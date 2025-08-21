/*
* ----------------- accessibility_panel.dart -----------------
* A modal bottom sheet for adjusting accessibility settings.
*/
import 'package:flutter/cupertino.dart';

class AccessibilityPanel extends StatefulWidget {
  const AccessibilityPanel({super.key});

  @override
  State<AccessibilityPanel> createState() => _AccessibilityPanelState();
}

class _AccessibilityPanelState extends State<AccessibilityPanel> {
  double _fontSize = 50.0;
  bool _isHighContrast = false;
  bool _isFocusMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350, // Set a fixed height for the modal
      decoration: const BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with Title and Done button
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Accessibility',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 2. Font Size Adjustment
              const Text(
                'Font Size',
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel,
                  fontSize: 15,
                  decoration: TextDecoration.none,
                ),
              ),
              CupertinoSlider(
                value: _fontSize,
                min: 20,
                max: 100,
                onChanged: (value) {
                  setState(() => _fontSize = value);
                },
              ),
              const SizedBox(height: 24),
              // 3. High Contrast Mode
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'High-Contrast Mode',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  CupertinoSwitch(
                    value: _isHighContrast,
                    onChanged: (value) {
                      setState(() => _isHighContrast = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 4. Focus/Reading Mode
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Focus / Reading Mode',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  CupertinoSwitch(
                    value: _isFocusMode,
                    onChanged: (value) {
                      setState(() => _isFocusMode = value);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
