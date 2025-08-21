// lib/authenticated_image.dart

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';

class AuthenticatedImage extends StatefulWidget {
  final String imageUrl;

  const AuthenticatedImage({super.key, required this.imageUrl});

  @override
  State<AuthenticatedImage> createState() => _AuthenticatedImageState();
}

class _AuthenticatedImageState extends State<AuthenticatedImage> {
  final SecureStorageService _storage = SecureStorageService();
  late Future<http.Response> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _fetchImage();
  }

  Future<http.Response> _fetchImage() async {
    final token = await _storage.getAccessToken();
    return http.get(
      Uri.parse(widget.imageUrl),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<http.Response>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (snapshot.hasError || snapshot.data?.statusCode != 200) {
          return const Center(
            child: Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: CupertinoColors.systemRed,
            ),
          );
        }
        if (snapshot.hasData) {
          return Image.memory(snapshot.data!.bodyBytes);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
