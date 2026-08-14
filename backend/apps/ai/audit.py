"""Audit helper for AI service calls (Sprint C7).

Fire-and-forget writes to `AIPredictionJob` so every heavy prediction is
retrievable by job id (task, input, output, model_version, error) without
blocking the request path.
"""
from .tasks import log_ai_prediction


def audit_ai_call(
    task: str,
    input_data: dict | None = None,
    output_data: dict | None = None,
    error_message: str = '',
    model_version: str = '',
):
    try:
        log_ai_prediction.delay(
            task=task,
            input_data=input_data,
            output_data=output_data,
            error_message=error_message,
            model_version=model_version,
        )
    except Exception:  # noqa: BLE001
        pass
