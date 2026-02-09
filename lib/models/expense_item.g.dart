// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpenseItem _$ExpenseItemFromJson(Map<String, dynamic> json) => _ExpenseItem(
  id: (json['id'] as num?)?.toInt(),
  accountType: $enumDecode(_$ExpenseAccountTypeEnumMap, json['accountType']),
  description: json['description'] as String,
  vendor: json['vendor'] as String,
  category: json['category'] as String,
  amount: (json['amount'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  isDeductible: json['isDeductible'] as bool,
  notes: json['notes'] as String,
  attachmentPath: json['attachmentPath'] as String?,
  secondaryAttachmentPaths:
      (json['secondaryAttachmentPaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  secondaryAttachmentNames:
      (json['secondaryAttachmentNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  subItems:
      (json['subItems'] as List<dynamic>?)
          ?.map((e) => ExpenseSubItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ExpenseSubItem>[],
);

Map<String, dynamic> _$ExpenseItemToJson(_ExpenseItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountType': _$ExpenseAccountTypeEnumMap[instance.accountType]!,
      'description': instance.description,
      'vendor': instance.vendor,
      'category': instance.category,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'isDeductible': instance.isDeductible,
      'notes': instance.notes,
      'attachmentPath': instance.attachmentPath,
      'secondaryAttachmentPaths': instance.secondaryAttachmentPaths,
      'secondaryAttachmentNames': instance.secondaryAttachmentNames,
      'subItems': instance.subItems,
    };

const _$ExpenseAccountTypeEnumMap = {
  ExpenseAccountType.personal: 'personal',
  ExpenseAccountType.business: 'business',
};
