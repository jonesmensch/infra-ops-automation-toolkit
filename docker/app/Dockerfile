FROM python:3.12-slim

WORKDIR /app
COPY healthz_server.sh /app/healthz_server.sh

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080').read()" || exit 1

CMD ["/app/healthz_server.sh"]
