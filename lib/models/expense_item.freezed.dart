// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpenseItem {

 int? get id; ExpenseAccountType get accountType; String get description; String get vendor; String get category; double get amount; DateTime get date; bool get isDeductible; String get notes; String? get attachmentPath; List<String> get secondaryAttachmentPaths; List<String> get secondaryAttachmentNames; List<ExpenseSubItem> get subItems;
/// Create a copy of ExpenseItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseItemCopyWith<ExpenseItem> get copyWith => _$ExpenseItemCopyWithImpl<ExpenseItem>(this as ExpenseItem, _$identity);

  /// Serializes this ExpenseItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseItem&&(identical(other.id, id) || other.id == id)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.description, description) || other.description == description)&&(identical(other.vendor, vendor) || other.vendor == vendor)&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.isDeductible, isDeductible) || other.isDeductible == isDeductible)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.attachmentPath, attachmentPath) || other.attachmentPath == attachmentPath)&&const DeepCollectionEquality().equals(other.secondaryAttachmentPaths, secondaryAttachmentPaths)&&const DeepCollectionEquality().equals(other.secondaryAttachmentNames, secondaryAttachmentNames)&&const DeepCollectionEquality().equals(other.subItems, subItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountType,description,vendor,category,amount,date,isDeductible,notes,attachmentPath,const DeepCollectionEquality().hash(secondaryAttachmentPaths),const DeepCollectionEquality().hash(secondaryAttachmentNames),const DeepCollectionEquality().hash(subItems));

@override
String toString() {
  return 'ExpenseItem(id: $id, accountType: $accountType, description: $description, vendor: $vendor, category: $category, amount: $amount, date: $date, isDeductible: $isDeductible, notes: $notes, attachmentPath: $attachmentPath, secondaryAttachmentPaths: $secondaryAttachmentPaths, secondaryAttachmentNames: $secondaryAttachmentNames, subItems: $subItems)';
}


}

