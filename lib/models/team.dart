import 'package:json_annotation/json_annotation.dart';

part 'team.g.dart';

@JsonSerializable()
class Team {
  final String id;
  final String name;
  final String? iconCode;
  final String? colorCode;
  final String? record;
  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  const Team({
    required this.id,
    required this.name,
    this.iconCode,
    this.colorCode,
    this.record,
    this.createdAt,
    this.lastUpdatedAt,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);

  @override
  String toString() => 'Team(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Team && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
