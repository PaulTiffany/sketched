"""Static regime-change sensor for the external LLMET source artifact.

The source file is treated as an ordered artifact, not as a transcript of a
model's hidden state. The sensor measures defensive-programming features in
overlapping line windows, reports first- and second-difference changes, and
retains conservative control-flow anomalies such as code following a block
that returns on every path.

No source is executed or copied into the certificate. A nonzero regime score
does not identify authorship, cognition, imagination, or a phase transition.
"""
from __future__ import annotations

import argparse
import ast
import hashlib
import io
import json
import math
import re
import statistics
import tokenize
from pathlib import Path
from typing import Any, Iterable

SCHEMA = "sketched.llmet-regime-certificate.v1"

FEATURE_NAMES = (
    "comment_rate",
    "try_rate",
    "handler_rate",
    "broad_handler_rate",
    "pass_rate",
    "raise_rate",
    "return_rate",
    "defensive_term_rate",
    "tool_boundary_rate",
    "logging_rate",
    "warning_suppression_rate",
)

DEFENSIVE_PATTERN = re.compile(
    r"\b(?:fallback|defensive|unexpected|warning|error|fail(?:ed|ure)?|"
    r"timeout|invalid|nan|inf|cleanup|abort|shouldn['’]?t|ensure|guard)\b",
    re.IGNORECASE,
)
TOOL_PATTERN = re.compile(
    r"(?:solver|cvxpy|problem\.solve|future|thread|executor|\.submit\(|"
    r"\.result\(|self\.after\()",
    re.IGNORECASE,
)
LOG_PATTERN = re.compile(
    r"(?:log_message\(|logging\.(?:debug|info|warning|error|exception)\()"
)
WARNING_SUPPRESSION_PATTERN = re.compile(
    r"warnings\.filterwarnings\(\s*[\"']ignore[\"']", re.IGNORECASE
)


def _rms(values: Iterable[float]) -> float:
    values = list(values)
    if not values:
        return 0.0
    return math.sqrt(sum(value * value for value in values) / len(values))


def _dot(left: list[float], right: list[float]) -> float:
    return sum(x * y for x, y in zip(left, right, strict=True))


def _is_broad_handler(handler: ast.ExceptHandler) -> bool:
    exception_type = handler.type
    if exception_type is None:
        return True
    if isinstance(exception_type, ast.Name):
        return exception_type.id in {"Exception", "BaseException"}
    if isinstance(exception_type, ast.Tuple):
        return any(
            isinstance(item, ast.Name)
            and item.id in {"Exception", "BaseException"}
            for item in exception_type.elts
        )
    return False


def _block_terminates(statements: list[ast.stmt]) -> bool:
    return bool(statements) and _statement_terminates(statements[-1])


def _statement_terminates(statement: ast.stmt) -> bool:
    if isinstance(statement, (ast.Return, ast.Raise, ast.Break, ast.Continue)):
        return True
    if isinstance(statement, ast.If):
        return (
            bool(statement.orelse)
            and _block_terminates(statement.body)
            and _block_terminates(statement.orelse)
        )
    if isinstance(statement, ast.Try):
        if statement.finalbody and _block_terminates(statement.finalbody):
            return True
        return (
            bool(statement.handlers)
            and _block_terminates(statement.body)
            and all(
                _block_terminates(handler.body)
                for handler in statement.handlers
            )
            and (
                not statement.orelse
                or _block_terminates(statement.orelse)
            )
        )
    return False


def _nested_blocks(
    node: ast.AST,
) -> Iterable[tuple[str, list[ast.stmt]]]:
    for field_name in ("body", "orelse", "finalbody"):
        value = getattr(node, field_name, None)
        if (
            isinstance(value, list)
            and value
            and all(isinstance(item, ast.stmt) for item in value)
        ):
            yield field_name, value
    if isinstance(node, ast.Try):
        for index, handler in enumerate(node.handlers):
            if handler.body:
                yield f"handler[{index}]", handler.body
    if isinstance(node, ast.Match):
        for index, case in enumerate(node.cases):
            if case.body:
                yield f"case[{index}]", case.body


