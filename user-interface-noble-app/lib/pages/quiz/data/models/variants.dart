import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'variants.g.dart';

@HiveType(typeId : 1)
@JsonSerializable()
class Variant extends HiveObject{
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String textEn;

  @HiveField(3)
  final String textRu;

  @HiveField(4)
  final String relatedId;

  @HiveField(5)
  final String textRel;

  @HiveField(6)
  final String textEnRel;

  @HiveField(7)
  final String textRuRel;

  @HiveField(8)
  bool isAnswer = false;

  Variant({this.id, this.text, this.textEn, this.textRu, this.relatedId, this.textRel, this.textEnRel, this.textRuRel, this.isAnswer });

  factory Variant.fromJson(Map<String, dynamic> json) => _$VariantFromJson(json);

  Map<String, dynamic> toJson() => _$VariantToJson(this);
}

