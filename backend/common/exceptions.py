from rest_framework.views import exception_handler


def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)
    request = context.get('request')
    request_id = getattr(request, 'request_id', None)

    if response is not None:
        response.data = {
            'success': False,
            'data': None,
            'message': str(exc.detail) if hasattr(exc, 'detail') else 'An error occurred',
            'errors': response.data,
            'pagination': None,
            'request_id': request_id,
        }

    return response