def _unreachable_regions(tree: ast.AST) -> list[dict[str, Any]]:
    findings: list[dict[str, Any]] = []

    def scan(block: list[ast.stmt], scope: str) -> None:
        terminator: ast.stmt | None = None
        for statement in block:
            if terminator is not None:
                findings.append(
                    {
                        "kind": (
                            "unreachable_after_guaranteed_termination"
                        ),
                        "scope": scope,
                        "terminator_line": getattr(
                            terminator, "lineno", None
                        ),
                        "start_line": getattr(statement, "lineno", None),
                        "end_line": getattr(
                            block[-1],
                            "end_lineno",
                            getattr(block[-1], "lineno", None),
                        ),
                    }
                )
                break
            for child_name, child_block in _nested_blocks(statement):
                scan(
                    child_block,
                    (
                        f"{scope}/{type(statement).__name__}."
                        f"{child_name}@{getattr(statement, 'lineno', '?')}"
                    ),
                )
            if _statement_terminates(statement):
                terminator = statement

    body = getattr(tree, "body", [])
    if isinstance(body, list):
        scan(body, "module")
    return findings


def _handler_findings(
    tree: ast.AST,
) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    broad: list[dict[str, Any]] = []
    pass_only: list[dict[str, Any]] = []
    for node in ast.walk(tree):
        if not isinstance(node, ast.ExceptHandler):
            continue
        if _is_broad_handler(node):
            broad.append(
                {
                    "line": node.lineno,
                    "reraises": any(
                        isinstance(child, ast.Raise)
                        for child in ast.walk(node)
                    ),
                }
            )
        if node.body and all(
            isinstance(statement, ast.Pass) for statement in node.body
        ):
            pass_only.append({"line": node.lineno})
    return broad, pass_only


def _comment_lines(source: str) -> list[int]:
    try:
        return [
            token.start[0]
            for token in tokenize.generate_tokens(
                io.StringIO(source).readline
            )
            if token.type == tokenize.COMMENT
        ]
    except tokenize.TokenError:
        return []


def _window_ranges(
    line_count: int,
    window_lines: int,
    stride_lines: int,
) -> list[tuple[int, int]]:
    if window_lines < 2 or stride_lines < 1:
        raise ValueError(
            "window_lines must be >= 2 and stride_lines must be >= 1"
        )
    if line_count == 0:
        return []
    starts = list(
        range(1, max(2, line_count - window_lines + 2), stride_lines)
    )
    final_start = max(1, line_count - window_lines + 1)
    if not starts or starts[-1] != final_start:
        starts.append(final_start)
    return [
        (start, min(line_count, start + window_lines - 1))
        for start in starts
    ]


def _build_windows(
    source: str,
    tree: ast.AST,
    *,
    window_lines: int,
    stride_lines: int,
) -> list[dict[str, Any]]:
    lines = source.splitlines()
    comments = _comment_lines(source)
    tries = [
        node for node in ast.walk(tree) if isinstance(node, ast.Try)
    ]
    handlers = [
        node
        for node in ast.walk(tree)
        if isinstance(node, ast.ExceptHandler)
    ]
    passes = [
        node for node in ast.walk(tree) if isinstance(node, ast.Pass)
    ]
    raises = [
        node for node in ast.walk(tree) if isinstance(node, ast.Raise)
    ]
    returns = [
        node for node in ast.walk(tree) if isinstance(node, ast.Return)
    ]

    def in_range(
        nodes: Iterable[ast.AST], start: int, end: int
    ) -> list[ast.AST]:
        return [
            node
            for node in nodes
            if start <= getattr(node, "lineno", -1) <= end
        ]

    windows: list[dict[str, Any]] = []
    ranges = _window_ranges(
        len(lines), window_lines, stride_lines
    )
    for index, (start, end) in enumerate(ranges):
        source_lines = lines[start - 1 : end]
        text = "\n".join(source_lines)
        nonblank = max(1, sum(bool(line.strip()) for line in source_lines))
        factor = 100.0 / nonblank
        window_handlers = in_range(handlers, start, end)
        counts = {
            "comments": sum(start <= line <= end for line in comments),
            "tries": len(in_range(tries, start, end)),
            "handlers": len(window_handlers),
            "broad_handlers": sum(
                _is_broad_handler(handler)
                for handler in window_handlers
            ),
            "passes": len(in_range(passes, start, end)),
            "raises": len(in_range(raises, start, end)),
            "returns": len(in_range(returns, start, end)),
            "defensive_terms": len(DEFENSIVE_PATTERN.findall(text)),
            "tool_terms": len(TOOL_PATTERN.findall(text)),
            "logging_calls": len(LOG_PATTERN.findall(text)),
            "warning_suppressions": len(
                WARNING_SUPPRESSION_PATTERN.findall(text)
            ),
        }
        features = {
            "comment_rate": counts["comments"] * factor,
            "try_rate": counts["tries"] * factor,
            "handler_rate": counts["handlers"] * factor,
            "broad_handler_rate": counts["broad_handlers"] * factor,
            "pass_rate": counts["passes"] * factor,
            "raise_rate": counts["raises"] * factor,
            "return_rate": counts["returns"] * factor,
            "defensive_term_rate": (
                counts["defensive_terms"] * factor
            ),
            "tool_boundary_rate": counts["tool_terms"] * factor,
            "logging_rate": counts["logging_calls"] * factor,
            "warning_suppression_rate": (
                counts["warning_suppressions"] * factor
            ),
        }
        windows.append(
            {
                "index": index,
                "start_line": start,
                "end_line": end,
                "nonblank_lines": nonblank,
                "counts": counts,
                "features_per_100_nonblank_lines": features,
            }
        )
    return windows


