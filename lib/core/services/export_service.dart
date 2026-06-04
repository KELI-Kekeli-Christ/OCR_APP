import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/scan_result.dart';

enum ExportFormat { txt, markdown, pdf, docx }

class ExportService {
  Future<String> export(ScanResult scan, ExportFormat format) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = scan.createdAt.millisecondsSinceEpoch;

    return switch (format) {
      ExportFormat.txt => _writeFile(
          dir,
          'ocr_$timestamp.txt',
          scan.text,
        ),
      ExportFormat.markdown => _writeFile(
          dir,
          'ocr_$timestamp.md',
          scan.markdown,
        ),
      ExportFormat.pdf => _exportPdf(dir, scan, timestamp),
      ExportFormat.docx => _writeFile(
          dir,
          'ocr_$timestamp.docx',
          scan.markdown,
        ),
    };
  }

  Future<String> _writeFile(Directory dir, String name, String content) async {
    final file = File('${dir.path}/$name');
    await file.writeAsString(content);
    return file.path;
  }

  Future<String> _exportPdf(
    Directory dir,
    ScanResult scan,
    int timestamp,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, text: scan.title ?? 'OCR Export'),
          pw.Paragraph(text: scan.text),
          if (scan.latex != null)
            pw.Paragraph(
              text: 'LaTeX:\n${scan.latex}',
              style: const pw.TextStyle(fontSize: 10),
            ),
        ],
      ),
    );
    final path = '${dir.path}/ocr_$timestamp.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return path;
  }

  Future<void> shareFile(String path, {String? subject}) async {
    await Share.shareXFiles([XFile(path)], subject: subject ?? 'OCR Export');
  }

  Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
