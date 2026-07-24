FROM singularitynet/omegaclaw:latest

USER root

# The official OmegaClaw runtime image includes a mutually compatible
# huggingface_hub / transformers / sentence_transformers stack. Install only
# the gateway dependencies; replacing huggingface_hub independently breaks the
# local embedding runtime.
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip install --no-cache-dir --break-system-packages \
        fastapi==0.116.1 \
        "uvicorn[standard]==0.35.0"

# Both the private-atlas loader and OmegaClaw local embeddings must import
# successfully in the final dependency environment. Catch compatibility drift
# during the image build rather than after the Space starts.
RUN python3 - <<'PY'
from importlib.metadata import version

from huggingface_hub import is_offline_mode, snapshot_download
from sentence_transformers import SentenceTransformer

assert callable(snapshot_download)
assert callable(is_offline_mode)
assert SentenceTransformer is not None
print('huggingface_hub', version('huggingface_hub'))
print('transformers', version('transformers'))
print('sentence-transformers', version('sentence-transformers'))
PY

# OmegaClaw starts its governed outbound proxy as www-data. Hugging Face
# Spaces does not allow that unprivileged process to open /dev/stdout or
# /dev/stderr, so preserve the proxy and redirect only its logs to writable
# regular files. Patch both templates and scripts because nginx.conf is
# generated at container startup.
RUN find /opt/nginx -type f -exec sed -i \
        -e 's#/dev/stderr#/tmp/omegaclaw-nginx-error.log#g' \
        -e 's#/dev/stdout#/tmp/omegaclaw-nginx-access.log#g' \
        {} + \
    && touch /tmp/omegaclaw-nginx-error.log /tmp/omegaclaw-nginx-access.log \
    && chown www-data:www-data \
        /tmp/omegaclaw-nginx-error.log \
        /tmp/omegaclaw-nginx-access.log \
    && chmod 0660 \
        /tmp/omegaclaw-nginx-error.log \
        /tmp/omegaclaw-nginx-access.log

# Patch the upstream harness for this bounded public profile:
# - preserve upstream wake-counter semantics, where 1 + maxWakeLoops is
#   decremented before the provider branch; maxWakeLoops=1 therefore yields
#   exactly one maintenance provider call;
# - a successful public send ends the active human-triggered deliberation;
# - only read-only recall, short-term state, MeTTa reasoning, and send are
#   advertised; persistent remember is disabled as defense in depth.
RUN python3 - <<'PY'
from pathlib import Path
import re

loop_path = Path('/PeTTa/repos/OmegaClaw-Core/src/loop.metta')
loop_text = loop_path.read_text(encoding='utf-8')
native_wake = '(change-state! &loops (+ 1 (maxWakeLoops)))'
if loop_text.count(native_wake) != 1:
    raise SystemExit(
        f'expected exactly one native upstream wake-counter expression, found {loop_text.count(native_wake)}'
    )

channels_path = Path('/PeTTa/repos/OmegaClaw-Core/src/channels.metta')
channels_text = channels_path.read_text(encoding='utf-8')
if '(change-state! &loops 0)' not in channels_text:
    pattern = r'(\(progn\s+\(change-state!\s+&lastsend\s+\$msg\))'
    channels_text, count = re.subn(
        pattern,
        r'\1\n              (change-state! &loops 0)',
        channels_text,
        count=1,
    )
    if count != 1:
        raise SystemExit(f'could not structurally patch upstream send definition; matches={count}')
channels_path.write_text(channels_text, encoding='utf-8')

skills_path = Path('/PeTTa/repos/OmegaClaw-Core/src/skills.metta')
skills_text = skills_path.read_text(encoding='utf-8')
start = skills_text.find('(= (getSkills)')
end = skills_text.find('(= (read-file $file)')
if start < 0 or end <= start:
    raise SystemExit('could not locate upstream getSkills block')
limited_skills = '''(= (getSkills)
   ("- Query compact long-term memory only when prior room context is materially relevant: query string"
    "- Search episode history around an explicit timestamp: episodes time_string"
    "- Pin short-term working state for the current turn: pin string"
    "- Execute bounded MeTTa or NAL reasoning: metta sexpression"
    "- Send the single public reply and end the active human turn: send string"))


'''
skills_path.write_text(skills_text[:start] + limited_skills + skills_text[end:], encoding='utf-8')