def _standardized_vectors(
    windows: list[dict[str, Any]],
) -> list[list[float]]:
    columns = [
        [
            window["features_per_100_nonblank_lines"][name]
            for window in windows
        ]
        for name in FEATURE_NAMES
    ]
    means = [statistics.fmean(column) for column in columns]
    deviations = [statistics.pstdev(column) for column in columns]
    return [
        [
            (
                0.0
                if deviations[index] <= 1e-12
                else (
                    window["features_per_100_nonblank_lines"][name]
                    - means[index]
                )
                / deviations[index]
            )
            for index, name in enumerate(FEATURE_NAMES)
        ]
        for window in windows
    ]


def _robust_threshold(values: list[float]) -> float:
    if not values:
        return 0.0
    median = statistics.median(values)
    mad = statistics.median(abs(value - median) for value in values)
    if mad <= 1e-12:
        return max(1e-12, 1.5 * median)
    return median + 3.0 * 1.4826 * mad


def _transitions(
    windows: list[dict[str, Any]],
    vectors: list[list[float]],
) -> tuple[list[dict[str, Any]], float]:
    transitions: list[dict[str, Any]] = []
    for index in range(1, len(vectors)):
        delta = [
            current - previous
            for previous, current in zip(
                vectors[index - 1], vectors[index], strict=True
            )
        ]
        contributions = sorted(
            (
                {
                    "feature": name,
                    "absolute_standardized_change": abs(delta[j]),
                }
                for j, name in enumerate(FEATURE_NAMES)
            ),
            key=lambda item: item["absolute_standardized_change"],
            reverse=True,
        )
        transitions.append(
            {
                "from_window": index - 1,
                "to_window": index,
                "boundary_line": windows[index]["start_line"],
                "distance": _rms(delta),
                "leading_features": contributions[:4],
            }
        )
    threshold = _robust_threshold(
        [item["distance"] for item in transitions]
    )
    for item in transitions:
        item["candidate_regime_change"] = (
            item["distance"] > threshold
        )
    return transitions, threshold


def _curvatures(
    vectors: list[list[float]],
) -> tuple[list[dict[str, Any]], float]:
    rows: list[dict[str, Any]] = []
    for index in range(1, len(vectors) - 1):
        before = [
            current - previous
            for previous, current in zip(
                vectors[index - 1], vectors[index], strict=True
            )
        ]
        after = [
            following - current
            for current, following in zip(
                vectors[index], vectors[index + 1], strict=True
            )
        ]
        curvature = [
            right - left
            for left, right in zip(before, after, strict=True)
        ]
        before_norm = math.sqrt(_dot(before, before))
        after_norm = math.sqrt(_dot(after, after))
        cosine = (
            None
            if before_norm <= 1e-12 or after_norm <= 1e-12
            else _dot(before, after) / (before_norm * after_norm)
        )
        rows.append(
            {
                "window": index,
                "curvature_norm": _rms(curvature),
                "successive_change_cosine": cosine,
                "orientation_reversal": (
                    cosine is not None and cosine < 0
                ),
            }
        )
    threshold = _robust_threshold(
        [item["curvature_norm"] for item in rows]
    )
    for item in rows:
        item["candidate_second_order_change"] = (
            item["curvature_norm"] > threshold
        )
    return rows, threshold


