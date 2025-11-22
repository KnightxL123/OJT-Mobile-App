import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../../utils/constants.dart';

class UploadDocumentScreen extends StatefulWidget {
  static const String routeName = '/upload-document';

  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  bool _isUploading = false;
  String? _statusMessage;
  PlatformFile? _selectedFile;

  Future<void> _uploadDocument() async {
    if (_selectedFile == null || _selectedFile!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _statusMessage = null;
    });

    try {
      final uri = Uri.parse(ApiConstants.baseUrl);
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedFile!.path!,
          filename: _selectedFile!.name,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        setState(() {
          _statusMessage =
              'Upload completed. Connect this URL to your PHP upload API if needed.';
        });
      } else {
        setState(() {
          _statusMessage = 'Upload failed (${response.statusCode}).';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Upload error: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _selectFile() {
    FilePicker.platform.pickFiles(
      allowMultiple: false,
    ).then((result) {
      if (!mounted || result == null || result.files.isEmpty) return;
      setState(() {
        _selectedFile = result.files.single;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Upload Document'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload a document using your backend API.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedFile?.name ?? 'No file selected',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: _isUploading ? null : _selectFile,
                    child: const Text('Choose File'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadDocument,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: _isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Upload'),
              ),
            ),
            const SizedBox(height: 16),
            if (_statusMessage != null)
              Text(
                _statusMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
