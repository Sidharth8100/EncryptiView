// lib/document_model.dart

import 'category_model.dart'; // This import is correct.

class Document {
  final int id;
  final String title;
  final String description;
  final String coverImageUrl;
  final Category? category;
  final String ownerUsername;
  final int pageCount;

  Document({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImageUrl,
    this.category,
    required this.ownerUsername,
    required this.pageCount,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['cover_image'] ?? '';
    // This logic should be here to prepend the base URL if the API returns a partial path
    if (!imageUrl.startsWith('http')) {
      // Example: imageUrl = 'http://10.0.2.2:8000' + imageUrl;
    }

    return Document(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      coverImageUrl: imageUrl,
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      ownerUsername: json['owner_username'] ?? 'Unknown Owner',
      pageCount: json['page_count'] ?? 0,
    );
  }
}
