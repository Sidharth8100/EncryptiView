// lib/marketplace_detail_screen.dart

import 'package:flutter/cupertino.dart';
import 'api_service.dart';
import 'document_model.dart';

class MarketplaceDetailScreen extends StatelessWidget {
  final Document document;
  final ApiService _apiService = ApiService();

  MarketplaceDetailScreen({super.key, required this.document});

  void _requestAccess(BuildContext context) async {
    try {
      await _apiService.createDocumentRequest(document.id);
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text('Request Sent'),
              content: const Text(
                'The document owner has been notified. You will get access as soon as possible.',
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text('Could not send request: ${e.toString()}'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(document.title)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(document.coverImageUrl),
              ),
              const SizedBox(height: 16),
              Text(
                document.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'By ${document.ownerUsername}',
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
              if (document.category != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      '#${document.category!.name}',
                      style: const TextStyle(color: CupertinoColors.activeBlue),
                    ),
                    onPressed: () {
                      /* TODO: Navigate to category search */
                    },
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(document.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () => _requestAccess(context),
                  child: const Text('Request Access'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
