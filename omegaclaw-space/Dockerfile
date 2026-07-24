FROM singularitynet/omegaclaw:latest

USER root

# The official OmegaClaw runtime image includes Python but omits pip.
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip install --no-cache-dir --break-system-packages \
        fastapi==0.116.1 \
        "uvicorn[standard]==0.35.0" \
        huggingface_hub==1.1.7

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

# Upstream currently schedules one provider call even when maxWakeLoops=0.
# Remove that implicit +1 so the public room stays human-triggered. Fail the
# image build if the upstream source changes and the patch no longer applies.
RUN python3 - <<'PY'
from pathlib import Path

path = Path('/PeTTa/repos/OmegaClaw-Core/src/loop.metta')
text = path.read_text(encoding='utf-8')
old = '(change-state! &loops (+ 1 (maxWakeLoops)))'
new = '(change-state! &loops (maxWakeLoops))'
if text.count(old) != 1:
    raise SystemExit(f'expected exactly one upstream wake-loop expression, found {text.count(old)}')
path.write_text(text.replace(old, new), encoding='utf-8')
patched = path.read_text(encoding='utf-8')
if old in patched or patched.count(new) != 1:
    raise SystemExit('OmegaClaw wake-loop patch verification failed')
PY

WORKDIR /app
COPY atlas.py /app/atlas.py
COPY gateway.py /app/gateway.py
COPY start.sh /app/start.sh
RUN chmod 0755 /app/start.sh \
    && python3 -m py_compile /app/atlas.py /app/gateway.py

ENV PORT=7860 \
    Z0_ALLOWED_ORIGIN=https://paultiffany.github.io \
    Z0_RATE_LIMIT_PER_HOUR=120 \
    Z0_ROOM_POSTS_PER_HOUR=300 \
    Z0_TURN_TIMEOUT_SECONDS=60 \
    OMEGACLAW_MAX_LOOPS=1 \
    OMEGACLAW_MAX_WAKE_LOOPS=0 \
    HYPOTHESIS_SURFACE_ATLAS_REPO=PaulTiffany/hypothesis-surface-atlas \
    HYPOTHESIS_SURFACE_ATLAS_REVISION=main \
    HYPOTHESIS_SURFACE_ATLAS_VERSION=1.4.1 \
    IMPORT_KB_ON_START=0

EXPOSE 7860
ENTRYPOINT ["/app/start.sh"]
