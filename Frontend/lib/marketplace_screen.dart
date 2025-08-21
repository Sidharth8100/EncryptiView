// lib/marketplace_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'api_service.dart';
import 'document_model.dart';
import 'marketplace_detail_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Document>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _documentsFuture = _apiService.getMarketplaceDocuments();
  }

  Future<void> _refreshDocuments() async {
    setState(() {
      _documentsFuture = _apiService.getMarketplaceDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Marketplace')),
      child: FutureBuilder<List<Document>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator(radius: 15));
          }
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No documents found in the marketplace.'),
            );
          }

          final documents = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshDocuments,
            child: GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => MarketplaceDetailScreen(document: doc),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: GridTile(
                      footer: GridTileBar(
                        backgroundColor: Colors.black45,
                        title: Text(
                          doc.title,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          doc.ownerUsername,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      child: Image.network(
                        doc.coverImageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder:
                            (context, child, progress) =>
                                progress == null
                                    ? child
                                    : const Center(
                                      child: CupertinoActivityIndicator(),
                                    ),
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: CupertinoColors.systemGrey5,
                              child: const Icon(
                                CupertinoIcons.photo,
                                size: 50,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
