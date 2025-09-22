import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

enum GameStatus {
  @JsonValue('SCHEDULED')
  scheduled,
  @JsonValue('IN_PROGRESS')
  inProgress,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled,
}

@JsonSerializable()
class Game {
  final String id;
  final String teamId;
  final String? opponentName;
  final DateTime? startDateTimeUtc;
  final GameStatus status;
  final String? location;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  const Game({
    required this.id,
    required this.teamId,
    this.opponentName,
    this.startDateTimeUtc,
    required this.status,
    this.location,
    this.notes,
    this.createdAt,
    this.lastUpdatedAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);

  @override
  String toString() => 'Game(id: $id, teamId: $teamId, opponentName: $opponentName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Game && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
