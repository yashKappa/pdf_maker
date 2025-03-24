import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileCompressPage extends StatefulWidget {
  const FileCompressPage({super.key});

  @override
  _FileCompressPageState createState() => _FileCompressPageState();
}

class _FileCompressPageState extends State<FileCompressPage> {
  File? _selectedFile;
  int? _originalSize;
  bool _isCompressing = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File selectedFile = File(result.files.single.path!);
      int fileSize = selectedFile.lengthSync();

      setState(() {
        _selectedFile = selectedFile;
        _originalSize = fileSize;
      });
    }
  }

  Future<void> _compressFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isCompressing = true;
    });

    File compressedFile = await _compressPDF(_selectedFile!);
    int compressedSize = compressedFile.lengthSync();

    setState(() {
      _isCompressing = false;
    });

    // Navigate to the compressed file page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompressedFilePage(
          originalFile: _selectedFile!,
          compressedFile: compressedFile,
          originalSize: _originalSize!,
          compressedSize: compressedSize,
        ),
      ),
    );
  }

  Future<File> _compressPDF(File file) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulating compression
    Directory tempDir = await getTemporaryDirectory();
    File compressedFile =
        File('${tempDir.path}/compressed_${file.uri.pathSegments.last}');
    await file.copy(compressedFile.path);
    return compressedFile;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return "$bytes B";
    } else if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(2)} KB";
    } else {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.white), // White File Icon
            SizedBox(width: 8),
            Text("File Compressor",
                style: TextStyle(color: Colors.white)), // White Text
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 39, 65, 87),
        iconTheme: const IconThemeData(color: Colors.white), // White Back Arrow
      ),
      backgroundColor: const Color.fromARGB(255, 227, 232, 250),
      body: _isCompressing
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 58, 112, 183),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'Select File & Compress',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  if (_selectedFile != null) ...[
                    const SizedBox(height: 20),
                    const Icon(Icons.picture_as_pdf,
                        size: 100, color: Color.fromARGB(255, 183, 58, 58)),
                    const SizedBox(height: 10),
                    Text(_selectedFile!.uri.pathSegments.last,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 5),
                    Text("Size: ${_formatFileSize(_originalSize!)}"),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _compressFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 58, 112, 183),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text(
                        'Compress File',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class CompressedFilePage extends StatelessWidget {
  final File originalFile;
  final File compressedFile;
  final int originalSize;
  final int compressedSize;

  const CompressedFilePage({
    super.key,
    required this.originalFile,
    required this.compressedFile,
    required this.originalSize,
    required this.compressedSize,
  });

  Future<void> _shareFile() async {
    await Share.shareXFiles([XFile(compressedFile.path)],
        text: "Here is your compressed PDF file.");
  }

  Future<void> _saveFile(BuildContext context) async {
    Directory? directory = await getExternalStorageDirectory();
    if (directory != null) {
      String newPath =
          '${directory.path}/${compressedFile.uri.pathSegments.last}';
      await compressedFile.copy(newPath);

      // Show a success message with a professional look
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: Colors.white), // Success icon
              const SizedBox(width: 10),
              const Text(
                "Compressed file saved successfully!",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 39, 65, 87),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
        ),
      );

      debugPrint("File saved to $newPath");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // This removes the back arrow
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color.fromARGB(255, 0, 0, 0)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const FileCompressPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 227, 232, 250),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf,
                size: 100, color: Color.fromARGB(255, 183, 58, 58)),
            const SizedBox(height: 10),
            Text(
                "Original: ${_formatFileSize(originalSize)} → Compressed: ${_formatFileSize(compressedSize)}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _shareFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 58, 112, 183),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(
                    'Share',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => _saveFile(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 58, 112, 183),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return "$bytes B";
    } else if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(2)} KB";
    } else {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    }
  }
}
