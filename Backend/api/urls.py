# api/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView

from .views import (
    MyTokenObtainPairView,
    RegisterView, # <-- NEW
    DocumentListView,
    DocumentDetailView,
    DocumentCreateView,
    DocumentSearchView,
    DocumentTTSView,
    DocumentPageView,
    AdminDocumentListView,
    DocumentContentView,
    # New ViewSets
    SuperUserViewSet,
    AdminViewSet,
    MarketplaceViewSet,
    DocumentRequestViewSet,
)

# Using a router for the new ViewSets is clean and efficient
router = DefaultRouter()
router.register(r'superuser', SuperUserViewSet, basename='superuser')
router.register(r'admin', AdminViewSet, basename='admin')
router.register(r'marketplace', MarketplaceViewSet, basename='marketplace')
router.register(r'requests', DocumentRequestViewSet, basename='documentrequest')

urlpatterns = [
    # Auth Endpoints
    path('token/', MyTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('register/', RegisterView.as_view(), name='auth_register'), # <-- NEW

    # Include the router URLs for the new ViewSets
    path('', include(router.urls)),

    # Keep your existing document endpoints
    path('documents/', DocumentListView.as_view(), name='document-list'),
    path('documents/<int:pk>/', DocumentDetailView.as_view(), name='document-detail'),
    path('documents/upload/', DocumentCreateView.as_view(), name='document-create'),
    path('documents/search/', DocumentSearchView.as_view(), name='document-search'),
    path('tts/<int:pk>/', DocumentTTSView.as_view(), name='document-tts'),
    path('documents/<int:pk>/page/<int:page_num>/', DocumentPageView.as_view(), name='document-page'),
    path('documents/<int:pk>/content/', DocumentContentView.as_view(), name='document-content'),
    path('admin/documents/', AdminDocumentListView.as_view(), name='admin-document-list'),
]