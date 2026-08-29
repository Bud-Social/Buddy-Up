#!/usr/bin/env python
"""Check representative route resolution and the documented response contract."""

import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "backend"))
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.development")

import django

django.setup()

from django.test import Client
from django.urls import resolve


FIXTURE = ROOT / "contracts" / "api_contract.json"


def assert_envelope(payload, required_keys):
    missing = set(required_keys) - set(payload)
    assert not missing, f"standard response missing keys: {sorted(missing)}"


def main():
    contract = json.loads(FIXTURE.read_text())
    required_keys = contract["envelope"]["required_keys"]

    for client, paths in contract["client_evidence"].items():
        for path in paths:
            assert (ROOT / path).is_file(), f"{client} evidence file is missing: {path}"

    for route in contract["routes"]:
        try:
            match = resolve(route["path"])
        except Exception as exc:  # noqa: BLE001
            raise AssertionError(f"route does not resolve: {route['path']}") from exc
        assert match.func, f"route has no callable view: {route['path']}"

    client = Client()
    login_response = client.post("/api/v1/auth/login/", data={}, content_type="application/json")
    assert login_response.status_code == 400, login_response.status_code
    assert_envelope(login_response.json(), required_keys)

    health_response = client.get("/api/v1/health/")
    health_payload = health_response.json()
    assert health_response.status_code in (200, 503), health_response.status_code
    assert {"status", "service", "checks"} <= set(health_payload)

    print(f"API contract valid: {len(contract['routes'])} routes, envelope and readiness checks passed")


if __name__ == "__main__":
    main()