/// @nodoc
abstract mixin class $ExpenseItemCopyWith<$Res>  {
  factory $ExpenseItemCopyWith(ExpenseItem value, $Res Function(ExpenseItem) _then) = _$ExpenseItemCopyWithImpl;
@useResult
$Res call({
 int? id, ExpenseAccountType accountType, String description, String vendor, String category, double amount, DateTime date, bool isDeductible, String notes, String? attachmentPath, List<String> secondaryAttachmentPaths, List<String> secondaryAttachmentNames, List<ExpenseSubItem> subItems
});




}
/// @nodoc
class _$ExpenseItemCopyWithImpl<$Res>
    implements $ExpenseItemCopyWith<$Res> {
  _$ExpenseItemCopyWithImpl(this._self, this._then);

  final ExpenseItem _self;
  final $Res Function(ExpenseItem) _then;

/// Create a copy of ExpenseItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? accountType = null,Object? description = null,Object? vendor = null,Object? category = null,Object? amount = null,Object? date = null,Object? isDeductible = null,Object? notes = null,Object? attachmentPath = freezed,Object? secondaryAttachmentPaths = null,Object? secondaryAttachmentNames = null,Object? subItems = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,accountType: null == accountType ? _self.accountType : accountType // ignore: cast_nullable_to_non_nullable
as ExpenseAccountType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,vendor: null == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,isDeductible: null == isDeductible ? _self.isDeductible : isDeductible // ignore: cast_nullable_to_non_nullable
as bool,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,attachmentPath: freezed == attachmentPath ? _self.attachmentPath : attachmentPath // ignore: cast_nullable_to_non_nullable
as String?,secondaryAttachmentPaths: null == secondaryAttachmentPaths ? _self.secondaryAttachmentPaths : secondaryAttachmentPaths // ignore: cast_nullable_to_non_nullable
as List<String>,secondaryAttachmentNames: null == secondaryAttachmentNames ? _self.secondaryAttachmentNames : secondaryAttachmentNames // ignore: cast_nullable_to_non_nullable
as List<String>,subItems: null == subItems ? _self.subItems : subItems // ignore: cast_nullable_to_non_nullable
as List<ExpenseSubItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseItem].
extension ExpenseItemPatterns on ExpenseItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseItem value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseItem value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  ExpenseAccountType accountType,  String description,  String vendor,  String category,  double amount,  DateTime date,  bool isDeductible,  String notes,  String? attachmentPath,  List<String> secondaryAttachmentPaths,  List<String> secondaryAttachmentNames,  List<ExpenseSubItem> subItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseItem() when $default != null:
return $default(_that.id,_that.accountType,_that.description,_that.vendor,_that.category,_that.amount,_that.date,_that.isDeductible,_that.notes,_that.attachmentPath,_that.secondaryAttachmentPaths,_that.secondaryAttachmentNames,_that.subItems);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  ExpenseAccountType accountType,  String description,  String vendor,  String category,  double amount,  DateTime date,  bool isDeductible,  String notes,  String? attachmentPath,  List<String> secondaryAttachmentPaths,  List<String> secondaryAttachmentNames,  List<ExpenseSubItem> subItems)  $default,) {final _that = this;
switch (_that) {
case _ExpenseItem():
return $default(_that.id,_that.accountType,_that.description,_that.vendor,_that.category,_that.amount,_that.date,_that.isDeductible,_that.notes,_that.attachmentPath,_that.secondaryAttachmentPaths,_that.secondaryAttachmentNames,_that.subItems);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  ExpenseAccountType accountType,  String description,  String vendor,  String category,  double amount,  DateTime date,  bool isDeductible,  String notes,  String? attachmentPath,  List<String> secondaryAttachmentPaths,  List<String> secondaryAttachmentNames,  List<ExpenseSubItem> subItems)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseItem() when $default != null:
return $default(_that.id,_that.accountType,_that.description,_that.vendor,_that.category,_that.amount,_that.date,_that.isDeductible,_that.notes,_that.attachmentPath,_that.secondaryAttachmentPaths,_that.secondaryAttachmentNames,_that.subItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpenseItem extends ExpenseItem {
  const _ExpenseItem({this.id, required this.accountType, required this.description, required this.vendor, required this.category, required this.amount, required this.date, required this.isDeductible, required this.notes, this.attachmentPath, final  List<String> secondaryAttachmentPaths = const <String>[], final  List<String> secondaryAttachmentNames = const <String>[], final  List<ExpenseSubItem> subItems = const <ExpenseSubItem>[]}): _secondaryAttachmentPaths = secondaryAttachmentPaths,_secondaryAttachmentNames = secondaryAttachmentNames,_subItems = subItems,super._();
  factory _ExpenseItem.fromJson(Map<String, dynamic> json) => _$ExpenseItemFromJson(json);

@override final  int? id;
@override final  ExpenseAccountType accountType;
@override final  String description;
@override final  String vendor;
@override final  String category;
@override final  double amount;
@override final  DateTime date;
@override final  bool isDeductible;
@override final  String notes;
@override final  String? attachmentPath;
 final  List<String> _secondaryAttachmentPaths;
@override@JsonKey() List<String> get secondaryAttachmentPaths {
  if (_secondaryAttachmentPaths is EqualUnmodifiableListView) return _secondaryAttachmentPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_secondaryAttachmentPaths);
}

 final  List<String> _secondaryAttachmentNames;
@override@JsonKey() List<String> get secondaryAttachmentNames {
  if (_secondaryAttachmentNames is EqualUnmodifiableListView) return _secondaryAttachmentNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_secondaryAttachmentNames);
}

 final  List<ExpenseSubItem> _subItems;
@override@JsonKey() List<ExpenseSubItem> get subItems {
  if (_subItems is EqualUnmodifiableListView) return _subItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subItems);
}