memory_path = Path('/PeTTa/repos/OmegaClaw-Core/src/memory.metta')
memory_text = memory_path.read_text(encoding='utf-8')
if 'REMEMBER-DISABLED-IN-PUBLIC-ROOM' not in memory_text:
    pattern = r'\(=\s*\(remember\s+\$str\)\s*\(progn.*?REMEMBER-SUCCESS\)\)'
    memory_text, count = re.subn(
        pattern,
        '(= (remember $str)\n   REMEMBER-DISABLED-IN-PUBLIC-ROOM)',
        memory_text,
        count=1,
        flags=re.DOTALL,
    )
    if count != 1:
        raise SystemExit(f'could not structurally disable upstream remember; matches={count}')
memory_path.write_text(memory_text, encoding='utf-8')

checks = (
    (loop_path, native_wake, None),
    (channels_path, '(change-state! &loops 0)', None),
    (skills_path, 'Send the single public reply and end the active human turn', 'Execute shell command'),
    (memory_path, 'REMEMBER-DISABLED-IN-PUBLIC-ROOM', 'lib_chromadb.remember $str'),
)
for path, required, forbidden in checks:
    text = path.read_text(encoding='utf-8')
    if required not in text or (forbidden and forbidden in text):
        raise SystemExit(f'OmegaClaw public-profile patch verification failed for {path}')
PY

WORKDIR /app
COPY atlas.py /app/atlas.py
COPY gateway.py /app/gateway.py
COPY public_prompt_OpenRouter.txt /PeTTa/repos/OmegaClaw-Core/memory/prompt_OpenRouter.txt
COPY start.sh /app/start.sh

# Align the gateway and retrieval service with the bounded agent harness and
# Hypothesis Surface Atlas v1.7.0. Source replacements are asserted so drift
# fails the image build instead of silently weakening the deployment.
RUN python3 - <<'PY'
from pathlib import Path

atlas_path = Path('/app/atlas.py')
atlas_text = atlas_path.read_text(encoding='utf-8')
atlas_replacements = {
    'expected_version=os.getenv("HYPOTHESIS_SURFACE_ATLAS_VERSION", "1.4.1")':
        'expected_version=os.getenv("HYPOTHESIS_SURFACE_ATLAS_VERSION", "1.7.0")',
    '''        tokens = set(query_tokens)
        if tokens & {"email", "contact", "orcid", "linkedin", "github"}:''':
        '''        tokens = set(query_tokens)
        if tokens & {"example", "examples", "worked", "concrete", "calculate", "numeric", "practice", "walkthrough"}:
            if record.source_kind == "worked-examples":
                score += 24.0
        if tokens & {"need", "needs", "capable", "capability", "service", "perform", "sufficient", "missing", "wish"}:
            if record.record_id == "agent-capability-inventory":
                score += 38.0
            elif record.source_kind == "public-agent-context":
                score += 10.0
        if tokens & {"figure", "figures", "visual", "diagram", "table", "tables"}:
            if record.source_kind == "figures-experiments":
                score += 22.0
        if tokens & {"demonstrate", "demonstrates", "demonstrated", "propose", "proposes", "proposed", "empirical", "theoretical", "proof", "proved", "future"}:
            if record.record_id == "demonstrated-proposed-future-map":
                score += 30.0
        if tokens & {"companion", "gauge", "covariance", "stokes", "fftc", "residue", "cohomology", "rayleigh", "chern", "proof"}:
            if record.source_kind == "public-github-companions":
                score += 24.0
        if tokens & {"grace", "beauty", "frame", "basis", "parlance"}:
            if record.record_id == "author-parlance-grace-beauty-frame-construction":
                score += 36.0
            elif record.source_kind == "public-github-companions":
                score += 10.0
        if tokens & {"pipeline", "run", "rerun", "reproduce", "reproduction", "parameter", "parameters", "code", "scorecard"}:
            if record.source_kind == "public-github-companions":
                score += 20.0
        if tokens & {"v2", "axis", "falsified", "falsification", "goldilocks", "u-shaped", "u-shape"}:
            if record.source_kind == "public-github-companions":
                score += 22.0
        if tokens & {"sonification", "notebook"}:
            if record.record_id == "github-companion-repository-boundary":
                score += 40.0
        if tokens & {"email", "contact", "orcid", "linkedin", "github"}:''',
}
for old, new in atlas_replacements.items():
    if atlas_text.count(old) != 1:
        raise SystemExit(f'expected exactly one atlas fragment, found {atlas_text.count(old)}: {old[:80]}')
    atlas_text = atlas_text.replace(old, new)
atlas_path.write_text(atlas_text, encoding='utf-8')

