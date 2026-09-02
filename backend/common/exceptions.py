from rest_framework.views import exception_handler


def _human_message(detail):
    """Extract a single human-readable sentence from DRF error structures.

    Field-error dicts like ``{'email': ['An account with this email already
    exists.']}`` previously stringified into developer JSON. Walk the
    structure and return the first real message.
    """
    if isinstance(detail, str):
        return detail
    if isinstance(detail, (list, tuple)):
        for item in detail:
            message = _human_message(item)
            if message:
                return message
        return ''
    if isinstance(detail, dict):
        # Prefer common keys first, then any value.
        for key in ('detail', 'message', 'error'):
            if key in detail:
                message = _human_message(detail[key])
                if message:
                    return message
        for value in detail.values():
            message = _human_message(value)
            if message:
                return message
    return ''


def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)
    request = context.get('request')
    request_id = getattr(request, 'request_id', None)

    if response is not None:
        detail = getattr(exc, 'detail', None)
        message = _human_message(detail) or 'An error occurred'
        # Throttled exceptions carry a wait period — surface it.
        wait = getattr(detail, 'wait', None)
        if wait:
            message = f'{message} Please try again in {int(wait) + 1} seconds.'
        response.data = {
            'success': False,
            'data': None,
            'message': message,
            'errors': response.data,
            'pagination': None,
            'request_id': request_id,
        }

    return response
