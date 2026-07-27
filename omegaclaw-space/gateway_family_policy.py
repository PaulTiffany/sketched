from __future__ import annotations

import json
import re
from pathlib import Path
from types import MethodType
from typing import Any

import gateway as _gateway


# Keep the base gateway authoritative, but replace its blanket family prohibition
# with a narrow conference-safe genealogy rule. This overlay is intentionally
# small so the public Space can discuss only records already curated for public use.
_OLD_POLICY = """You may directly provide approved public links, email, ORCID, GitHub, LinkedIn, public location,
citation, and conference information contained in the records. Never infer or provide a street
address, phone number, temporary location, travel, accommodation, family, or other non-approved
personal information."""

_NEW_POLICY = """You may directly provide approved public links, email, ORCID, GitHub, LinkedIn, public location,
citation, conference information, and privacy-filtered genealogy contained in the records. Family
information may be provided only when a retrieved atlas record explicitly marks it public-safe.
Never infer omitted relatives, reconstruct missing generations, identify living or uncertain-status
relatives other than the author, or provide exact private dates, raw GEDCOM content, Ancestry
identifiers, private notes, media references, addresses, phone numbers, temporary location, travel,
accommodation, or other non-approved personal information. Biological ancestry is not evidence of
intellectual influence, character, capability, or destiny."""

_original_paper_prompt = _gateway._paper_prompt


def _paper_prompt(
    name: str,
    question: str,
    retrieved_context: str,
    directed: bool,
) -> str:
    prompt = _original_paper_prompt(name, question, retrieved_context, directed)
    if _OLD_POLICY not in prompt:
        raise RuntimeError("OmegaClaw family policy overlay no longer matches gateway.py")
    return prompt.replace(_OLD_POLICY, _NEW_POLICY)


_gateway._paper_prompt = _paper_prompt


# Bulk family-tree extraction remains prohibited even when a narrow public-safe
# genealogical answer exists in the atlas.
_FAMILY_EXTRACTION_RE = re.compile(
    r"\b(?:dump|download|export|print|reveal|show|return|give|provide|reconstruct)\b"
    r".{0,80}\b(?:raw\s+gedcom|gedcom|complete\s+family\s+tree|full\s+family\s+tree|"
    r"ancestry\s+identifiers?|private\s+notes?|media\s+references?)\b",
    re.IGNORECASE,
)
_original_is_extraction_request = _gateway.is_extraction_request


def _is_extraction_request(question: str) -> bool:
    return _original_is_extraction_request(question) or bool(_FAMILY_EXTRACTION_RE.search(question))


_gateway.is_extraction_request = _is_extraction_request


# Merge the curated family records into the in-memory atlas after the private
# Hugging Face dataset has loaded. The source GEDCOM itself is never shipped.
_FAMILY_ATLAS_PATH = Path(__file__).with_name("family_atlas.jsonl")
_original_load_from_hub = _gateway.knowledge_base.load_from_hub


def _load_from_hub_with_family(self: Any) -> None:
    _original_load_from_hub()
    if not self.loaded or not _FAMILY_ATLAS_PATH.is_file():
        return

    existing_ids = set(self._records_by_id)
    additions = []
    for line_number, line in enumerate(
        _FAMILY_ATLAS_PATH.read_text(encoding="utf-8").splitlines(), start=1
    ):
        if not line.strip():
            continue
        record = json.loads(line)
        if not isinstance(record, dict):
            raise ValueError(f"family_atlas.jsonl:{line_number} is not an object")
        record_id = str(record.get("id", "")).strip()
        if not record_id:
            raise ValueError(f"family_atlas.jsonl:{line_number} has no id")
        if record_id in existing_ids:
            raise ValueError(f"duplicate atlas record id: {record_id}")
        existing_ids.add(record_id)
        additions.append(self._index_record(record_id, "family-atlas", record, {}))

    if additions:
        self._records.extend(additions)
        self._records_by_id.update({record.record_id: record for record in additions})
        self._idf = self._build_idf(self._records)
        self.total_records += len(additions)
        self.indexed_records += len(additions)


_gateway.knowledge_base.load_from_hub = MethodType(
    _load_from_hub_with_family, _gateway.knowledge_base
)


# Give the curated family records a modest routing boost for explicitly
# genealogical questions without changing ordinary paper/project retrieval.
_FAMILY_QUERY_TOKENS = {
    "ancestor",
    "ancestors",
    "ancestry",
    "family",
    "father",
    "gedcom",
    "genealogy",
    "grandfather",
    "grandmother",
    "grandparent",
    "grandparents",
    "maternal",
    "mother",
    "paternal",
    "relative",
    "relatives",
}
_original_score = _gateway.knowledge_base._score


def _score_with_family(
    self: Any,
    record: Any,
    normalized_query: str,
    query_tokens: Any,
    bigrams: set[str],
) -> float:
    score = _original_score(record, normalized_query, query_tokens, bigrams)
    if record.source_kind == "family-atlas" and set(query_tokens) & _FAMILY_QUERY_TOKENS:
        score += 18.0
    return score


_gateway.knowledge_base._score = MethodType(_score_with_family, _gateway.knowledge_base)
_gateway.app.version = "0.3.3"

app = _gateway.app
