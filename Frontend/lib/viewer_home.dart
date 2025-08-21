// lib/viewer_home.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // This import is necessary for RefreshIndicator

import 'api_service.dart';
// THE FIX: Changed this import to point to the correct model file.
import 'document_model.dart';
import 'document_viewer_screen.dart';
import 'login_screen.dart';
import 'secure_storage_service.dart';

class ViewerHome extends StatefulWidget {
  const ViewerHome({super.key});

  @override
  State<ViewerHome> createState() => _ViewerHomeState();
}

class _ViewerHomeState extends State<ViewerHome> {
  final ApiService _apiService = ApiService();
  final SecureStorageService _storage = SecureStorageService();
  late Future<List<Document>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    // We re-assign the future here to allow the FutureBuilder to rebuild
    setState(() {
      // THE FIX: Changed this to call the correct, existing method.
      _documentsFuture = _apiService.getMarketplaceDocuments();
    });
  }

  Future<void> _logout() async {
    await _storage.deleteAll();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        CupertinoPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Marketplace'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _logout,
          child: const Text('Logout'),
        ),
      ),
      child: FutureBuilder<List<Document>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No documents available."));
          }

          return Material(
            type: MaterialType.transparency,
            child: RefreshIndicator.adaptive(
              onRefresh: _fetchDocuments,
              child: _buildDocumentList(snapshot.data!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentList(List<Document> documents) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final document = documents[index];
        return CupertinoListTile.notched(
          title: Text(document.title),
          // THE FIX: Changed 'owner_username' to the correct 'ownerUsername'
          subtitle: Text('By ${document.ownerUsername}'),
          leading: const Icon(
            CupertinoIcons.doc_text_fill,
            color: CupertinoColors.activeBlue,
          ),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => DocumentViewerScreen(document: document),
              ),
            );
          },
        );
      },
    );
  }
}
