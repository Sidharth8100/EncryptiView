// lib/admin_document_list_tab.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'api_service.dart';
// THE FIX: This now points to the correct file.
import 'document_model.dart';

class AdminDocumentListTab extends StatefulWidget {
  const AdminDocumentListTab({super.key});

  @override
  State<AdminDocumentListTab> createState() => _AdminDocumentListTabState();
}

class _AdminDocumentListTabState extends State<AdminDocumentListTab> {
  final ApiService _apiService = ApiService();
  late Future<List<Document>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _documentsFuture = _apiService.getAdminDocuments();
  }

  Future<void> _refresh() async {
    setState(() {
      _documentsFuture = _apiService.getAdminDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Document>>(
      future: _documentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('You have not uploaded any documents.'),
          );
        }
        final documents = snapshot.data!;
        return Material(
          color: CupertinoColors.systemGroupedBackground,
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                return CupertinoListTile.notched(
                  title: Text(
                    doc.title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Category: ${doc.category?.name ?? "Uncategorized"}',
                  ),
                  leading: const Icon(
                    CupertinoIcons.doc_text_fill,
                    color: CupertinoColors.systemGrey,
                  ),
                  onTap: () {},
                );
              },
            ),
          ),
        );
      },
    );
  }
}
