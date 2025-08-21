# api/views.py

import io
from django.db.models import Q, Count
from django.http import HttpResponse, JsonResponse
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import generics, viewsets, status, parsers
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from gtts import gTTS
import fitz
import docx

# Import all models and serializers
from .models import Document, UserProfile, Category, DocumentRequest, User
from .serializers import (
    DocumentSerializer, MyTokenObtainPairSerializer, RegisterSerializer,
    UserProfileSerializer, CategorySerializer, DocumentRequestSerializer
)
# THE FIX: This single, clean import list contains ALL necessary permissions.
from .permissions import IsOwnerOrAllowedViewer, IsSuperUser, IsApprovedAdmin, IsOwnerOrSuperUser

# --- Authentication and Registration ---
# This RegisterView was missing from your file but is needed for the registration feature.
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = RegisterSerializer

class MyTokenObtainPairView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer

# --- New Feature ViewSets ---
class SuperUserViewSet(viewsets.ViewSet):
    permission_classes = [IsSuperUser]
    @action(detail=False, methods=['get'], url_path='admin-requests')
    def admin_requests(self, request):
        unapproved_profiles = UserProfile.objects.filter(user__role='ADMIN', admin_approved=False)
        serializer = UserProfileSerializer(unapproved_profiles, many=True)
        return Response(serializer.data)
    @action(detail=True, methods=['post'], url_path='approve-admin')
    def approve_admin(self, request, pk=None):
        profile = get_object_or_404(UserProfile, pk=pk)
        profile.admin_approved = True
        profile.save()
        return Response({'status': 'Admin approved successfully'}, status=status.HTTP_200_OK)
    @action(detail=True, methods=['post'], url_path='revoke-admin')
    def revoke_admin(self, request, pk=None):
        profile = get_object_or_404(UserProfile, pk=pk)
        profile.admin_approved = False
        profile.save()
        return Response({'status': 'Admin status revoked'}, status=status.HTTP_200_OK)

class AdminViewSet(viewsets.ModelViewSet):
    serializer_class = DocumentSerializer
    permission_classes = [IsApprovedAdmin]
    parser_classes = [parsers.MultiPartParser, parsers.FormParser]
    def get_queryset(self):
        return Document.objects.filter(owner=self.request.user)
    def perform_create(self, serializer):
        category = get_object_or_404(Category, id=self.request.data.get('category_id'))
        serializer.save(owner=self.request.user, category=category)
    @action(detail=True, methods=['get'])
    def requests(self, request, pk=None):
        document = self.get_object()
        requests = document.requests.all().order_by('-requested_at')
        serializer = DocumentRequestSerializer(requests, many=True)
        return Response(serializer.data)

class MarketplaceViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = DocumentSerializer
    permission_classes = [IsAuthenticated]
    def get_queryset(self):
        queryset = Document.objects.annotate(request_count=Count('requests')).order_by('-request_count')
        category_id = self.request.query_params.get('category')
        if category_id:
            queryset = queryset.filter(category__id=category_id)
        return queryset

class DocumentRequestViewSet(viewsets.ModelViewSet):
    serializer_class = DocumentRequestSerializer
    permission_classes = [IsAuthenticated]
    def get_queryset(self):
        return DocumentRequest.objects.filter(requester=self.request.user)
    def perform_create(self, serializer):
        document_id = self.request.data.get('document_id')
        document = get_object_or_404(Document, id=document_id)
        serializer.save(requester=self.request.user, document=document)
    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        doc_request = get_object_or_404(DocumentRequest, pk=pk)
        if doc_request.document.owner == request.user or request.user.is_superuser:
            doc_request.status = DocumentRequest.RequestStatus.APPROVED
            doc_request.document.allowed_viewers.add(doc_request.requester)
            doc_request.save()
            return Response({'status': 'Request approved'})
        return Response({'error': 'Not authorized'}, status=status.HTTP_403_FORBIDDEN)
    @action(detail=True, methods=['post'])
    def deny(self, request, pk=None):
        doc_request = get_object_or_404(DocumentRequest, pk=pk)
        if doc_request.document.owner == request.user or request.user.is_superuser:
            doc_request.status = DocumentRequest.RequestStatus.DENIED
            doc_request.save()
            return Response({'status': 'Request denied'})
        return Response({'error': 'Not authorized'}, status=status.HTTP_403_FORBIDDEN)

# --- ALL YOUR ORIGINAL VIEWS ARE PRESERVED BELOW ---

