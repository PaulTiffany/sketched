FROM singularitynet/omegaclaw:latest

USER root

# The official OmegaClaw runtime image includes Python but omits pip.
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip install --no-cache-dir --break-system-packages \
        fastapi==0.116.1 \
        "uvicorn[standard]==0.35.0" \
        huggingface_hub==1.24.0

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
    HYPOTHESIS_SURFACE_ATLAS_REPO=PaulTiffany/hypothesis-surface-atlas \
    HYPOTHESIS_SURFACE_ATLAS_REVISION=main \
    HYPOTHESIS_SURFACE_ATLAS_VERSION=1.4.1 \
    IMPORT_KB_ON_START=0

EXPOSE 7860
ENTRYPOINT ["/app/start.sh"]