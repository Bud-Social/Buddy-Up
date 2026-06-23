from rest_framework.pagination import CursorPagination as DRCursorPagination
from rest_framework.pagination import PageNumberPagination


class CursorPagination(DRCursorPagination):
    page_size = 20
    page_size_query_param = 'limit'
    ordering = '-created_at'


class PageNumberPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = 'limit'
    max_page_size = 100