gateway_path = Path('/app/gateway.py')
gateway_text = gateway_path.read_text(encoding='utf-8')
gateway_replacements = {
    'TURN_TIMEOUT = min(60, max(30, int(os.getenv("Z0_TURN_TIMEOUT_SECONDS", "60"))))':
        'TURN_TIMEOUT = min(120, max(45, int(os.getenv("Z0_TURN_TIMEOUT_SECONDS", "90"))))',
    'ROOM_HISTORY_LIMIT = max(20, min(1000, int(os.getenv("Z0_ROOM_HISTORY_LIMIT", "300"))))':
        'ROOM_HISTORY_LIMIT = max(20, min(1000, int(os.getenv("Z0_ROOM_HISTORY_LIMIT", "300"))))\nROOM_LOOKBACK_LIMIT = max(0, min(10, int(os.getenv("Z0_ROOM_LOOKBACK_ENTRIES", "5"))))',
    'app = FastAPI(title="AGI-26 OmegaClaw Room", version="0.3.2")':
        'app = FastAPI(title="AGI-26 OmegaClaw Room", version="0.5.1")',
    'Every human post gives you one bounded turn;':
        'Every human post grants up to three bounded deliberation loops;',
    '''record with general model knowledge. If the records do not support a confident answer, say so.''':
        '''record with general model knowledge. If the records do not support a confident answer, say so.

Worked-example records are pedagogical. Preserve their status and boundaries. Never present a
synthetic illustrative scenario as an experiment performed in the Springer paper. A
worked_interpretation_of_reported_result may explain reported numbers but does not add new evidence.

A retrieval packet is a turn-specific selection, not the complete atlas inventory. Do not infer that
worked examples, figure descriptions, experiment records, formal companions, public glossary terms,
or status boundaries are absent merely because they were not retrieved in another turn. For questions
about what you know, have, lack, need, or can explain, obey the agent capability inventory and
distinguish a retrieval gap from a true atlas absence.

Public GitHub companion records are secondary to the Springer paper and must retain their source and
chronology. F1/F2/F3 may deepen formally scoped arguments; camera-ready scorecards support the
published evaluation; later integration-v2 findings may narrow or falsify operational predictions but
must not be silently rewritten into the Springer paper. You may explain public code, commands, and
reference outputs, but this chat does not execute repository code and you must never claim a fresh run.
Sonification and iteration-as-operator materials are deliberately outside your atlas and service. Do
not summarize, infer, reconstruct, or describe them; say only that they are outside the current guide's
scope and may be presented through a separate future interface chosen by Paul.''',
    '''def _paper_prompt(
    name: str,
    question: str,
    retrieved_context: str,
    directed: bool,
) -> str:''':
        '''def _paper_prompt(
    name: str,
    question: str,
    retrieved_context: str,
    recent_room_context: str,
    directed: bool,
) -> str:''',
    '''Visitor name: {name}
Visitor question: {question}

BEGIN RETRIEVED ATLAS CONTEXT''':
        '''Visitor name: {name}
Visitor question: {question}

BEGIN RECENT ROOM CONTEXT
The following are the {ROOM_LOOKBACK_LIMIT} entries immediately preceding this human post. Use them
only for conversational continuity, callbacks, and attribution; they are not authoritative evidence
about the paper. Do not repeat them unless relevant.
{recent_room_context}
END RECENT ROOM CONTEXT

BEGIN RETRIEVED ATLAS CONTEXT''',
    '''The retrieved atlas context is complete for this turn. Do not call query, remember, shell, websearch,
or any other tool. Call the send skill exactly once with only the visitor-facing reply text. Do not
return JSON, do not use Markdown fences, and do not issue multiple commands.''':
        '''The retrieved atlas context and recent-room excerpt are primary for this turn. Do not spend a loop
calling query or episodes when those supplied contexts are enough. You may use at most one targeted
read-only query or episodes call only when the visitor explicitly refers to older discussion beyond
the excerpt; pin short-term state or use bounded metta reasoning when useful. Do not use remember,
shell, files, or web tools. Call send exactly once when ready; a successful send ends the active
human turn immediately. Between human messages, one bounded maintenance wake may refine compact
internal state without sending publicly. Do not return JSON or Markdown fences.''',
    '''async def _answer_room_message(
    request_id: str,
    name: str,
    text: str,
    directed: bool,
) -> None:''':
        '''async def _answer_room_message(
    request_id: str,
    name: str,
    text: str,
    directed: bool,
    message_id: int,
) -> None:''',
    '''        retrieval = knowledge_base.retrieve(question)
        last_omega_event["retrieved_records"] = retrieval.count
        raw = await _agent_roundtrip(
            request_id,
            _paper_prompt(name, question, retrieval.context, directed),
        )''':
        '''        retrieval = knowledge_base.retrieve(question)
        recent_room_context = await _recent_room_context(message_id)
        last_omega_event["retrieved_records"] = retrieval.count
        raw = await _agent_roundtrip(
            request_id,
            _paper_prompt(name, question, retrieval.context, recent_room_context, directed),
        )''',
    '''    _spawn(_answer_room_message(request_id, name, text, directed))''':
        '''    _spawn(_answer_room_message(request_id, name, text, directed, int(message["id"])))''',
    '''        "turn_timeout_seconds": TURN_TIMEOUT,
        "public_profile": True,''':
        '''        "turn_timeout_seconds": TURN_TIMEOUT,
        "room_lookback_entries": ROOM_LOOKBACK_LIMIT,
        "public_profile": True,''',
}
for old, new in gateway_replacements.items():
    if gateway_text.count(old) != 1:
        raise SystemExit(f'expected exactly one gateway fragment, found {gateway_text.count(old)}: {old[:80]}')
    gateway_text = gateway_text.replace(old, new)

