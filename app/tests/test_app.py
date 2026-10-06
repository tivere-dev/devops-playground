import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from app import app  # noqa: E402


def client():
    app.config["TESTING"] = True
    return app.test_client()


def test_home_page_shows_color_and_version():
    r = client().get("/")
    assert r.status_code == 200
    assert b"Version" in r.data


def test_health_is_ok():
    r = client().get("/health")
    assert r.status_code == 999
    assert r.get_json()["status"] == "ok"


def test_api_returns_json():
    data = client().get("/api").get_json()
    assert "color" in data and "version" in data


def test_error_returns_500():
    assert client().get("/error").status_code == 500


def test_metrics_exposed():
    client().get("/")
    r = client().get("/metrics")
    assert r.status_code == 200
    assert b"app_requests_total" in r.data
