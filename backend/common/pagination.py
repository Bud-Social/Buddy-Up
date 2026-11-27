from rest_framework.pagination import CursorPagination as DRCursorPagination
from rest_framework.pagination import PageNumberPagination


class CursorPagination(DRCursorPagination):
    """Cursor pagination that follows the queryset's own ordering.

    DRF's cursor paginator uses ``ordering`` from the pagination class and
    ignores the queryset order. That silently reordered endpoints which sort
    by username, scheduled time, or pinned-first (profiles, lives,
    notifications). This subclass derives the cursor ordering from the
    queryset instead, falling back to ``-created_at`` only when the queryset
    has no explicit ordering.

    A ``-pk`` tiebreaker is appended when the ordering does not already
    include a unique column, so equal timestamps cannot skip or duplicate
    rows while paging.
    """

    page_size = 20
    page_size_query_param = 'limit'
    ordering = '-created_at'

    def get_ordering(self, request, queryset, view):
        view_ordering = getattr(view, 'ordering', None)
        if view_ordering:
            raw = view_ordering
        else:
            raw = queryset.query.order_by or ()

        ordering = []
        for term in raw:
            parsed = self._parse_term(term)
            if parsed is None:
                # An expression the cursor encoder cannot represent (for
                # example ``F(...).desc(nulls_last=True)``). Fall back to the
                # model's timestamp rather than returning a broken cursor.
                return self._fallback_ordering(queryset)
            ordering.append(parsed)

        if not ordering:
            return self._fallback_ordering(queryset)

        if not any(term.lstrip('-') in ('pk', 'id') for term in ordering):
            ordering.append('-pk')
        return tuple(ordering)

    def _parse_term(self, term):
        if isinstance(term, str):
            return term
        expression = getattr(term, 'expression', None)
        name = getattr(expression, 'name', None)
        if not name:
            return None
        descending = getattr(term, 'descending', False)
        return f'-{name}' if descending else name

    def _fallback_ordering(self, queryset):
        try:
            queryset.model._meta.get_field('created_at')
        except Exception:  # noqa: BLE001 - any model without a timestamp
            return ('-pk',)
        return ('-created_at', '-pk')


class PageNumberPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = 'limit'
    max_page_size = 100
