import 'dart:io';
import 'dart:math';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/expense_sub_item.dart';
import '../models/ocr_bill_data.dart';

enum BillScanMode { shopReceipt, a4Bill }

enum BillImageSource { camera, gallery }

class OfflineBillOcrService {
  OfflineBillOcrService()
    : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer;

  Future<OcrBillData?> scanBill({
    required BillScanMode mode,
    BillImageSource source = BillImageSource.camera,
  }) async {
    final image = await _picker.pickImage(
      source: source == BillImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: mode == BillScanMode.shopReceipt ? 85 : 95,
      maxWidth: mode == BillScanMode.shopReceipt ? 1800 : 2800,
    );

    if (image == null) {
      return null;
    }

    final recognizedText = await _textRecognizer.processImage(
      InputImage.fromFilePath(image.path),
    );

    final rawText = recognizedText.text.trim();
    if (rawText.isEmpty) {
      return OcrBillData(rawText: '', sourceFilePath: image.path);
    }

    return _extractData(rawText, mode: mode, sourceFilePath: image.path);
  }

  Future<String?> pickBillImage({
    BillImageSource source = BillImageSource.camera,
  }) async {
    final image = await _picker.pickImage(
      source: source == BillImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 92,
      maxWidth: 2600,
    );

    return image?.path;
  }

  OcrBillData _extractData(
    String rawText, {
    required BillScanMode mode,
    required String sourceFilePath,
  }) {
    final lines = rawText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final vendor = lines.isNotEmpty ? lines.first : null;
    final description = lines.length > 1 ? lines[1] : vendor;

    final date = _extractDate(rawText);
    final amount = _extractAmount(rawText);
    final subItems = _extractSubItems(rawText, mode: mode, totalAmount: amount);

    return OcrBillData(
      rawText: rawText,
      vendor: vendor,
      description: description,
      date: date,
      amount: amount,
      notes: null,
      sourceFilePath: sourceFilePath,
      subItems: subItems,
    );
  }

  DateTime? _extractDate(String text) {
    final dateMatch = RegExp(
      r'(\b\d{1,2}[./-]\d{1,2}[./-]\d{2,4}\b)|(\b\d{4}[./-]\d{1,2}[./-]\d{1,2}\b)',
    ).firstMatch(text);

    if (dateMatch == null) {
      return null;
    }

    final token = dateMatch.group(0);
    if (token == null) {
      return null;
    }

    final normalized = token.replaceAll('/', '.').replaceAll('-', '.');
    final parts = normalized.split('.');

    if (parts.length != 3) {
      return null;
    }

    if (parts[0].length == 4) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year == null || month == null || day == null) {
        return null;
      }
      return DateTime.tryParse(
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
      );
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final parsedYear = int.tryParse(parts[2]);
    if (day == null || month == null || parsedYear == null) {
      return null;
    }
    final year = parsedYear < 100 ? 2000 + parsedYear : parsedYear;

