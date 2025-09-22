import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

enum PlayerRole {
  @JsonValue('OWNER')
  owner,
  @JsonValue('COACH')
  coach,
  @JsonValue('PLAYER')
  player,
}

@JsonSerializable()
class Player {
  final String id;
  final String displayName;
  final PlayerRole role;
  final String? linkedUserId;
  final bool isGhost;
  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  const Player({
    required this.id,
    required this.displayName,
    required this.role,
    this.linkedUserId,
    required this.isGhost,
    this.createdAt,
    this.lastUpdatedAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  @override
  String toString() => 'Player(id: $id, displayName: $displayName, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
