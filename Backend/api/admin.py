from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, Document, UserProfile, Category, DocumentRequest

class UserAdmin(BaseUserAdmin):
    list_display = ('username', 'email', 'first_name', 'last_name', 'role', 'is_staff')
    fieldsets = BaseUserAdmin.fieldsets + (
        ('Custom Fields', {'fields': ('role',)}),
    )

class DocumentAdmin(admin.ModelAdmin):
    list_display = ('title', 'owner', 'uploaded_at')
    list_filter = ('owner', 'uploaded_at')
    search_fields = ('title', 'owner__username')

admin.site.register(User, UserAdmin)
admin.site.register(UserProfile)
admin.site.register(Category)
admin.site.register(Document, DocumentAdmin)
admin.site.register(DocumentRequest)