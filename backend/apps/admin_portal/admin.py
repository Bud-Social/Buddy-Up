"""No models to register.

The admin portal owns no tables of its own. The models it exposes (users,
shops, orders, gyms, conversations, logistics, ledger) are registered with
their owning app's admin site — see apps/marketplace/admin.py and
apps/messaging/admin.py.
"""
