# api/serializers.py

from rest_framework import serializers
from .models import Document, User, UserProfile, Category, DocumentRequest
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
import fitz

# UPDATED: Add role and approval status to the login token payload
class MyTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        data['username'] = self.user.username
        data['role'] = self.user.role
        # Add admin approval status to the payload
        if self.user.role == 'ADMIN':
            data['admin_approved'] = self.user.profile.admin_approved
        else:
            data['admin_approved'] = False # Viewers don't need approval
        return data

# NEW: Serializer for user registration
class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'password', 'role')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            role=validated_data['role']
        )
        # Create a UserProfile for the new user
        UserProfile.objects.create(user=user)
        return user

# NEW: UserProfile Serializer
class UserProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = UserProfile
        fields = ('id', 'user', 'username', 'email', 'admin_approved')

# NEW: Category Serializer
class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = '__all__'

# UPDATED: Document Serializer with new fields
class DocumentSerializer(serializers.ModelSerializer):
    page_count = serializers.SerializerMethodField()
    owner_username = serializers.CharField(source='owner.username', read_only=True)
    category = CategorySerializer(read_only=True) # Read-only for list views
    category_id = serializers.IntegerField(write_only=True) # Write-only for uploads

    class Meta:
        model = Document
        fields = [
            'id', 'title', 'description', 'file', 'cover_image',
            'category', 'category_id', 'owner', 'owner_username', 'allowed_viewers',
            'extracted_text', 'page_count', 'watermark_enabled'
        ]
        read_only_fields = ['owner', 'extracted_text', 'page_count', 'owner_username']

    def get_page_count(self, obj):
        # No changes needed here
        if obj.file and obj.file.name.lower().endswith('.pdf'):
            try:
                with obj.file.open('rb') as f:
                    doc = fitz.open(stream=f.read(), filetype="pdf")
                    count = doc.page_count
                    doc.close()
                    return count
            except Exception:
                return 0
        return 1 # for non-pdf files

# NEW: DocumentRequest Serializer
class DocumentRequestSerializer(serializers.ModelSerializer):
    document = DocumentSerializer(read_only=True)
    requester_username = serializers.CharField(source='requester.username', read_only=True)

    class Meta:
        model = DocumentRequest
        fields = '__all__'