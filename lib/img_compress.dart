import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImgcompressPage extends StatefulWidget {
  const ImgcompressPage({super.key});

  @override
  _ImgcompressPageState createState() => _ImgcompressPageState();
}

class _ImgcompressPageState extends State<ImgcompressPage> {
  File? _selectedImage;
  bool _isCompressing = false;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      File selectedFile = File(result.files.single.path!);
      setState(() {
        _selectedImage = selectedFile;
      });
      _compressImage();
    }
  }

  Future<void> _compressImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isCompressing = true;
    });

    File compressedImage = await _compressImg(_selectedImage!);

    setState(() {
      _isCompressing = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompressedImagePage(compressedImage: compressedImage),
      ),
    );
  }

  Future<File> _compressImg(File file) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulating compression
    Directory tempDir = await getTemporaryDirectory();
    File compressedImage =
        File('${tempDir.path}/compressed_${file.uri.pathSegments.last}');
    await file.copy(compressedImage.path);
    return compressedImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Icon(Icons.image, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Image Compresser',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 39, 65, 87),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 227, 232, 250),

      body: Center(
        child: _isCompressing
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 58, 112, 183),
                ),
                child: const Text(
                  "Select Image ",
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}

class CompressedImagePage extends StatelessWidget {
  final File compressedImage;

  const CompressedImagePage({super.key, required this.compressedImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 227, 232, 250),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.file(compressedImage, height: 500),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Share.shareXFiles(
                        [XFile(compressedImage.path)],
                        text: "Here is your compressed image.",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 58, 112, 183),
                    ),
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text(
                      "Share Image",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 50, 69, 109),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Image saved successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}