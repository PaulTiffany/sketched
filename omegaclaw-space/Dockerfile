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
# Hypothesis Surface Atlas v1.5.0. Source replacements are asserted so drift
# fails the image build instead of silently weakening the deployment.
RUN python3 - <<'PY'
from pathlib import Path

atlas_path = Path('/app/atlas.py')
atlas_text = atlas_path.read_text(encoding='utf-8')
atlas_replacements = {
    'expected_version=os.getenv("HYPOTHESIS_SURFACE_ATLAS_VERSION", "1.4.1")':
        'expected_version=os.getenv("HYPOTHESIS_SURFACE_ATLAS_VERSION", "1.5.0")',
    '''        tokens = set(query_tokens)
        if tokens & {"email", "contact", "orcid", "linkedin", "github"}:''':
        '''        tokens = set(query_tokens)
        if tokens & {"example", "worked", "concrete", "calculate", "numeric", "practice", "walkthrough"}:
            if record.source_kind == "worked-examples":
                score += 24.0
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
    'app = FastAPI(title="AGI-26 OmegaClaw Room", version="0.3.2")':
        'app = FastAPI(title="AGI-26 OmegaClaw Room", version="0.4.2")',
    'Every human post gives you one bounded turn;':
        'Every human post grants up to three bounded deliberation loops;',
    '''record with general model knowledge. If the records do not support a confident answer, say so.''':
        '''record with general model knowledge. If the records do not support a confident answer, say so.

Worked-example records are pedagogical. Preserve their status and boundaries. Never present a
synthetic illustrative scenario as an experiment performed in the Springer paper. A
worked_interpretation_of_reported_result may explain reported numbers but does not add new evidence.''',
    '''The retrieved atlas context is complete for this turn. Do not call query, remember, shell, websearch,
or any other tool. Call the send skill exactly once with only the visitor-facing reply text. Do not
return JSON, do not use Markdown fences, and do not issue multiple commands.''':
        '''The retrieved atlas context is primary for this turn. You may use at most one read-only query or
episodes call when prior room context materially matters, pin short-term state, or use bounded metta
reasoning. Do not use remember, shell, files, or web tools. Call send exactly once when ready; a
successful send ends the active human turn immediately. Between human messages, one bounded
maintenance wake may refine compact internal state without sending publicly. Do not return JSON or Markdown fences.''',
}
for old, new in gateway_replacements.items():
    if gateway_text.count(old) != 1:
        raise SystemExit(f'expected exactly one gateway fragment, found {gateway_text.count(old)}: {old[:80]}')
    gateway_text = gateway_text.replace(old, new)
gateway_path.write_text(gateway_text, encoding='utf-8')
PY

RUN chmod 0755 /app/start.sh \
    && python3 -m py_compile /app/atlas.py /app/gateway.py \
    && python3 -c 'from huggingface_hub import snapshot_download; from sentence_transformers import SentenceTransformer' \
    && grep -Fq 'one periodic maintenance wake is allowed' /PeTTa/repos/OmegaClaw-Core/memory/prompt_OpenRouter.txt \
    && grep -Fq 'change-state! &loops 0' /PeTTa/repos/OmegaClaw-Core/src/channels.metta \
    && grep -Fq '(change-state! &loops (+ 1 (maxWakeLoops)))' /PeTTa/repos/OmegaClaw-Core/src/loop.metta \
    && grep -Fq 'worked-examples' /app/atlas.py \
    && grep -Fq 'synthetic illustrative scenario' /app/gateway.py \
    && grep -Fq '"1.5.0"' /app/atlas.py

ENV PORT=7860 \
    Z0_ALLOWED_ORIGIN=https://paultiffany.github.io \
    Z0_RATE_LIMIT_PER_HOUR=120 \
    Z0_ROOM_POSTS_PER_HOUR=300 \
    Z0_TURN_TIMEOUT_SECONDS=90 \
    OMEGACLAW_MAX_LOOPS=3 \
    OMEGACLAW_MAX_WAKE_LOOPS=1 \
    HYPOTHESIS_SURFACE_ATLAS_REPO=PaulTiffany/hypothesis-surface-atlas \
    HYPOTHESIS_SURFACE_ATLAS_REVISION=main \
    HYPOTHESIS_SURFACE_ATLAS_VERSION=1.5.0 \
    IMPORT_KB_ON_START=0

EXPOSE 7860
ENTRYPOINT ["/app/start.sh"]
