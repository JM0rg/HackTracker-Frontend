import 'dart:convert';
import 'package:http/http.dart' as http;

/// Comprehensive API service covering all HackTracker backend endpoints
class ApiService {
  static const String baseUrl = 'https://1bp6rtodo2.execute-api.us-east-1.amazonaws.com/hacktracker-test';
  
  /// Common headers for authenticated requests
  static Map<String, String> _getHeaders(String accessToken) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  /// Handle API response and extract data
  static Map<String, dynamic>? _handleResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        print('🌐 API: Success response parsed: $data');
        
        // Backend returns data directly, not wrapped in {"success": true, "data": {...}}
        // So we'll wrap it ourselves for consistency
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorData = json.decode(response.body);
        print('🌐 API: HTTP Error ${response.statusCode}: ${errorData['error']}');
      }
      return null;
    } catch (e) {
      print('🌐 API: Error parsing response: $e');
      return null;
    }
  }

  // ============================
  // USER ENDPOINTS
  // ============================

  /// GET /users/{id} - Get user by ID
  static Future<Map<String, dynamic>?> getUser(String userId, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _getHeaders(accessToken),
      );
      
      final result = _handleResponse(response);
      return result?['data'];
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  /// GET /users/{id}?email={email} - Get user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String userId, String email, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId?email=$email'),
        headers: _getHeaders(accessToken),
      );
      
      final result = _handleResponse(response);
      return result?['data'];
    } catch (e) {
      print('Error fetching user by email: $e');
      return null;
    }
  }

  /// PUT /users/{id} - Update user profile
  static Future<bool> updateUser({
    required String userId,
    String? firstName,
    String? lastName,
    required String accessToken,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _getHeaders(accessToken),
        body: json.encode(body),
      );

      return _handleResponse(response) != null;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  /// DELETE /users/{id} - Delete user account
  static Future<bool> deleteUser(String userId, String accessToken) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _getHeaders(accessToken),
      );

      return _handleResponse(response) != null;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  /// GET /users/{id}/teams - Get user's teams
  static Future<List<Map<String, dynamic>>> getUserTeams(String userId, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/teams'),
        headers: _getHeaders(accessToken),
      );

      final result = _handleResponse(response);
      if (result != null && result['data'] != null) {
        // Backend returns {"teams": [...]} so we need to extract the teams array
        final data = result['data'];
        List<Map<String, dynamic>> teams = [];
        
        if (data is Map<String, dynamic> && data.containsKey('teams')) {
          teams = List<Map<String, dynamic>>.from(data['teams'] ?? []);
        } else if (data is List) {
          // Fallback: if data is directly a list
          teams = List<Map<String, dynamic>>.from(data);
        }
        
        // Transform team data to frontend format
        return teams.map((team) {
          return {
            'id': team['PK']?.toString().replaceFirst('TEAM#', '') ?? '',
            'name': team['team_name'] ?? 'Unknown Team',
            'emoji': team['emoji'] ?? '⚾',
            'created_at': team['created_at'],
            'owner_id': team['owner_id'],
          };
        }).toList();
      }
      
      return [];
    } catch (e) {
      print('Error fetching user teams: $e');
      return [];
    }
  }

  // ============================
  // TEAM ENDPOINTS
  // ============================

  /// POST /teams - Create a new team
  static Future<Map<String, dynamic>?> createTeam({
    required String teamName,
    required String ownerId,
    required String accessToken,
  }) async {
    try {
      print('🌐 API: Creating team "$teamName" for owner: $ownerId');
      print('🌐 API: URL: $baseUrl/teams');
      print('🌐 API: Token: ${accessToken.substring(0, 20)}...');
      
      final requestBody = {
        'team_name': teamName,  // Backend expects 'team_name', not 'name'
        'owner_id': ownerId,    // Backend expects 'owner_id'
      };
      print('🌐 API: Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/teams'),
        headers: _getHeaders(accessToken),
        body: json.encode(requestBody),
      );

      print('🌐 API: Response status: ${response.statusCode}');
      print('🌐 API: Response body: ${response.body}');

      final result = _handleResponse(response);
      print('🌐 API: Parsed result: $result');
      
      // For team creation, return the team object from the response
      if (result != null && result['data'] != null) {
        final team = result['data']['team'];
        if (team != null) {
          // Transform team data to frontend format
          return {
            'id': team['PK']?.toString().replaceFirst('TEAM#', '') ?? '',
            'name': team['team_name'] ?? 'Unknown Team',
            'emoji': team['emoji'] ?? '⚾',
            'created_at': team['created_at'],
            'owner_id': team['owner_id'],
          };
        }
      }
      
      return null;
    } catch (e) {
      print('🌐 API: Exception creating team: $e');
      return null;
    }
  }

  /// GET /teams/{id} - Get team details
  static Future<Map<String, dynamic>?> getTeam(String teamId, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teams/$teamId'),
        headers: _getHeaders(accessToken),
      );

      final result = _handleResponse(response);
      if (result != null && result['data'] != null) {
        final team = result['data'];
        // Transform team data to frontend format
        return {
          'id': team['PK']?.toString().replaceFirst('TEAM#', '') ?? teamId,
          'name': team['team_name'] ?? 'Unknown Team',
          'emoji': team['emoji'] ?? '⚾',
          'created_at': team['created_at'],
          'owner_id': team['owner_id'],
        };
      }
      return null;
    } catch (e) {
      print('Error fetching team: $e');
      return null;
    }
  }

  /// PUT /teams/{id} - Update team details
  static Future<bool> updateTeam({
    required String teamId,
    required String teamName,
    required String accessToken,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/teams/$teamId'),
        headers: _getHeaders(accessToken),
        body: json.encode({'name': teamName}),
      );

      return _handleResponse(response) != null;
    } catch (e) {
      print('Error updating team: $e');
      return false;
    }
  }

  /// DELETE /teams/{id} - Delete team (cascading delete)
  static Future<bool> deleteTeam(String teamId, String accessToken) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/teams/$teamId'),
        headers: _getHeaders(accessToken),
      );

      return _handleResponse(response) != null;
    } catch (e) {
      print('Error deleting team: $e');
      return false;
    }
  }

  // ============================
  // TEAM PLAYER ENDPOINTS (Unified Player Model)
  // ============================

  /// GET /teams/{id}/players - Get team players
  static Future<List<Map<String, dynamic>>> getTeamPlayers(String teamId, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teams/$teamId/players'),
        headers: _getHeaders(accessToken),
      );

      final result = _handleResponse(response);
      if (result != null) {
        return List<Map<String, dynamic>>.from(result['data'] ?? []);
      }
      
      return [];
    } catch (e) {
      print('Error fetching team players: $e');
      return [];
    }
  }

  /// POST /teams/{id}/players - Add player to team (ghost player)
  static Future<Map<String, dynamic>?> addPlayerToTeam({
    required String teamId,
    required String displayName,
    String? role, // OWNER, COACH, PLAYER (defaults to PLAYER)
    required String accessToken,
  }) async {
    try {
      final body = {'display_name': displayName};
      if (role != null) body['role'] = role;

      final response = await http.post(
        Uri.parse('$baseUrl/teams/$teamId/players'),
        headers: _getHeaders(accessToken),
        body: json.encode(body),
      );

      final result = _handleResponse(response);
      return result?['data'];
    } catch (e) {
      print('Error adding player to team: $e');
      return null;
    }
  }

  /// DELETE /teams/{id}/players/{player_id} - Remove player from team
  static Future<bool> removePlayerFromTeam({
    required String teamId,
    required String playerId,
    required String accessToken,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/teams/$teamId/players/$playerId'),
        headers: _getHeaders(accessToken),
      );

      return _handleResponse(response) != null;
    } catch (e) {
      print('Error removing player from team: $e');
      return false;
    }
  }

  /// PUT /teams/{id}/players/{player_id}/role - Update player role
  static Future<bool> updatePlayerRole({
    required String teamId,
    required String playerId,
    required String role, // OWNER, COACH, PLAYER
    required String accessToken,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/teams/$teamId/players/$playerId/role'),
        headers: _getHeaders(accessToken),
        body: json.encode({'role': role}),
      );

      return _handleResponse(response) != null;
    } catch (e) {
      print('Error updating player role: $e');
      return false;
    }
  }

  /// POST /teams/{id}/players/{player_id}/link - Link ghost player to user
  static Future<bool> linkPlayerToUser({
    required String teamId,
    required String playerId,
    required String userId,
    required String accessToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/teams/$teamId/players/$playerId/link'),
        headers: _getHeaders(accessToken),
        body: json.encode({'user_id': userId}),
      );

      return _handleResponse(response) != null;
    } catch (e) {
      print('Error linking player to user: $e');
      return false;
    }
  }

  /// PUT /teams/{id}/transfer-ownership - Transfer team ownership
  static Future<bool> transferOwnership({
    required String teamId,
    required String newOwnerPlayerId,
    required String accessToken,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/teams/$teamId/transfer-ownership'),
        headers: _getHeaders(accessToken),
        body: json.encode({'new_owner_player_id': newOwnerPlayerId}),
      );

      return _handleResponse(response) != null;
    } catch (e) {
      print('Error transferring ownership: $e');
      return false;
    }
  }

  // ============================
  // GAME ENDPOINTS
  // ============================

  /// POST /teams/{id}/games - Create a new game
  static Future<Map<String, dynamic>?> createGame({
    required String teamId,
    required String opponent,
    String? startDatetimeUtc,
    String? timezone,
    String? park,
    String? field,
    required String accessToken,
  }) async {
    try {
      final body = <String, dynamic>{'opponent': opponent};
      
      if (startDatetimeUtc != null) body['start_datetime_utc'] = startDatetimeUtc;
      if (timezone != null) body['timezone'] = timezone;
      if (park != null) body['park'] = park;
      if (field != null) body['field'] = field;

      final response = await http.post(
        Uri.parse('$baseUrl/teams/$teamId/games'),
        headers: _getHeaders(accessToken),
        body: json.encode(body),
      );

      final result = _handleResponse(response);
      return result?['data'];
    } catch (e) {
      print('Error creating game: $e');
      return null;
    }
  }

  /// GET /teams/{id}/games - Get team games (paginated)
  static Future<List<Map<String, dynamic>>> getTeamGames(String teamId, String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teams/$teamId/games'),
        headers: _getHeaders(accessToken),
      );

      final result = _handleResponse(response);
      if (result != null && result['data'] != null) {
        // Backend returns {"games": [...], "last_evaluated_key": null} so we need to extract the games array
        final data = result['data'];
        if (data is Map<String, dynamic> && data.containsKey('games')) {
          return List<Map<String, dynamic>>.from(data['games'] ?? []);
        } else if (data is List) {
          // Fallback: if data is directly a list
          return List<Map<String, dynamic>>.from(data);
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching team games: $e');
      return [];
    }
  }

  /// GET /teams/{id}/games/{game_id} - Get game details
  static Future<Map<String, dynamic>?> getGame({
    required String teamId,
    required String gameId,
    required String accessToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teams/$teamId/games/$gameId'),
        headers: _getHeaders(accessToken),
      );

      final result = _handleResponse(response);
      return result?['data'];
    } catch (e) {
      print('Error fetching game: $e');
      return null;
    }
  }

  /// PUT /teams/{id}/games/{game_id} - Update game details
  static Future<bool> updateGame({
    required String teamId,
    required String gameId,
    String? opponent,
    String? startDatetimeUtc,
    String? timezone,
    String? park,
    String? field,
    required String accessToken,
  }) async {
    try {
      final body = <String, dynamic>{};
      
      if (opponent != null) body['opponent'] = opponent;
      if (startDatetimeUtc != null) body['start_datetime_utc'] = startDatetimeUtc;
      if (timezone != null) body['timezone'] = timezone;
      if (park != null) body['park'] = park;
      if (field != null) body['field'] = field;

      final response = await http.put(
        Uri.parse('$baseUrl/teams/$teamId/games/$gameId'),
        headers: _getHeaders(accessToken),
        body: json.encode(body),
      );

      return _handleResponse(response) != null;
    } catch (e) {
      print('Error updating game: $e');
      return false;
    }
  }

  /// DELETE /teams/{id}/games/{game_id} - Delete game
  static Future<bool> deleteGame({
    required String teamId,
    required String gameId,
    required String accessToken,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/teams/$teamId/games/$gameId'),
        headers: _getHeaders(accessToken),
      );

      return _handleResponse(response) != null;
    } catch (e) {
      print('Error deleting game: $e');
      return false;
    }
  }

  /// PUT /teams/{id}/games/{game_id}/lineup - Update game lineup
  static Future<bool> updateGameLineup({
    required String teamId,
    required String gameId,
    required List<Map<String, dynamic>> lineup,
    required String accessToken,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/teams/$teamId/games/$gameId/lineup'),
        headers: _getHeaders(accessToken),
        body: json.encode({'lineup': lineup}),
      );

      return _handleResponse(response) != null;
    } catch (e) {
      print('Error updating game lineup: $e');
      return false;
    }
  }
}