def analyze_source(
    source: str,
    *,
    source_label: str,
    window_lines: int = 160,
    stride_lines: int = 80,
) -> dict[str, Any]:
    """Analyze source text without importing or executing it."""
    try:
        tree = ast.parse(source)
    except SyntaxError as exc:
        raise ValueError(
            f"source is not valid Python: line {exc.lineno}: {exc.msg}"
        ) from exc

    windows = _build_windows(
        source,
        tree,
        window_lines=window_lines,
        stride_lines=stride_lines,
    )
    vectors = _standardized_vectors(windows)
    transitions, transition_threshold = _transitions(windows, vectors)
    curvatures, curvature_threshold = _curvatures(vectors)
    broad_handlers, pass_only_handlers = _handler_findings(tree)
    unreachable = _unreachable_regions(tree)
    warning_suppression_lines = [
        index
        for index, line in enumerate(source.splitlines(), start=1)
        if WARNING_SUPPRESSION_PATTERN.search(line)
    ]

    ranked_transitions = sorted(
        transitions,
        key=lambda item: item["distance"],
        reverse=True,
    )
    ranked_curvatures = sorted(
        curvatures,
        key=lambda item: item["curvature_norm"],
        reverse=True,
    )
    return {
        "schema": SCHEMA,
        "source": {
            "label": source_label,
            "sha256": hashlib.sha256(
                source.encode("utf-8")
            ).hexdigest(),
            "bytes_utf8": len(source.encode("utf-8")),
            "line_count": len(source.splitlines()),
            "executed": False,
            "copied_into_certificate": False,
        },
        "method": {
            "ordered_source_proxy": (
                "line order; not verified generation chronology"
            ),
            "window_lines": window_lines,
            "stride_lines": stride_lines,
            "feature_names": list(FEATURE_NAMES),
            "transition_threshold": transition_threshold,
            "curvature_threshold": curvature_threshold,
            "threshold_rule": (
                "median + 3 * 1.4826 * MAD; "
                "1.5 * median fallback"
            ),
            "authorship_claim": False,
            "cognitive_state_claim": False,
            "imagination_claim": False,
            "phase_transition_claim": False,
        },
        "summary": {
            "window_count": len(windows),
            "transition_count": len(transitions),
            "candidate_regime_changes": sum(
                item["candidate_regime_change"]
                for item in transitions
            ),
            "candidate_second_order_changes": sum(
                item["candidate_second_order_change"]
                for item in curvatures
            ),
            "orientation_reversals": sum(
                item["orientation_reversal"]
                for item in curvatures
            ),
            "try_blocks": sum(
                isinstance(node, ast.Try) for node in ast.walk(tree)
            ),
            "exception_handlers": sum(
                isinstance(node, ast.ExceptHandler)
                for node in ast.walk(tree)
            ),
            "broad_exception_handlers": len(broad_handlers),
            "broad_handlers_without_reraise": sum(
                not item["reraises"] for item in broad_handlers
            ),
            "pass_only_handlers": len(pass_only_handlers),
            "warning_suppressions": len(warning_suppression_lines),
            "unreachable_regions": len(unreachable),
        },
        "static_witnesses": {
            "unreachable_regions": unreachable,
            "warning_suppression_lines": warning_suppression_lines,
            "broad_handler_sample": broad_handlers[:20],
            "pass_only_handlers": pass_only_handlers,
        },
        "ranked_transitions": ranked_transitions[:12],
        "ranked_second_order_changes": ranked_curvatures[:12],
        "windows": windows,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--source-label", default="LLMET.py")
    parser.add_argument("--window-lines", type=int, default=160)
    parser.add_argument("--stride-lines", type=int, default=80)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    source = args.source.read_text(encoding="utf-8-sig")
    certificate = analyze_source(
        source,
        source_label=args.source_label,
        window_lines=args.window_lines,
        stride_lines=args.stride_lines,
    )
    rendered = json.dumps(certificate, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(
            rendered,
            encoding="utf-8",
            newline="\n",
        )
    else:
        print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
