import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mds_reads/pages/quiz/data/models/variants.dart';

part 'quiz.g.dart';

@HiveType(typeId : 0)
@JsonSerializable()
class Quiz extends HiveObject{
  @HiveField(0)
  final String description;

  @HiveField(1)
  final String descriptionRu;

  @HiveField(2)
  final String descriptionEn;

  @HiveField(3)
  final List<Variant> variantsList;

  @HiveField(4)
  final String id;

  @HiveField(5)
  final int type;

  @HiveField(6)
  final String bookId;

  Quiz({this.description, this.descriptionRu, this.descriptionEn, this.variantsList, this.id, this.type, this.bookId });

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);

  Map<String, dynamic> toJson() => _$QuizToJson(this);
}