class DocumentPageView(APIView):
    permission_classes = [IsAuthenticated, IsOwnerOrAllowedViewer]
    def get(self, request, pk, page_num):
        document = get_object_or_404(Document.objects.all(), pk=pk)
        self.check_object_permissions(request, document)
        if not document.file or not document.file.name.lower().endswith('.pdf'):
            return HttpResponse("This document is not a viewable PDF.", status=400)
        try:
            with document.file.open('rb') as f:
                doc = fitz.open(stream=f.read(), filetype="pdf")
                if page_num > doc.page_count or page_num <= 0:
                    doc.close()
                    return HttpResponse("Page not found.", status=404)
                page = doc.load_page(page_num - 1)
                if document.watermark_enabled:
                    user_instance = User.objects.get(id=request.user.id)
                    text = f"Viewed by: {user_instance.email} on {timezone.now().strftime('%Y-%m-%d %H:%M')}"
                    rect = fitz.Rect(50, page.rect.height - 50, page.rect.width - 50, page.rect.height - 20)
                    page.insert_textbox(rect, text, fontsize=8, color=(0.5, 0.5, 0.5), align=fitz.TEXT_ALIGN_LEFT)
                pix = page.get_pixmap(dpi=150)
                doc.close()
                img_data = pix.tobytes("png")
                return HttpResponse(img_data, content_type='image/png')
        except Exception as e:
            return HttpResponse(f"Error processing page with PyMuPDF: {e}", status=500)

class DocumentListView(generics.ListAPIView):
    serializer_class = DocumentSerializer
    permission_classes = [IsAuthenticated]
    def get_queryset(self):
        user = self.request.user
        return Document.objects.filter(Q(owner=user) | Q(allowed_viewers=user)).distinct()

class DocumentDetailView(generics.RetrieveAPIView):
    serializer_class = DocumentSerializer
    permission_classes = [IsAuthenticated, IsOwnerOrAllowedViewer]
    queryset = Document.objects.all()

class DocumentCreateView(generics.CreateAPIView):
    serializer_class = DocumentSerializer
    permission_classes = [IsAuthenticated]
    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

class DocumentSearchView(generics.ListAPIView):
    serializer_class = DocumentSerializer
    permission_classes = [IsAuthenticated]
    def get_queryset(self):
        user = self.request.user
        allowed_documents = Document.objects.filter(Q(owner=user) | Q(allowed_viewers=user)).distinct()
        query = self.request.query_params.get('q', None)
        if query:
            return allowed_documents.filter(extracted_text__icontains=query)
        return Document.objects.none()

class DocumentTTSView(APIView):
    permission_classes = [IsAuthenticated, IsOwnerOrAllowedViewer]
    def get(self, request, pk):
        document = get_object_or_404(Document.objects.all(), pk=pk)
        self.check_object_permissions(request, document)
        if not document.extracted_text:
            return HttpResponse("No text content available to convert.", status=404)
        try:
            tts = gTTS(document.extracted_text, lang='en')
            mp3_fp = io.BytesIO()
            tts.write_to_fp(mp3_fp)
            mp3_fp.seek(0)
            response = HttpResponse(mp3_fp, content_type='audio/mpeg')
            response['Content-Disposition'] = f'attachment; filename="{document.title}.mp3"'
            return response
        except Exception as e:
            return HttpResponse(f"Error during TTS conversion: {e}", status=500)

class DocumentContentView(APIView):
    permission_classes = [IsAuthenticated, IsOwnerOrAllowedViewer]
    def get(self, request, pk):
        document = get_object_or_404(Document.objects.all(), pk=pk)
        self.check_object_permissions(request, document)
        if not document.file:
            return JsonResponse({'error': 'File not found.'}, status=404)
        file_path = document.file.path
        content = ""
        try:
            if file_path.lower().endswith('.txt'):
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
            elif file_path.lower().endswith('.docx'):
                doc = docx.Document(file_path)
                full_text = [para.text for para in doc.paragraphs]
                content = '\n'.join(full_text)
            else:
                return JsonResponse({'error': 'Unsupported file type for content view.'}, status=400)
            return JsonResponse({'content': content})
        except Exception as e:
            return JsonResponse({'error': f'Error reading file: {e}'}, status=500)

class AdminDocumentListView(generics.ListAPIView):
    queryset = Document.objects.all().order_by('-uploaded_at')
    serializer_class = DocumentSerializer
    # This should use IsApprovedAdmin for consistency with the new features
    permission_classes = [IsApprovedAdmin]