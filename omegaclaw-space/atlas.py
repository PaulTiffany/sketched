from __future__ import annotations

import json
import math
import os
import re
from collections import Counter
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

from huggingface_hub import snapshot_download

_TOKEN_RE = re.compile(r"[a-z0-9]+(?:['-][a-z0-9]+)?", re.IGNORECASE)
_SPACE_RE = re.compile(r"\s+")
_STOPWORDS = {
    "a", "about", "an", "and", "are", "as", "at", "be", "been", "but", "by", "can",
    "could", "did", "do", "does", "for", "from", "had", "has", "have", "how", "i", "in",
    "into", "is", "it", "its", "me", "of", "on", "or", "our", "paper", "please", "that",
    "the", "their", "them", "there", "these", "they", "this", "to", "was", "we", "were",
    "what", "when", "where", "which", "who", "why", "will", "with", "would", "you", "your",
    "omegaclaw",
}

_PRIVATE_FIELDS = {
    "id",
    "source_files",
    "source_locator",
    "search_scope",
    "related_ids",
    "related_record_ids",
    "lean_refs",
    "paper_claim_id",
    "public_sources",
    "expected_record_ids",
    "required_points",
    "forbidden_claims",
    "expected_behavior",
}

_EXTRACTION_PATTERNS = (
    re.compile(r"\b(?:dump|export|print|reveal|show|return|give)\b.{0,60}\b(?:raw|hidden|private)\b.{0,40}\b(?:atlas|records?|context|prompt|dataset)\b", re.I),
    re.compile(r"\b(?:dump|export|reveal|show)\b.{0,50}\b(?:system prompt|hidden context|retrieval context|atlas records?|private dataset)\b", re.I),
    re.compile(r"\b(?:complete|full|entire)\b.{0,30}\b(?:manuscript|paper)\b.{0,30}\b(?:verbatim|section by section|word for word|text)\b", re.I),
    re.compile(r"\bcontinue\b.{0,50}\b(?:manuscript|paper|section|quoted passage)\b", re.I),
    re.compile(r"\breconstruct\b.{0,40}\b(?:manuscript|paper|atlas)\b", re.I),
)

_PERSONAL_PATTERNS = (
    re.compile(r"\b(?:phone|telephone|mobile|cell)\s*(?:number)?\b", re.I),
    re.compile(r"\b(?:street|home|residential|mailing)\s+address\b", re.I),
    re.compile(r"\bwhere\s+(?:does|is)\s+paul\s+(?:live|staying)\b", re.I),
)

PUBLIC_PAPER_URL = "https://link.springer.com/chapter/10.1007/978-3-032-33195-3_25"
PUBLIC_CONTACT_EMAIL = "paulctiffany@gmail.com"


class AtlasUnavailableError(RuntimeError):
    """Raised when atlas-backed answering is requested before a valid atlas is loaded."""


@dataclass(frozen=True)
class IndexedRecord:
    record_id: str
    source_kind: str
    prompt_payload: dict[str, Any]
    title_tokens: Counter[str]
    question_tokens: Counter[str]
    topic_tokens: Counter[str]
    body_tokens: Counter[str]
    title_text: str
    question_text: str


@dataclass(frozen=True)
class RetrievalResult:
    context: str
    count: int


def _normalize_text(value: str) -> str:
    return _SPACE_RE.sub(" ", value.casefold()).strip()


def _tokens(value: str, *, keep_stopwords: bool = False) -> list[str]:
    found = [match.group(0).casefold() for match in _TOKEN_RE.finditer(value)]
    if keep_stopwords:
        return found
    return [token for token in found if token not in _STOPWORDS and len(token) > 1]


def _flatten_strings(value: Any) -> Iterable[str]:
    if isinstance(value, str):
        yield value
    elif isinstance(value, (int, float, bool)):
        yield str(value)
    elif isinstance(value, list):
        for item in value:
            yield from _flatten_strings(item)
    elif isinstance(value, dict):
        for item in value.values():
            yield from _flatten_strings(item)


def _clean_value(value: Any) -> Any:
    if isinstance(value, str):
        return value.strip()
    if isinstance(value, list):
        cleaned = [_clean_value(item) for item in value]
        return [item for item in cleaned if item not in ("", [], {})]
    if isinstance(value, dict):
        cleaned = {str(key): _clean_value(item) for key, item in value.items()}
        return {key: item for key, item in cleaned.items() if item not in ("", [], {})}
    return value


