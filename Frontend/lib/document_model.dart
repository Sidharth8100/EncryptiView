// lib/document_model.dart

import 'category_model.dart';

class Document {
  final int id;
  final String title;
  final String description;
  final String coverImageUrl;
  final String fileUrl;
  final String? extractedText;
  final Category? category;
  final String ownerUsername;
  final int pageCount;

  Document({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    required this.fileUrl,
    this.extractedText,
    this.category,
    required this.ownerUsername,
    required this.pageCount,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      coverImageUrl: json['cover_image'] ?? '',
      fileUrl: json['file'] ?? '',
      extractedText: json['extracted_text'],
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      ownerUsername: json['owner_username'] ?? 'Unknown Owner',
      pageCount: json['page_count'] ?? 0,
    );
  }
}
