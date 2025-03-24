import 'package:flutter/material.dart';
import 'pdf.dart';
import 'file_compress.dart';
import 'img_compress.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PdfMakerScreen(),
  ));
}

class PdfMakerScreen extends StatelessWidget {
  const PdfMakerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 65, 87),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.picture_as_pdf, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'PDF & File Optimizer',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color.fromARGB(255, 227, 232, 250), // Set background color to dark blue
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOption(
                    context,
                    icon: Icons.picture_as_pdf,
                    label: "Create PDF",
                    color: Colors.red,
                    page: const PdfPage(),
                  ),
                  const SizedBox(width: 60),
                  _buildOption(
                    context,
                    icon: Icons.file_copy,
                    label: "File Compressor",
                    color: Colors.orange,
                    page: const FileCompressPage(),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              _buildOption(
                context,
                icon: Icons.image,
                label: "Image Compressor",
                color: Colors.purple,
                page: const ImgcompressPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required Widget page}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