def _public_projection(
    record: dict[str, Any],
    source_kind: str,
    public_sources: dict[str, dict[str, str]],
) -> dict[str, Any]:
    projection: dict[str, Any] = {"atlas_record_type": source_kind}
    for key, value in record.items():
        if key in _PRIVATE_FIELDS or value in (None, "", [], {}):
            continue
        projection[key] = _clean_value(value)

    resolved_sources: list[dict[str, str]] = []
    source_ids = record.get("public_sources", [])
    if isinstance(source_ids, list):
        for source_id in source_ids:
            source = public_sources.get(str(source_id))
            if source:
                resolved_sources.append({"label": source["label"], "url": source["url"]})
    if resolved_sources:
        projection["public_links"] = resolved_sources
    return projection


def is_extraction_request(question: str) -> bool:
    normalized = _normalize_text(question)
    return any(pattern.search(normalized) for pattern in _EXTRACTION_PATTERNS)


def is_prohibited_personal_request(question: str) -> bool:
    normalized = _normalize_text(question)
    return any(pattern.search(normalized) for pattern in _PERSONAL_PATTERNS)


def extraction_refusal() -> str:
    return (
        "I can’t provide raw atlas records, hidden retrieval context, prompts, or reconstruct the "
        f"manuscript. The authoritative published paper is available from Springer: {PUBLIC_PAPER_URL}. "
        "Ask me about a specific concept, claim, figure, experiment, citation, or intellectual influence instead."
    )


def personal_information_refusal() -> str:
    return (
        "I don’t provide or infer Paul Tiffany’s phone number, street address, temporary location, or "
        f"other non-public personal details. His approved public research contact is {PUBLIC_CONTACT_EMAIL}."
    )


