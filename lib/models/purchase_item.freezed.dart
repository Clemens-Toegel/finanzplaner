// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PurchaseItem {

 int? get id; ExpenseAccountType get accountType; String get description; String get vendor; String get category; double get amount; DateTime get date; bool get isDeductible; String get notes; String? get attachmentPath; List<ExpenseSubItem> get subItems;
/// Create a copy of PurchaseItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseItemCopyWith<PurchaseItem> get copyWith => _$PurchaseItemCopyWithImpl<PurchaseItem>(this as PurchaseItem, _$identity);

  /// Serializes this PurchaseItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseItem&&(identical(other.id, id) || other.id == id)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.description, description) || other.description == description)&&(identical(other.vendor, vendor) || other.vendor == vendor)&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.isDeductible, isDeductible) || other.isDeductible == isDeductible)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.attachmentPath, attachmentPath) || other.attachmentPath == attachmentPath)&&const DeepCollectionEquality().equals(other.subItems, subItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountType,description,vendor,category,amount,date,isDeductible,notes,attachmentPath,const DeepCollectionEquality().hash(subItems));

@override
String toString() {
  return 'PurchaseItem(id: $id, accountType: $accountType, description: $description, vendor: $vendor, category: $category, amount: $amount, date: $date, isDeductible: $isDeductible, notes: $notes, attachmentPath: $attachmentPath, subItems: $subItems)';
}


}

/// @nodoc
abstract mixin class $PurchaseItemCopyWith<$Res>  {
  factory $PurchaseItemCopyWith(PurchaseItem value, $Res Function(PurchaseItem) _then) = _$PurchaseItemCopyWithImpl;
@useResult
$Res call({
 int? id, ExpenseAccountType accountType, String description, String vendor, String category, double amount, DateTime date, bool isDeductible, String notes, String? attachmentPath, List<ExpenseSubItem> subItems
});




}
/// @nodoc
class _$PurchaseItemCopyWithImpl<$Res>
    implements $PurchaseItemCopyWith<$Res> {
  _$PurchaseItemCopyWithImpl(this._self, this._then);

  final PurchaseItem _self;
  final $Res Function(PurchaseItem) _then;

/// Create a copy of PurchaseItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? accountType = null,Object? description = null,Object? vendor = null,Object? category = null,Object? amount = null,Object? date = null,Object? isDeductible = null,Object? notes = null,Object? attachmentPath = freezed,Object? subItems = null,}) {
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
as String?,subItems: null == subItems ? _self.subItems : subItems // ignore: cast_nullable_to_non_nullable
as List<ExpenseSubItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseItem].
extension PurchaseItemPatterns on PurchaseItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseItem value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseItem value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  ExpenseAccountType accountType,  String description,  String vendor,  String category,  double amount,  DateTime date,  bool isDeductible,  String notes,  String? attachmentPath,  List<ExpenseSubItem> subItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseItem() when $default != null:
return $default(_that.id,_that.accountType,_that.description,_that.vendor,_that.category,_that.amount,_that.date,_that.isDeductible,_that.notes,_that.attachmentPath,_that.subItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  ExpenseAccountType accountType,  String description,  String vendor,  String category,  double amount,  DateTime date,  bool isDeductible,  String notes,  String? attachmentPath,  List<ExpenseSubItem> subItems)  $default,) {final _that = this;
switch (_that) {
case _PurchaseItem():
return $default(_that.id,_that.accountType,_that.description,_that.vendor,_that.category,_that.amount,_that.date,_that.isDeductible,_that.notes,_that.attachmentPath,_that.subItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  ExpenseAccountType accountType,  String description,  String vendor,  String category,  double amount,  DateTime date,  bool isDeductible,  String notes,  String? attachmentPath,  List<ExpenseSubItem> subItems)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseItem() when $default != null:
return $default(_that.id,_that.accountType,_that.description,_that.vendor,_that.category,_that.amount,_that.date,_that.isDeductible,_that.notes,_that.attachmentPath,_that.subItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseItem extends PurchaseItem {
  const _PurchaseItem({this.id, required this.accountType, required this.description, required this.vendor, required this.category, required this.amount, required this.date, required this.isDeductible, required this.notes, this.attachmentPath, final  List<ExpenseSubItem> subItems = const <ExpenseSubItem>[]}): _subItems = subItems,super._();
  factory _PurchaseItem.fromJson(Map<String, dynamic> json) => _$PurchaseItemFromJson(json);

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
 final  List<ExpenseSubItem> _subItems;
@override@JsonKey() List<ExpenseSubItem> get subItems {
  if (_subItems is EqualUnmodifiableListView) return _subItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subItems);
}


/// Create a copy of PurchaseItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseItemCopyWith<_PurchaseItem> get copyWith => __$PurchaseItemCopyWithImpl<_PurchaseItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseItem&&(identical(other.id, id) || other.id == id)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.description, description) || other.description == description)&&(identical(other.vendor, vendor) || other.vendor == vendor)&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.isDeductible, isDeductible) || other.isDeductible == isDeductible)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.attachmentPath, attachmentPath) || other.attachmentPath == attachmentPath)&&const DeepCollectionEquality().equals(other._subItems, _subItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountType,description,vendor,category,amount,date,isDeductible,notes,attachmentPath,const DeepCollectionEquality().hash(_subItems));

@override
String toString() {
  return 'PurchaseItem(id: $id, accountType: $accountType, description: $description, vendor: $vendor, category: $category, amount: $amount, date: $date, isDeductible: $isDeductible, notes: $notes, attachmentPath: $attachmentPath, subItems: $subItems)';
}


}

/// @nodoc
abstract mixin class _$PurchaseItemCopyWith<$Res> implements $PurchaseItemCopyWith<$Res> {
  factory _$PurchaseItemCopyWith(_PurchaseItem value, $Res Function(_PurchaseItem) _then) = __$PurchaseItemCopyWithImpl;
@override @useResult
$Res call({
 int? id, ExpenseAccountType accountType, String description, String vendor, String category, double amount, DateTime date, bool isDeductible, String notes, String? attachmentPath, List<ExpenseSubItem> subItems
});




}
/// @nodoc
class __$PurchaseItemCopyWithImpl<$Res>
    implements _$PurchaseItemCopyWith<$Res> {
  __$PurchaseItemCopyWithImpl(this._self, this._then);

  final _PurchaseItem _self;
  final $Res Function(_PurchaseItem) _then;

/// Create a copy of PurchaseItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? accountType = null,Object? description = null,Object? vendor = null,Object? category = null,Object? amount = null,Object? date = null,Object? isDeductible = null,Object? notes = null,Object? attachmentPath = freezed,Object? subItems = null,}) {
  return _then(_PurchaseItem(
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
as String?,subItems: null == subItems ? _self._subItems : subItems // ignore: cast_nullable_to_non_nullable
as List<ExpenseSubItem>,
  ));
}


}

// dart format on
