"""No models.

The admin portal is a read/act surface over models that already exist
(accounts, profiles, marketplace, gyms, messaging, wallet). Everything it does
happens through the owning apps' models and serializers, so nothing is stored
here and there is no migration to run.

``migrations/`` exists only so ``makemigrations`` treats this app as migrated.
"""
