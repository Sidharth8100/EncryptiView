// lib/document_viewer_screen.dart

import 'dart:io';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // For Material widget wrapper
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as p;
import 'package:docx_to_text/docx_to_text.dart';

import 'authenticated_image.dart';
import 'config.dart';
import 'accessibility_panel.dart';
import 'api_service.dart';
import 'document_model.dart'; // Uses the correct, single document model

class DocumentViewerScreen extends StatefulWidget {
  final Document? document;
  final String? localFilePath;

  const DocumentViewerScreen({super.key, this.document, this.localFilePath})
    : assert(document != null || localFilePath != null);

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  static const _channel = MethodChannel('com.encryptiview/secure_screen');
  final ApiService _apiService = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isTtsLoading = false;
  bool _isPlaying = false;
  bool _isDocumentLoading = true;
  String _documentTextContent = '';

  late final bool _isLocalMode;
  late final String _title;

  @override
  void initState() {
    super.initState();
    _isLocalMode = widget.localFilePath != null;
    _title =
        _isLocalMode
            ? p.basename(widget.localFilePath!)
            : widget.document!.title;

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        setState(() => _isPlaying = false);
      }
    });

    if (!_isLocalMode) {
      _channel.invokeMethod('secureScreen');
    }
    _loadDocumentContent();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    if (!_isLocalMode) {
      _channel.invokeMethod('unsecureScreen');
    }
    super.dispose();
  }

  Future<void> _loadDocumentContent() async {
    setState(() => _isDocumentLoading = true);
    try {
      if (_isLocalMode) {
        final filePath = widget.localFilePath!;
        if (filePath.toLowerCase().endsWith('.txt')) {
          _documentTextContent = await File(filePath).readAsString();
        } else if (filePath.toLowerCase().endsWith('.docx')) {
          final bytes = await File(filePath).readAsBytes();
          _documentTextContent = docxToText(bytes);
        }
      } else {
        _documentTextContent =
            widget.document?.extractedText ?? "No text content available.";
      }
    } catch (e) {
      _documentTextContent = "Error loading document: $e";
      if (mounted) _showErrorDialog("Could not load the document.");
    }
    setState(() => _isDocumentLoading = false);
  }

  Future<void> _handleTTS() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isTtsLoading = true);
    try {
      final audioData = await _apiService.getTTSAudio(widget.document!.id);
      if (audioData != null) {
        await _audioPlayer.play(BytesSource(audioData));
        setState(() => _isPlaying = true);
      } else {
        if (mounted)
          _showErrorDialog("Could not fetch audio for this document.");
      }
    } catch (e) {
      if (mounted) _showErrorDialog("An error occurred during Text-to-Speech.");
    }
    setState(() => _isTtsLoading = false);
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_title),
        trailing:
            _isLocalMode
                ? null
                : CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  child: const Icon(CupertinoIcons.ellipsis_vertical),
                ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _isDocumentLoading
              ? const CupertinoActivityIndicator(radius: 20)
              : _buildDocumentViewer(),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _buildBottomToolbar(),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentViewer() {
    String? filePath = widget.localFilePath;
    String fileUrl =
        _isLocalMode
            ? filePath!.toLowerCase()
            : widget.document!.fileUrl.toLowerCase();

    if (fileUrl.endsWith('.pdf')) {
      if (_isLocalMode) {
        // This part needs flutter_pdfview, make sure it's in your pubspec.yaml
        // return PDFView(filePath: filePath);
        return Center(
          child: Text(
            "Local PDF rendering is a placeholder. You would use a package like flutter_pdfview here.",
          ),
        );
      } else {
        // Your original, working cloud PDF viewer
        final doc = widget.document!;
        if (doc.pageCount <= 0)
          return const Center(
            child: Text("This PDF is empty or cannot be displayed."),
          );
        return PageView.builder(
          itemCount: doc.pageCount,
          itemBuilder: (context, index) {
            final pageNum = index + 1;
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final imageUrl =
                '${Config.baseUrl}/documents/${doc.id}/page/$pageNum/?v=$timestamp';
            return InteractiveViewer(
              child: AuthenticatedImage(imageUrl: imageUrl),
            );
          },
        );
      }
    } else if (fileUrl.endsWith('.txt') || fileUrl.endsWith('.docx')) {
      // This logic now works for BOTH local and cloud files
      return Material(
        // Using Material wrapper for better text selection, etc.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Text(_documentTextContent),
        ),
      );
    }
    return const Center(child: Text("Unsupported file format."));
  }

  Widget _buildBottomToolbar() {
    return Column(
      children: [
        const SizedBox(height: 16),
        // RESTORED: Your original "sexy" blurred toolbar
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.withOpacity(0.8),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: CupertinoColors.systemGrey4.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CupertinoButton(
                    onPressed: () {},
                    child: const Icon(
                      CupertinoIcons.goforward,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  if (!_isLocalMode)
                    CupertinoButton(
                      onPressed: _isTtsLoading ? null : _handleTTS,
                      child:
                          _isTtsLoading
                              ? const CupertinoActivityIndicator()
                              : Icon(
                                _isPlaying
                                    ? CupertinoIcons.pause_circle_fill
                                    : CupertinoIcons.play_circle_fill,
                                size: 40,
                                color: CupertinoColors.activeBlue,
                              ),
                    ),
                  CupertinoButton(
                    onPressed:
                        () => showCupertinoModalPopup(
                          context: context,
                          builder: (_) => const AccessibilityPanel(),
                        ),
                    child: const Icon(
                      CupertinoIcons.textformat_size,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
