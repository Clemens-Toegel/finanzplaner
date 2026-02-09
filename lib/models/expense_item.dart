import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'expense_account_type.dart';
import 'expense_sub_item.dart';

part 'expense_item.freezed.dart';
part 'expense_item.g.dart';

@freezed
abstract class ExpenseItem with _$ExpenseItem {
  const factory ExpenseItem({
    int? id,
    required ExpenseAccountType accountType,
    required String description,
    required String vendor,
    required String category,
    required double amount,
    required DateTime date,
    required bool isDeductible,
    required String notes,
    String? attachmentPath,
    @Default(<String>[]) List<String> secondaryAttachmentPaths,
    @Default(<String>[]) List<String> secondaryAttachmentNames,
    @Default(<ExpenseSubItem>[]) List<ExpenseSubItem> subItems,
  }) = _ExpenseItem;

  factory ExpenseItem.fromJson(Map<String, dynamic> json) =>
      _$ExpenseItemFromJson(json);

  const ExpenseItem._();

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'account': accountType.storageValue,
      'description': description,
      'vendor': vendor,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'deductible': isDeductible ? 1 : 0,
      'notes': notes,
      'attachment_path': attachmentPath,
      'secondary_attachment_paths': jsonEncode(secondaryAttachmentPaths),
      'secondary_attachment_names': jsonEncode(secondaryAttachmentNames),
      'sub_items': jsonEncode(subItems.map((item) => item.toJson()).toList()),
    };
  }

  factory ExpenseItem.fromMap(Map<String, Object?> map) {
    final rawSubItems = map['sub_items'] as String?;
    final rawSecondaryAttachmentPaths =
        map['secondary_attachment_paths'] as String?;
    final rawSecondaryAttachmentNames =
        map['secondary_attachment_names'] as String?;
    final secondaryPaths = _decodeStringList(rawSecondaryAttachmentPaths);
    final secondaryNames = _normalizeSecondaryAttachmentNames(
      paths: secondaryPaths,
      rawNames: _decodeStringList(rawSecondaryAttachmentNames),
    );

    return ExpenseItem(
      id: map['id'] as int?,
      accountType: ExpenseAccountTypeStorage.fromStorage(
        map['account'] as String? ?? 'personal',
      ),
      description: map['description'] as String? ?? '',
      vendor: map['vendor'] as String? ?? '',
      category: map['category'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      isDeductible: (map['deductible'] as int? ?? 0) == 1,
      notes: map['notes'] as String? ?? '',
      attachmentPath: (map['attachment_path'] as String?)?.trim(),
      secondaryAttachmentPaths: secondaryPaths,
      secondaryAttachmentNames: secondaryNames,
      subItems: _decodeSubItems(rawSubItems),
    );
  }

  static List<String> _decodeStringList(String? rawList) {
    if (rawList == null || rawList.trim().isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(rawList);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<String>()
          .map((entry) => entry.trim())
          .where((entry) => entry.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static List<String> _normalizeSecondaryAttachmentNames({
    required List<String> paths,
    required List<String> rawNames,
  }) {
    if (paths.isEmpty) {
      return const [];
    }

    final names = <String>[];
    for (var i = 0; i < paths.length; i++) {
      final candidate = i < rawNames.length ? rawNames[i].trim() : '';
      names.add(candidate.isEmpty ? _filenameForPath(paths[i]) : candidate);
    }
    return names;
  }

  static String _filenameForPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    final segments = normalized
        .split('/')
        .where((segment) => segment.isNotEmpty);
    if (segments.isEmpty) {
      return 'Bild';
    }
    return segments.last;
  }

  static List<ExpenseSubItem> _decodeSubItems(String? rawSubItems) {
    if (rawSubItems == null || rawSubItems.trim().isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(rawSubItems);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .map(ExpenseSubItem.fromJson)
          .where((item) => item.description.isNotEmpty && item.amount > 0)
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
