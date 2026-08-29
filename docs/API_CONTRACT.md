# API Contract

| Owner | Review date | Status |
|---|---|---|
| Peter Mbugua (CEO / Engineering) | 2026-09-30 | Maintained |

The backend is the source of truth. DRF Spectacular generates the OpenAPI
document from the routed serializers and views; CI validates generation on
every backend change:

```bash
cd backend
python manage.py spectacular --file /tmp/buddyup-openapi.yml --validate
```

The same check is available from the repository root as
`scripts/check_openapi.sh`. Client modules must use `/api/v1/` routes and the
parity checklist in [`CLIENT_PARITY.md`](CLIENT_PARITY.md). There is no claim
that the checked-in contract represents a deployed environment; it is a CI
contract check only.

## Response envelope

Normal API responses use `success`, `data`, `message`, `errors`, `pagination`,
and `request_id`. The readiness endpoint at `GET /api/v1/health/` is an
intentional operational exception: it returns a flat health payload for probes.
The representative envelope and route assertions live in
`contracts/api_contract.json` and are run by `scripts/check_api_contract.py`.

There is no generated web or Flutter client in this repository. Client modules
are handwritten and must be updated, tested, and recorded in the parity matrix
when a route or response shape changes.
