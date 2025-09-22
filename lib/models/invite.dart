import 'package:json_annotation/json_annotation.dart';

part 'invite.g.dart';

enum InviteStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACCEPTED')
  accepted,
  @JsonValue('DECLINED')
  declined,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('EXPIRED')
  expired,
}

@JsonSerializable()
class Invite {
  final String id;
  final String teamId;
  final String playerId;
  final String email;
  final InviteStatus status;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  const Invite({
    required this.id,
    required this.teamId,
    required this.playerId,
    required this.email,
    required this.status,
    this.expiresAt,
    this.createdAt,
    this.lastUpdatedAt,
  });

  factory Invite.fromJson(Map<String, dynamic> json) => _$InviteFromJson(json);
  Map<String, dynamic> toJson() => _$InviteToJson(this);

  @override
  String toString() => 'Invite(id: $id, teamId: $teamId, email: $email, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Invite && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
