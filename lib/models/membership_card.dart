import 'package:hive/hive.dart';

import 'code_format.dart';

part 'membership_card.g.dart';

@HiveType(typeId: 0)
class MembershipCard extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String storeName;

  @HiveField(2)
  String codeValue;

  @HiveField(3)
  CodeFormat codeFormat;

  @HiveField(4)
  String? logoPath;

  @HiveField(5)
  int colorValue;

  @HiveField(6)
  String? nickname;

  @HiveField(7)
  DateTime dateAdded;

  @HiveField(8)
  String? notes;

  MembershipCard({
    required this.id,
    required this.storeName,
    required this.codeValue,
    required this.codeFormat,
    this.logoPath,
    required this.colorValue,
    this.nickname,
    required this.dateAdded,
    this.notes,
  });

  String get displayName =>
      (nickname != null && nickname!.trim().isNotEmpty) ? nickname! : storeName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'storeName': storeName,
        'codeValue': codeValue,
        'codeFormat': codeFormat.name,
        'logoPath': logoPath,
        'colorValue': colorValue,
        'nickname': nickname,
        'dateAdded': dateAdded.toIso8601String(),
        'notes': notes,
      };

  factory MembershipCard.fromJson(Map<String, dynamic> json) {
    return MembershipCard(
      id: json['id'] as String,
      storeName: json['storeName'] as String,
      codeValue: json['codeValue'] as String,
      codeFormat: CodeFormat.values.firstWhere(
        (f) => f.name == json['codeFormat'],
        orElse: () => CodeFormat.code128,
      ),
      logoPath: json['logoPath'] as String?,
      colorValue: json['colorValue'] as int,
      nickname: json['nickname'] as String?,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      notes: json['notes'] as String?,
    );
  }
}
