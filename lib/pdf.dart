import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class PdfPage extends StatefulWidget {
  const PdfPage({super.key});

  @override
  _PdfPageState createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  final List<File> _selectedImages = [];
  bool _isLoading = false;
  File? _savedPdfFile;

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _selectedImages.clear();
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _createPdf() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }

      final pdf = pw.Document();

      for (var imageFile in _selectedImages) {
        final image = pw.MemoryImage(await imageFile.readAsBytes());
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }

      // Ask user for file name
      String? pdfFileName = await _showRenameDialog();
      if (pdfFileName == null || pdfFileName.trim().isEmpty) return;

      // Get the public Download directory
      Directory downloadsDir = Directory('/storage/emulated/0/Download');

      final pdfFile = File('${downloadsDir.path}/$pdfFileName.pdf');

      await pdfFile.writeAsBytes(await pdf.save());

      setState(() {
        _savedPdfFile = pdfFile;
        _selectedImages.clear(); // Hide image selection screen
      });

      // Show bottom sheet with Open & Share options
      _showSaveOptions(pdfFile.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating PDF: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

void _showSaveOptions(String filePath) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent accidental dismissal
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.zero, // Ensure it covers the full screen
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 227, 232, 250),
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // PDF Image
                    // Image.asset(
                    //   'assets/PDF.png',
                    //   width: 200, // Adjust size as needed
                    //   height: 200,
                    //   fit: BoxFit.cover,
                    // ),
                    const SizedBox(height: 20),

                    // Success Icon
                    const Icon(Icons.check_circle, color: Colors.green, size: 80),
                    const SizedBox(height: 20),

                    // Success Text
                    const Text(
                      'PDF Saved Successfully!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Buttons (Open & Share)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => OpenFile.open(filePath),
                          icon: const Icon(Icons.open_in_new, color: Colors.white),
                          label: const Text('Open'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 58, 112, 183),
                              foregroundColor: Colors.white, // White text
                            ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Share.shareXFiles([XFile(filePath)], text: 'Here is your PDF file!');
                          },
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 58, 112, 183),
                              foregroundColor: Colors.white, // White text
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 30, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Future<String?> _showRenameDialog() async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename PDF'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter PDF name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Icon(Icons.picture_as_pdf, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'PDF Maker',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 39, 65, 87),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color.fromARGB(255, 227, 232, 250), // Set background color
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 58, 112, 183),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'Select Images',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _selectedImages.isEmpty
                      ? const Center(child: Text('No images selected', style: TextStyle(fontSize: 16)))
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            itemCount: _selectedImages.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemBuilder: (context, index) {
                              return Image.file(
                                _selectedImages[index],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                ),
                if (_selectedImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      onPressed: _createPdf,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Create PDF',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),

            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