    return DateTime.tryParse(
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
    );
  }

  double? _extractAmount(String text) {
    final lines = text.split('\n');
    final keywordRegex = RegExp(
      r'(summe|gesamt|total|betrag|zu zahlen|endbetrag|gesamtbetrag)',
      caseSensitive: false,
    );

    final allCandidates = <double>[];

    for (final line in lines) {
      final lineCandidates = _extractAmountsFromLine(line);
      allCandidates.addAll(lineCandidates);
      if (keywordRegex.hasMatch(line) && lineCandidates.isNotEmpty) {
        return lineCandidates.reduce(max);
      }
    }

    if (allCandidates.isEmpty) {
      return null;
    }

    return allCandidates.reduce(max);
  }

  List<ExpenseSubItem> _extractSubItems(
    String text, {
    required BillScanMode mode,
    required double? totalAmount,
  }) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final skipRegex = RegExp(
      r'(summe|gesamt|total|betrag|zu zahlen|endbetrag|gesamtbetrag|mwst|ust|tax|rechnung|invoice|zahlung|zahlart|bar|karte|card|cash|wechselgeld|ust-id|uid|tel\.?|www\.|http|danke|beleg|kassa|filiale)',
      caseSensitive: false,
    );

    final candidates = <_SubItemCandidate>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (skipRegex.hasMatch(line)) {
        continue;
      }

      final amounts = _extractAmountsFromLine(line);
      if (amounts.isEmpty) {
        continue;
      }

      final amount = amounts.last;
      if (amount <= 0 || amount > 10000) {
        continue;
      }

      var description = _extractDescriptionForLine(line);
      if (description.isEmpty) {
        continue;
      }

      // For shop receipts, remove noisy prefixes like article ids and quantity markers.
      if (mode == BillScanMode.shopReceipt) {
        description = description
            .replaceAll(RegExp(r'^\d{4,}\s+'), '')
            .replaceAll(RegExp(r'^\d+\s*[xX]\s*'), '')
            .trim();
      }

      if (!_looksLikeItemDescription(description)) {
        continue;
      }

      candidates.add(
        _SubItemCandidate(index: i, description: description, amount: amount),
      );
    }

    final selected = _selectBestSubItems(
      candidates,
      totalAmount: totalAmount,
      mode: mode,
    );

    return selected
        .map(
          (entry) => ExpenseSubItem(
            description: entry.description,
            amount: entry.amount,
          ),
        )
        .take(30)
        .toList();
  }

  String _extractDescriptionForLine(String line) {
    final cleanedLine = line.trim();
    final match = RegExp(
      r'^(.*?)(\d{1,4}(?:[.,]\d{3})*(?:[.,]\d{2}))\s*$',
    ).firstMatch(cleanedLine);

    var description = match != null ? (match.group(1) ?? '') : cleanedLine;

    description = description
        .replaceAll(RegExp(r'\b\d{1,4}(?:[.,]\d{3})*(?:[.,]\d{2})\b'), ' ')
        .replaceAll(RegExp(r'\b\d+\b'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return description;
  }

  bool _looksLikeItemDescription(String description) {
    if (description.length < 2) {
      return false;
    }
    if (RegExp(r'^[^A-Za-zÄÖÜäöüß]+$').hasMatch(description)) {
      return false;
    }
    if (RegExp(
      r'^(eur|euro|sum|total|ust|mwst)$',
      caseSensitive: false,
    ).hasMatch(description)) {
      return false;
    }
    return true;
  }

  List<_SubItemCandidate> _selectBestSubItems(
    List<_SubItemCandidate> candidates, {
    required double? totalAmount,
    required BillScanMode mode,
  }) {
    if (candidates.isEmpty) {
      return const [];
    }

    // De-duplicate identical line items that OCR may output multiple times.
    final deduped = <String, _SubItemCandidate>{};
    for (final candidate in candidates) {
      final key =
          '${candidate.description.toLowerCase()}|${candidate.amount.toStringAsFixed(2)}';
      deduped.putIfAbsent(key, () => candidate);
    }

    final values = deduped.values.toList()..sort((a, b) => a.index - b.index);

    if (totalAmount == null || totalAmount <= 0) {
      return values;
    }

    final maxAllowed =
        totalAmount * (mode == BillScanMode.shopReceipt ? 1.05 : 1.15);
    final exactish = <_SubItemCandidate>[];
    double running = 0;

    for (final entry in values) {
      if (running + entry.amount <= maxAllowed) {
        exactish.add(entry);
        running += entry.amount;
      }
    }

    if (exactish.isNotEmpty) {
      return exactish;
    }

    // Fallback: keep reasonably sized lines (exclude totals/taxes that survived filters).
    return values.where((entry) => entry.amount <= totalAmount).toList();
  }

  List<double> _extractAmountsFromLine(String line) {
    final matches = RegExp(
      r'\b\d{1,4}(?:[.,]\d{3})*(?:[.,]\d{2})\b',
    ).allMatches(line);

    final values = <double>[];
    for (final match in matches) {
      final token = match.group(0);
      if (token == null) {
        continue;
      }

      final normalized = token.contains(',') && token.contains('.')
          ? token.replaceAll('.', '').replaceAll(',', '.')
          : token.replaceAll(',', '.');

      final value = double.tryParse(normalized);
      if (value != null) {
        values.add(value);
      }
    }

    return values;
  }

  Future<String?> persistAttachment(String sourcePath) async {
    try {
      final source = File(sourcePath);
      if (!await source.exists()) {
        return null;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory(
        p.join(appDir.path, 'expense_attachments'),
      );
      if (!await attachmentsDir.exists()) {
        await attachmentsDir.create(recursive: true);
      }

      final extension = p.extension(source.path).toLowerCase();
      final safeExtension = extension.isEmpty ? '.jpg' : extension;
      final fileName =
          'expense_${DateTime.now().millisecondsSinceEpoch}$safeExtension';
      final targetPath = p.join(attachmentsDir.path, fileName);

      final stored = await source.copy(targetPath);
      return stored.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteStoredAttachment(String? filePath) async {
    final path = filePath?.trim();
    if (path == null || path.isEmpty) {
      return;
    }

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best effort cleanup.
    }
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}

class _SubItemCandidate {
  const _SubItemCandidate({
    required this.index,
    required this.description,
    required this.amount,
  });

  final int index;
  final String description;
  final double amount;
}
