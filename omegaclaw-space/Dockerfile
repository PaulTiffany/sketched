FROM singularitynet/omegaclaw:latest

USER root

# The official OmegaClaw image includes Python but not pip. Install the
# distro-provided pip first, then add only the small HTTP/WebSocket gateway.
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip install --no-cache-dir --break-system-packages \
        fastapi==0.116.1 \
        "uvicorn[standard]==0.35.0"

WORKDIR /app
COPY gateway.py /app/gateway.py
COPY start.sh /app/start.sh
RUN chmod 0755 /app/start.sh

ENV PORT=7860 \
    Z0_ALLOWED_ORIGIN=https://paultiffany.github.io \
    Z0_RATE_LIMIT_PER_HOUR=12 \
    IMPORT_KB_ON_START=0

EXPOSE 7860
ENTRYPOINT ["/app/start.sh"]
