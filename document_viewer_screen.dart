import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'accessibility_panel.dart'; // Import the accessibility panel

class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({super.key});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  int _currentPage = 0;
  final int _totalPages = 20;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    // TODO: On Android, use flutter_windowmanager to prevent screenshots.
    // await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

    return CupertinoPageScaffold(
      // 1. Navigation Bar
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Project Titan_NDA.docx"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            /* TODO: Show CupertinoActionSheet for Settings/Logout */
          },
          child: const Icon(CupertinoIcons.ellipsis_vertical),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 2. Document Page View using PageView.builder
          PageView.builder(
            itemCount: _totalPages,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  120,
                ), // Padding to avoid overlap
                child: Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  // This child would be the securely rendered page image/widget.
                  child: Center(
                    child: Text(
                      'Page Content for ${index + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 3. Dynamic Watermark (DRM) - Non-interactive.
          IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: 0.08,
                child: Transform.rotate(
                  angle: -0.5,
                  child: const Text(
                    'user@company.com - 2025-06-28',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemGrey,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. & 5. Floating UI Elements at the bottom.
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // 5. Page Indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Page ${_currentPage + 1} of $_totalPages',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Bottom Toolbar - Wrapped in a ClipRRect for the glassmorphism effect.
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                          // OCR Reprocess Button
                          CupertinoButton(
                            onPressed: () {
                              /* TODO: Call OCR/ML Vision API */
                            },
                            child: const Icon(
                              CupertinoIcons.goforward,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          // TTS Button - The most prominent action
                          CupertinoButton(
                            onPressed: () {
                              setState(() {
                                _isPlaying = !_isPlaying;
                              });
                              // TODO: Toggle flutter_tts playback
                            },
                            child: Icon(
                              _isPlaying
                                  ? CupertinoIcons.pause_circle_fill
                                  : CupertinoIcons.play_circle_fill,
                              size: 40,
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                          // Accessibility Panel Button
                          CupertinoButton(
                            onPressed: () {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (_) => const AccessibilityPanel(),
                              );
                            },
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
            ),
          ),
        ],
      ),
    );
  }
}