class AtlasKnowledgeBase:
    def __init__(
        self,
        *,
        repo_id: str,
        token: str,
        revision: str = "main",
        expected_version: str = "",
        local_dir: str = "/tmp/hypothesis-surface-atlas",
        top_k: int = 5,
        max_context_chars: int = 14000,
    ) -> None:
        self.repo_id = repo_id.strip()
        self.token = token.strip()
        self.revision = revision.strip() or "main"
        self.expected_version = expected_version.strip()
        self.local_dir = local_dir
        self.top_k = max(3, min(5, int(top_k)))
        self.max_context_chars = max(4000, min(24000, int(max_context_chars)))

        self.loaded = False
        self.version = ""
        self.error = "not loaded"
        self.total_records = 0
        self.indexed_records = 0
        self._records: list[IndexedRecord] = []
        self._records_by_id: dict[str, IndexedRecord] = {}
        self._idf: dict[str, float] = {}

    def load_from_hub(self) -> None:
        if not self.repo_id:
            self._fail("HYPOTHESIS_SURFACE_ATLAS_REPO is not configured")
            return
        if not self.token:
            self._fail("HYPOTHESIS_SURFACE_ATLAS_TOKEN is not configured")
            return
        try:
            directory = snapshot_download(
                repo_id=self.repo_id,
                repo_type="dataset",
                revision=self.revision,
                token=self.token,
                local_dir=self.local_dir,
                allow_patterns=["*.json", "*.jsonl", "*.md", "evaluation/*.jsonl"],
            )
            self.load_from_directory(Path(directory))
        except Exception as exc:  # startup must remain observable through /health
            self._fail(f"{type(exc).__name__}: {exc}")

    def load_from_directory(self, directory: Path) -> None:
        try:
            root = self._locate_root(directory)
            manifest = json.loads((root / "atlas-manifest.json").read_text(encoding="utf-8"))
            version = str(manifest.get("atlas_version", "")).strip()
            if not version:
                raise ValueError("atlas manifest has no atlas_version")
            if self.expected_version and version != self.expected_version:
                raise ValueError(
                    f"atlas version {version!r} does not match required {self.expected_version!r}"
                )

            source_registry = json.loads((root / "public-source-registry.json").read_text(encoding="utf-8"))
            public_sources = {
                str(source["id"]): {
                    "label": str(source["label"]),
                    "url": str(source["url"]),
                }
                for source in source_registry.get("sources", [])
                if isinstance(source, dict) and source.get("id") and source.get("url")
            }

            all_ids: set[str] = set()
            total_records = 0
            runtime_records: list[IndexedRecord] = []
            for path in sorted(root.rglob("*.jsonl")):
                records = self._read_jsonl(path)
                is_evaluation = "evaluation" in path.relative_to(root).parts
                source_kind = path.stem.replace("_", "-")
                for record in records:
                    record_id = str(record.get("id", "")).strip()
                    if not record_id:
                        raise ValueError(f"{path.name} contains a record without an id")
                    if record_id in all_ids:
                        raise ValueError(f"duplicate atlas record id: {record_id}")
                    all_ids.add(record_id)
                    total_records += 1
                    if is_evaluation:
                        continue
                    runtime_records.append(
                        self._index_record(record_id, source_kind, record, public_sources)
                    )

            if not runtime_records:
                raise ValueError("atlas contains no runtime records")
            if not (root / "paper-atlas.jsonl").is_file():
                raise ValueError("paper-atlas.jsonl is missing")
            if not (root / "omegaclaw-answer-policy.md").is_file():
                raise ValueError("omegaclaw-answer-policy.md is missing")

            self._records = runtime_records
            self._records_by_id = {record.record_id: record for record in runtime_records}
            self._idf = self._build_idf(runtime_records)
            self.version = version
            self.total_records = total_records
            self.indexed_records = len(runtime_records)
            self.loaded = True
            self.error = ""
        except Exception as exc:
            self._fail(f"{type(exc).__name__}: {exc}")
            raise

    def _fail(self, detail: str) -> None:
        self.loaded = False
        self.version = ""
        self.total_records = 0
        self.indexed_records = 0
        self._records = []
        self._records_by_id = {}
        self._idf = {}
        self.error = detail[:500]

    @staticmethod
    def _locate_root(directory: Path) -> Path:
        candidates = [directory, directory / "private-atlas"]
        for candidate in candidates:
            if (candidate / "atlas-manifest.json").is_file():
                return candidate
        matches = list(directory.rglob("atlas-manifest.json"))
        if len(matches) == 1:
            return matches[0].parent
        raise FileNotFoundError("could not locate atlas-manifest.json")

    @staticmethod
    def _read_jsonl(path: Path) -> list[dict[str, Any]]:
        records: list[dict[str, Any]] = []
        for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            if not line.strip():
                continue
            value = json.loads(line)
            if not isinstance(value, dict):
                raise ValueError(f"{path.name}:{line_number} is not a JSON object")
            records.append(value)
        return records

    @staticmethod
    def _index_record(
        record_id: str,
        source_kind: str,
        record: dict[str, Any],
        public_sources: dict[str, dict[str, str]],
    ) -> IndexedRecord:
        projection = _public_projection(record, source_kind, public_sources)

        title_parts = [
            str(record.get(key, ""))
            for key in ("title", "term", "label", "question", "profile_type", "citation_type")
        ]
        question_parts = list(_flatten_strings(record.get("question_forms", [])))
        question_parts.extend(_flatten_strings(record.get("likely_questions", [])))
        if isinstance(record.get("question"), str):
            question_parts.append(str(record["question"]))
        topic_parts = list(_flatten_strings(record.get("topics", [])))
        topic_parts.extend(_flatten_strings(record.get("aliases", [])))

        body_source = {
            key: value
            for key, value in projection.items()
            if key not in {"atlas_record_type", "title", "term", "label", "question", "question_forms", "topics", "aliases"}
        }
        body_parts = list(_flatten_strings(body_source))

        title_text = _normalize_text(" ".join(title_parts))
        question_text = _normalize_text(" ".join(question_parts))
        topic_text = _normalize_text(" ".join(topic_parts))
        body_text = _normalize_text(" ".join(body_parts))

        return IndexedRecord(
            record_id=record_id,
            source_kind=source_kind,
            prompt_payload=projection,
            title_tokens=Counter(_tokens(title_text)),
            question_tokens=Counter(_tokens(question_text)),
            topic_tokens=Counter(_tokens(topic_text)),
            body_tokens=Counter(_tokens(body_text)),
            title_text=title_text,
            question_text=question_text,
        )

    @staticmethod
    def _build_idf(records: list[IndexedRecord]) -> dict[str, float]:
        document_frequency: Counter[str] = Counter()
        for record in records:
            tokens = set(record.title_tokens)
            tokens.update(record.question_tokens)
            tokens.update(record.topic_tokens)
            tokens.update(record.body_tokens)
            document_frequency.update(tokens)
        total = len(records)
        return {
            token: math.log((total + 1) / (frequency + 1)) + 1.0
            for token, frequency in document_frequency.items()
        }

    def retrieve(self, question: str) -> RetrievalResult:
        if not self.loaded:
            raise AtlasUnavailableError(self.error or "Hypothesis Surface atlas is unavailable")

        normalized = _normalize_text(re.sub(r"(?i)(?:^|\s)@?omegaclaw\b[:,]?", " ", question))
        query_tokens = Counter(_tokens(normalized))
        query_words = _tokens(normalized, keep_stopwords=True)
        bigrams = {" ".join(query_words[index:index + 2]) for index in range(len(query_words) - 1)}

        ranked: list[tuple[float, str, IndexedRecord]] = []
        for record in self._records:
            score = self._score(record, normalized, query_tokens, bigrams)
            ranked.append((score, record.record_id, record))
        ranked.sort(key=lambda item: (-item[0], item[1]))

        selected = [record for score, _, record in ranked if score > 0][: self.top_k]
        if len(selected) < 3:
            for fallback_id in (
                "hypothesis-surface-overview",
                "agent-identity",
                "faq-read-paper",
                "citation-springer-canonical",
            ):
                fallback = self._records_by_id.get(fallback_id)
                if fallback and fallback not in selected:
                    selected.append(fallback)
                if len(selected) >= 3:
                    break
        if not selected:
            selected = [self._records[0]]

        context = self._format_context(selected[: self.top_k])
        return RetrievalResult(context=context, count=min(len(selected), self.top_k))

    def _score(
        self,
        record: IndexedRecord,
        normalized_query: str,
        query_tokens: Counter[str],
        bigrams: set[str],
    ) -> float:
        score = 0.0
        if normalized_query and normalized_query in record.question_text:
            score += 28.0
        if normalized_query and normalized_query in record.title_text:
            score += 18.0

        for token, query_count in query_tokens.items():
            idf = self._idf.get(token, 1.0)
            score += min(query_count, record.question_tokens.get(token, 0)) * 7.0 * idf
            score += min(query_count, record.title_tokens.get(token, 0)) * 6.0 * idf
            score += min(query_count, record.topic_tokens.get(token, 0)) * 5.0 * idf
            score += min(query_count, record.body_tokens.get(token, 0)) * 1.6 * idf

        combined_focus = f"{record.title_text} {record.question_text}"
        score += sum(4.0 for bigram in bigrams if bigram and bigram in combined_focus)

        tokens = set(query_tokens)
        if tokens & {"email", "contact", "orcid", "linkedin", "github"}:
            if record.source_kind in {"public-contact-directory", "public-faq", "public-author-profile"}:
                score += 16.0
        if tokens & {"cite", "citation", "bibtex", "doi", "springer"}:
            if record.source_kind == "public-citations":
                score += 20.0
        if tokens & {"conference", "agi26", "agi", "poster", "venue", "virtual"}:
            if record.source_kind in {"public-conference-context", "public-faq"}:
                score += 14.0
        if tokens & {"why", "motivation", "philosophy", "influence", "art", "music", "drum", "jam"}:
            if record.source_kind in {"public-intellectual-context", "bibliography-rationale", "paper-atlas"}:
                score += 10.0
        if tokens & {"compitum", "principia", "paleae", "sketched", "come"}:
            if record.source_kind in {"public-projects", "public-faq"}:
                score += 14.0
        if tokens & {"you", "yourself", "omegaclaw", "agent"}:
            if record.source_kind == "public-agent-context":
                score += 12.0
        return score

    def _format_context(self, records: list[IndexedRecord]) -> str:
        chunks: list[str] = []
        used = 0
        for record in records:
            encoded = json.dumps(record.prompt_payload, ensure_ascii=False, separators=(",", ":"))
            if len(encoded) > 4200:
                encoded = encoded[:4190] + '…"}'
            addition = len(encoded) + 2
            if chunks and used + addition > self.max_context_chars:
                break
            chunks.append(encoded)
            used += addition
        return "\n".join(chunks)

    def health(self) -> dict[str, Any]:
        return {
            "kb_loaded": self.loaded,
            "kb_version": self.version,
            "kb_records": self.total_records,
            "kb_indexed_records": self.indexed_records,
            "kb_error": self.error,
        }


def knowledge_base_from_environment() -> AtlasKnowledgeBase:
    return AtlasKnowledgeBase(
        repo_id=os.getenv("HYPOTHESIS_SURFACE_ATLAS_REPO", "PaulTiffany/hypothesis-surface-atlas"),
        token=(
            os.getenv("HYPOTHESIS_SURFACE_ATLAS_TOKEN", "")
            or os.getenv("HF_TOKEN", "")
        ),
        revision=os.getenv("HYPOTHESIS_SURFACE_ATLAS_REVISION", "main"),
        expected_version=os.getenv("HYPOTHESIS_SURFACE_ATLAS_VERSION", "1.4.1"),
        local_dir=os.getenv("HYPOTHESIS_SURFACE_ATLAS_DIR", "/tmp/hypothesis-surface-atlas"),
        top_k=int(os.getenv("HYPOTHESIS_SURFACE_ATLAS_TOP_K", "5")),
        max_context_chars=int(os.getenv("HYPOTHESIS_SURFACE_ATLAS_MAX_CONTEXT_CHARS", "14000")),
    )