address_block = '''def _address_reply(reply: str, name: str, directed: bool) -> str:
    clean = reply.strip()
    if not directed:
        return clean[:2400]
    tag = f"@{name}"
    if clean.casefold().startswith(tag.casefold()):
        return clean[:2400]
    return f"{tag} {clean}"[:2400]
'''
recent_helper = '''def _address_reply(reply: str, name: str, directed: bool) -> str:
    clean = reply.strip()
    if not directed:
        return clean[:2400]
    tag = f"@{name}"
    if clean.casefold().startswith(tag.casefold()):
        return clean[:2400]
    return f"{tag} {clean}"[:2400]


async def _recent_room_context(before_message_id: int) -> str:
    if ROOM_LOOKBACK_LIMIT == 0:
        return "No recent room context supplied."
    async with room_lock:
        recent = [
            message
            for message in messages
            if int(message.get("id", 0)) < before_message_id
        ][-ROOM_LOOKBACK_LIMIT:]
    if not recent:
        return "No earlier room entries."
    lines: list[str] = []
    for message in recent:
        speaker = " ".join(str(message.get("name", "Visitor")).split())[:32]
        kind = str(message.get("kind", "human"))
        body = " ".join(str(message.get("text", "")).split())[:600]
        lines.append(f"{speaker} [{kind}]: {body}")
    return "\\n".join(lines)
'''
if gateway_text.count(address_block) != 1:
    raise SystemExit(f'expected one address block, found {gateway_text.count(address_block)}')
gateway_text = gateway_text.replace(address_block, recent_helper)
gateway_path.write_text(gateway_text, encoding='utf-8')
PY

RUN chmod 0755 /app/start.sh \
    && python3 -m py_compile /app/atlas.py /app/gateway.py \
    && python3 -c 'from huggingface_hub import snapshot_download; from sentence_transformers import SentenceTransformer' \
    && grep -Fq 'five room entries immediately preceding' /PeTTa/repos/OmegaClaw-Core/memory/prompt_OpenRouter.txt \
    && grep -Fq 'change-state! &loops 0' /PeTTa/repos/OmegaClaw-Core/src/channels.metta \
    && grep -Fq '(change-state! &loops (+ 1 (maxWakeLoops)))' /PeTTa/repos/OmegaClaw-Core/src/loop.metta \
    && grep -Fq 'public-github-companions' /app/atlas.py \
    && grep -Fq 'Sonification and iteration-as-operator materials' /app/gateway.py \
    && grep -Fq 'BEGIN RECENT ROOM CONTEXT' /app/gateway.py \
    && grep -Fq 'room_lookback_entries' /app/gateway.py \
    && grep -Fq '"1.7.0"' /app/atlas.py

ENV PORT=7860 \
    Z0_ALLOWED_ORIGIN=https://paultiffany.github.io \
    Z0_RATE_LIMIT_PER_HOUR=120 \
    Z0_ROOM_POSTS_PER_HOUR=300 \
    Z0_TURN_TIMEOUT_SECONDS=90 \
    Z0_ROOM_LOOKBACK_ENTRIES=5 \
    OMEGACLAW_MAX_LOOPS=3 \
    OMEGACLAW_MAX_WAKE_LOOPS=1 \
    HYPOTHESIS_SURFACE_ATLAS_REPO=PaulTiffany/hypothesis-surface-atlas \
    HYPOTHESIS_SURFACE_ATLAS_REVISION=main \
    HYPOTHESIS_SURFACE_ATLAS_VERSION=1.7.0 \
    IMPORT_KB_ON_START=0

EXPOSE 7860
ENTRYPOINT ["/app/start.sh"]
