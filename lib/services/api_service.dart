import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/team.dart';
import '../models/game.dart';

class ApiService {
  static const String _baseUrl = 'https://your-api-gateway-url.amazonaws.com'; // TODO: Replace with your actual API Gateway URL
  
  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Helper method to handle API responses
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        'HTTP ${response.statusCode}: ${response.body}',
        response.statusCode,
      );
    }
  }

  // USER ENDPOINTS

  /// Create a new user
  Future<User> createUser({
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users'),
      headers: _headers,
      body: json.encode({
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      }),
    );

    final data = _handleResponse(response);
    return User.fromJson(data['user']);
  }

  /// Get user by ID
  Future<User> getUser(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return User.fromJson(data);
  }

  /// Get user by email
  Future<User> getUserByEmail(String email) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/by-email?email=${Uri.encodeComponent(email)}'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return User.fromJson(data);
  }

  /// Update user
  Future<User> updateUser(String userId, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: _headers,
      body: json.encode(updates),
    );

    final data = _handleResponse(response);
    return User.fromJson(data['user']);
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: _headers,
    );

    _handleResponse(response);
  }

  // TEAM ENDPOINTS

  /// Create a new team
  Future<Map<String, dynamic>> createTeam({
    required String ownerId,
    required String teamName,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/teams'),
      headers: _headers,
      body: json.encode({
        'owner_id': ownerId,
        'team_name': teamName,
      }),
    );

    final data = _handleResponse(response);
    return {
      'team': Team.fromJson(data['team']),
      'membership': TeamMembership.fromJson(data['membership']),
    };
  }

  /// Get team by ID
  Future<Team> getTeam(String teamId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/teams/$teamId'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return Team.fromJson(data);
  }

  /// Get teams for a user
  Future<List<TeamMembership>> getUserTeams(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$userId/teams'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return (data['teams'] as List)
        .map((team) => TeamMembership.fromJson(team))
        .toList();
  }

  /// Get team members
  Future<List<TeamMembership>> getTeamMembers(String teamId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/teams/$teamId/users'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return (data['members'] as List)
        .map((member) => TeamMembership.fromJson(member))
        .toList();
  }

  /// Add user to team
  Future<TeamMembership> addUserToTeam({
    required String teamId,
    required String userId,
    String role = 'PLAYER',
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/teams/$teamId/users'),
      headers: _headers,
      body: json.encode({
        'user_id': userId,
        'role': role,
      }),
    );

    final data = _handleResponse(response);
    return TeamMembership.fromJson(data['membership']);
  }

  /// Remove user from team
  Future<void> removeUserFromTeam(String teamId, String userId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/teams/$teamId/users/$userId'),
      headers: _headers,
    );

    _handleResponse(response);
  }

  /// Update team
  Future<Team> updateTeam(String teamId, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/teams/$teamId'),
      headers: _headers,
      body: json.encode(updates),
    );

    final data = _handleResponse(response);
    return Team.fromJson(data['team']);
  }

  /// Delete team
  Future<void> deleteTeam(String teamId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/teams/$teamId'),
      headers: _headers,
    );

    _handleResponse(response);
  }

  // GAME ENDPOINTS

  /// Create a new game
  Future<Game> createGame({
    required String teamId,
    required String createdBy,
    String? startDatetimeUtc,
    String? timezone,
    String? park,
    String? field,
    String? opponent,
  }) async {
    final body = <String, dynamic>{
      'created_by': createdBy,
    };

    if (startDatetimeUtc != null) body['start_datetime_utc'] = startDatetimeUtc;
    if (timezone != null) body['timezone'] = timezone;
    if (park != null) body['park'] = park;
    if (field != null) body['field'] = field;
    if (opponent != null) body['opponent'] = opponent;

    final response = await http.post(
      Uri.parse('$_baseUrl/teams/$teamId/games'),
      headers: _headers,
      body: json.encode(body),
    );

    final data = _handleResponse(response);
    return Game.fromJson(data['game']);
  }

  /// Get games for a team
  Future<Map<String, dynamic>> getTeamGames(
    String teamId, {
    int limit = 50,
    String? lastEvaluatedKey,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
    };
    if (lastEvaluatedKey != null) {
      queryParams['last_evaluated_key'] = lastEvaluatedKey;
    }

    final uri = Uri.parse('$_baseUrl/teams/$teamId/games').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(uri, headers: _headers);
    final data = _handleResponse(response);

    return {
      'games': (data['games'] as List).map((game) => Game.fromJson(game)).toList(),
      'lastEvaluatedKey': data['last_evaluated_key'],
    };
  }

  /// Get specific game
  Future<Game> getGame(String teamId, String gameId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/teams/$teamId/games/$gameId'),
      headers: _headers,
    );

    final data = _handleResponse(response);
    return Game.fromJson(data);
  }

  /// Update game
  Future<Game> updateGame(
    String teamId,
    String gameId,
    Map<String, dynamic> updates,
    String callerId,
  ) async {
    final body = <String, dynamic>{
      'caller_id': callerId,
      ...updates,
    };

    final response = await http.put(
      Uri.parse('$_baseUrl/teams/$teamId/games/$gameId'),
      headers: _headers,
      body: json.encode(body),
    );

    final data = _handleResponse(response);
    return Game.fromJson(data['game']);
  }

  /// Delete game
  Future<void> deleteGame(String teamId, String gameId, String callerId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/teams/$teamId/games/$gameId'),
      headers: _headers,
      body: json.encode({'caller_id': callerId}),
    );

    _handleResponse(response);
  }

  /// Update game lineup
  Future<Game> updateGameLineup(
    String teamId,
    String gameId,
    List<LineupPlayer> lineup,
    String callerId,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/teams/$teamId/games/$gameId/lineup'),
      headers: _headers,
      body: json.encode({
        'caller_id': callerId,
        'lineup': lineup.map((player) => player.toJson()).toList(),
      }),
    );

    final data = _handleResponse(response);
    return Game.fromJson(data['game']);
  }
}

/// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}