/// Create a copy of ExpenseItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseItemCopyWith<_ExpenseItem> get copyWith => __$ExpenseItemCopyWithImpl<_ExpenseItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseItem&&(identical(other.id, id) || other.id == id)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.description, description) || other.description == description)&&(identical(other.vendor, vendor) || other.vendor == vendor)&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.isDeductible, isDeductible) || other.isDeductible == isDeductible)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.attachmentPath, attachmentPath) || other.attachmentPath == attachmentPath)&&const DeepCollectionEquality().equals(other._secondaryAttachmentPaths, _secondaryAttachmentPaths)&&const DeepCollectionEquality().equals(other._secondaryAttachmentNames, _secondaryAttachmentNames)&&const DeepCollectionEquality().equals(other._subItems, _subItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountType,description,vendor,category,amount,date,isDeductible,notes,attachmentPath,const DeepCollectionEquality().hash(_secondaryAttachmentPaths),const DeepCollectionEquality().hash(_secondaryAttachmentNames),const DeepCollectionEquality().hash(_subItems));

@override
String toString() {
  return 'ExpenseItem(id: $id, accountType: $accountType, description: $description, vendor: $vendor, category: $category, amount: $amount, date: $date, isDeductible: $isDeductible, notes: $notes, attachmentPath: $attachmentPath, secondaryAttachmentPaths: $secondaryAttachmentPaths, secondaryAttachmentNames: $secondaryAttachmentNames, subItems: $subItems)';
}


}

/// @nodoc
abstract mixin class _$ExpenseItemCopyWith<$Res> implements $ExpenseItemCopyWith<$Res> {
  factory _$ExpenseItemCopyWith(_ExpenseItem value, $Res Function(_ExpenseItem) _then) = __$ExpenseItemCopyWithImpl;
@override @useResult
$Res call({
 int? id, ExpenseAccountType accountType, String description, String vendor, String category, double amount, DateTime date, bool isDeductible, String notes, String? attachmentPath, List<String> secondaryAttachmentPaths, List<String> secondaryAttachmentNames, List<ExpenseSubItem> subItems
});




}
/// @nodoc
class __$ExpenseItemCopyWithImpl<$Res>
    implements _$ExpenseItemCopyWith<$Res> {
  __$ExpenseItemCopyWithImpl(this._self, this._then);

  final _ExpenseItem _self;
  final $Res Function(_ExpenseItem) _then;

/// Create a copy of ExpenseItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? accountType = null,Object? description = null,Object? vendor = null,Object? category = null,Object? amount = null,Object? date = null,Object? isDeductible = null,Object? notes = null,Object? attachmentPath = freezed,Object? secondaryAttachmentPaths = null,Object? secondaryAttachmentNames = null,Object? subItems = null,}) {
  return _then(_ExpenseItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,accountType: null == accountType ? _self.accountType : accountType // ignore: cast_nullable_to_non_nullable
as ExpenseAccountType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,vendor: null == vendor ? _self.vendor : vendor // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,isDeductible: null == isDeductible ? _self.isDeductible : isDeductible // ignore: cast_nullable_to_non_nullable
as bool,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,attachmentPath: freezed == attachmentPath ? _self.attachmentPath : attachmentPath // ignore: cast_nullable_to_non_nullable
as String?,secondaryAttachmentPaths: null == secondaryAttachmentPaths ? _self._secondaryAttachmentPaths : secondaryAttachmentPaths // ignore: cast_nullable_to_non_nullable
as List<String>,secondaryAttachmentNames: null == secondaryAttachmentNames ? _self._secondaryAttachmentNames : secondaryAttachmentNames // ignore: cast_nullable_to_non_nullable
as List<String>,subItems: null == subItems ? _self._subItems : subItems // ignore: cast_nullable_to_non_nullable
as List<ExpenseSubItem>,
  ));
}


}

// dart format on
