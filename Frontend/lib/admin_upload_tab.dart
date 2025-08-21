// lib/admin_upload_tab.dart

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';

// THE FIX: This import was missing. It defines ImagePicker and ImageSource.
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';

class AdminUploadTab extends StatefulWidget {
  const AdminUploadTab({super.key});

  @override
  State<AdminUploadTab> createState() => _AdminUploadTabState();
}

class _AdminUploadTabState extends State<AdminUploadTab> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _apiService = ApiService();

  File? _documentFile;
  File? _coverImageFile;
  bool _isLoading = false;

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _documentFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickCoverImage() async {
    // This will now work because of the added import.
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _documentFile == null ||
        _coverImageFile == null) {
      _showDialog('Validation Error', 'All fields and files are required.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // For now, we are hardcoding category ID. You can fetch categories and show a picker later.
      const int categoryId = 1;

      await _apiService.uploadDocument(
        _titleController.text,
        _descriptionController.text,
        categoryId,
        _documentFile!,
        _coverImageFile!,
      );
      _showDialog(
        'Success',
        'Document uploaded successfully.',
        isSuccess: true,
      );
    } catch (e) {
      _showDialog(
        'Upload Failed',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDialog(String title, String content, {bool isSuccess = false}) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (isSuccess) {
                    // Clear fields after successful upload
                    setState(() {
                      _titleController.clear();
                      _descriptionController.clear();
                      _documentFile = null;
                      _coverImageFile = null;
                    });
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CupertinoTextField(
            controller: _titleController,
            placeholder: 'Document Title',
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _descriptionController,
            placeholder: 'Description',
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          // Document Picker
          CupertinoListTile(
            title: const Text('Document File'),
            subtitle: Text(
              _documentFile?.path.split('/').last ?? 'No file selected',
            ),
            trailing: CupertinoButton(
              onPressed: _pickDocument,
              child: const Text('Select'),
            ),
          ),
          // Cover Image Picker
          CupertinoListTile(
            title: const Text('Cover Image'),
            subtitle: Text(
              _coverImageFile?.path.split('/').last ?? 'No image selected',
            ),
            leading:
                _coverImageFile != null
                    ? Image.file(
                      _coverImageFile!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                    : null,
            trailing: CupertinoButton(
              onPressed: _pickCoverImage,
              child: const Text('Select'),
            ),
          ),
          const SizedBox(height: 32),
          CupertinoButton.filled(
            onPressed: _isLoading ? null : _handleUpload,
            child:
                _isLoading
                    ? const CupertinoActivityIndicator()
                    : const Text('Upload Document'),
          ),
        ],
      ),
    );
  }
}
