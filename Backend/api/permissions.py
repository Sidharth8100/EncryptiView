# api/permissions.py

from rest_framework import permissions

# --- THIS IS THE PERMISSION CLASS THAT WAS MISSING ---
class IsOwnerOrAllowedViewer(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object or users explicitly
    added to the 'allowed_viewers' list to see the object.
    """
    def has_object_permission(self, request, view, obj):
        # The object 'obj' is the Document instance.
        # This checks if the request.user is the owner OR if they exist in the M2M field.
        return obj.owner == request.user or request.user in obj.allowed_viewers.all()
# ---------------------------------------------------------

class IsSuperUser(permissions.BasePermission):
    """
    Allows access only to superusers.
    """
    def has_permission(self, request, view):
        return request.user and request.user.is_superuser

class IsApprovedAdmin(permissions.BasePermission):
    """
    Allows access only to users with the ADMIN role who have been approved by a superuser.
    """
    def has_permission(self, request, view):
        return (
            request.user and
            request.user.is_authenticated and
            request.user.role == 'ADMIN' and
            hasattr(request.user, 'profile') and
            request.user.profile.admin_approved
        )

class IsOwnerOrSuperUser(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object or superusers to edit it.
    """
    def has_object_permission(self, request, view, obj):
        return obj.owner == request.user or request.user.is_superuser