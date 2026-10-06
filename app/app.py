"""DevOps Playground app: a tiny website that shows its COLOR and VERSION,
exposes /health for health checks and /metrics for Prometheus."""
import os
import time

from flask import Flask, Response, jsonify
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

COLOR = os.getenv("COLOR", "blue")        # which slot this copy runs in (blue/green)
VERSION = os.getenv("VERSION", "v1")      # which release of the app this is

app = Flask(__name__)

REQUESTS = Counter("app_requests_total", "Total HTTP requests", ["path", "status"])
LATENCY = Histogram("app_request_seconds", "Request latency in seconds", ["path"])


def log(level, message):
    # Print to stdout: Docker collects stdout as the container's logs (Loki reads these).
    print(f"level={level} color={COLOR} version={VERSION} msg=\"{message}\"", flush=True)


@app.route("/")
def home():
    start = time.time()
    page = f"""<!doctype html><html><head><title>DevOps Playground v2</title></head>
<body style="font-family:Arial;background:{COLOR};color:white;text-align:center;padding-top:15vh">
<h1>DevOps Playground</h1>
<h2>Color: {COLOR.upper()} &middot; Version: {VERSION}</h2>
<p>Served by container: {os.getenv('HOSTNAME', 'local')}</p>
</body></html>"""
    REQUESTS.labels("/", "200").inc()
    LATENCY.labels("/").observe(time.time() - start)
    log("info", "home page served")
    return page


@app.route("/api")
def api():
    REQUESTS.labels("/api", "200").inc()
    return jsonify(color=COLOR, version=VERSION, host=os.getenv("HOSTNAME", "local"))


@app.route("/health")
def health():
    return jsonify(status="ok", color=COLOR, version=VERSION)


@app.route("/error")
def error():
    # Deliberately fails so you can practise alerts and log searches.
    REQUESTS.labels("/error", "500").inc()
    log("error", "something went wrong on purpose")
    return jsonify(error="simulated failure"), 500


@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
