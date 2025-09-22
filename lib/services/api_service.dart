import 'api_helper.dart';
import '../providers/auth_provider.dart';

/// Comprehensive API service covering all HackTracker backend endpoints
class ApiService {

  // ============================
  // USER ENDPOINTS
  // ============================

  /// GET /users/{id} - Get user by ID
  static Future<Map<String, dynamic>?> getUser(String userId, AuthProvider authProvider) async {
    final authHeader = await authProvider.getAuthorizationHeader();
    if (authHeader == null) return null;
    
    final result = await ApiHelper.get<Map<String, dynamic>>(
      endpoint: '/users/$userId',
      authorizationHeader: authHeader,
    );
    return ApiHelper.extractData(result);
  }

  /// GET /users/{id}?email={email} - Get user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String userId, String email, String accessToken) async {
    final result = await ApiHelper.get<Map<String, dynamic>>(
      endpoint: '/users/$userId',
      accessToken: accessToken,
      queryParams: {'email': email},
    );
    return ApiHelper.extractData(result);
  }

  /// PUT /users/{id} - Update user profile
  static Future<bool> updateUser({
    required String userId,
    String? firstName,
    String? lastName,
    required String accessToken,
  }) async {
    final body = ApiHelper.buildRequestBody({
      'first_name': firstName,
      'last_name': lastName,
    });

    final result = await ApiHelper.put(
      endpoint: '/users/$userId',
      accessToken: accessToken,
      body: body,
    );
    
    return result != null;
  }

  /// DELETE /users/{id} - Delete user account
  static Future<bool> deleteUser(String userId, String accessToken) async {
    return await ApiHelper.delete(
      endpoint: '/users/$userId',
      accessToken: accessToken,
    );
  }

  /// GET /users/{id}/teams - Get user's teams
  static Future<List<Map<String, dynamic>>> getUserTeams(String userId, String accessToken) async {
    final result = await ApiHelper.get<Map<String, dynamic>>(
      endpoint: '/users/$userId/teams',
      accessToken: accessToken,
    );
    return ApiHelper.extractTeams(result);
  }

  // ============================
  // TEAM ENDPOINTS
  // ============================

  /// POST /teams - Create a new team
  static Future<Map<String, dynamic>?> createTeam({
    required String teamName,
    required String ownerId,
    required String accessToken,
    String? iconCode,
    String? colorCode,
  }) async {
    final body = ApiHelper.buildRequestBody({
      'team_name': teamName,
      'owner_id': ownerId,
      'icon_code': iconCode,
      'color_code': colorCode,
    });

    final result = await ApiHelper.post<Map<String, dynamic>>(
      endpoint: '/teams',
      accessToken: accessToken,
      body: body,
    );
    
    // For team creation, return the team object from the response
    if (result != null && result['data'] != null) {
      final team = result['data']['team'];
      if (team != null) {
        return ApiHelper.transformTeam(team);
      }
    }
    
    return null;
  }

  /// GET /teams/{id} - Get team details
  static Future<Map<String, dynamic>?> getTeam(String teamId, String accessToken) async {
    final result = await ApiHelper.get<Map<String, dynamic>>(
      endpoint: '/teams/$teamId',
      accessToken: accessToken,
    );
    
    final data = ApiHelper.extractData(result);
    return data != null ? ApiHelper.transformTeam(data) : null;
  }

  /// PUT /teams/{id} - Update team details
  static Future<bool> updateTeam({
    required String teamId,
    required String teamName,
    required String accessToken,
  }) async {
    final result = await ApiHelper.put(
      endpoint: '/teams/$teamId',
      accessToken: accessToken,
      body: {'name': teamName},
    );
    return result != null;
  }

  /// DELETE /teams/{id} - Delete team (cascading delete)
  static Future<bool> deleteTeam(String teamId, String accessToken) async {
    return await ApiHelper.delete(
      endpoint: '/teams/$teamId',
      accessToken: accessToken,
    );
  }

  // ============================
  // TEAM PLAYER ENDPOINTS (Unified Player Model)
  // ============================

  /// GET /teams/{id}/players - Get team players
  static Future<List<Map<String, dynamic>>> getTeamPlayers(String teamId, String accessToken) async {
    final result = await ApiHelper.get<dynamic>(
      endpoint: '/teams/$teamId/players',
      accessToken: accessToken,
    );
    final data = ApiHelper.extractData<dynamic>(result);
    if (data == null) return [];
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    if (data is Map<String, dynamic>) {
      final players = data['players'];
      if (players is List) {
        return List<Map<String, dynamic>>.from(players);
      }
    }
    return [];
  }

  /// POST /teams/{id}/players - Add player to team (ghost player)
  static Future<Map<String, dynamic>?> addPlayerToTeam({
    required String teamId,
    required String displayName,
    String? role, // OWNER, COACH, PLAYER (defaults to PLAYER)
    required String accessToken,
  }) async {
    final body = ApiHelper.buildRequestBody({
      'display_name': displayName,
      'role': role,
    });
    final result = await ApiHelper.post<Map<String, dynamic>>(
      endpoint: '/teams/$teamId/players',
      accessToken: accessToken,
      body: body,
    );
    return ApiHelper.extractData(result);
  }

  /// DELETE /teams/{id}/players/{player_id} - Remove player from team
  static Future<bool> removePlayerFromTeam({
    required String teamId,
    required String playerId,
    required String accessToken,
  }) async {
    return await ApiHelper.delete(
      endpoint: '/teams/$teamId/players/$playerId',
      accessToken: accessToken,
    );
  }

  /// PUT /teams/{id}/players/{player_id}/role - Update player role
  static Future<bool> updatePlayerRole({
    required String teamId,
    required String playerId,
    required String role, // OWNER, COACH, PLAYER
    required String accessToken,
  }) async {
    final result = await ApiHelper.put(
      endpoint: '/teams/$teamId/players/$playerId/role',
      accessToken: accessToken,
      body: {'role': role},
    );
    return result != null;
  }

  /// POST /teams/{id}/players/{player_id}/link - Link ghost player to user
  static Future<bool> linkPlayerToUser({
    required String teamId,
    required String playerId,
    required String userId,
    required String accessToken,
  }) async {
    final result = await ApiHelper.post(
      endpoint: '/teams/$teamId/players/$playerId/link',
      accessToken: accessToken,
      body: {'user_id': userId},
    );
    return result != null;
  }

  /// PUT /teams/{id}/transfer-ownership - Transfer team ownership
  static Future<bool> transferOwnership({
    required String teamId,
    required String newOwnerPlayerId,
    required String accessToken,
  }) async {
    final result = await ApiHelper.put(
      endpoint: '/teams/$teamId/transfer-ownership',
      accessToken: accessToken,
      body: {'new_owner_player_id': newOwnerPlayerId},
    );
    return result != null;
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
    final body = ApiHelper.buildRequestBody({
      'opponent': opponent,
      'start_datetime_utc': startDatetimeUtc,
      'timezone': timezone,
      'park': park,
      'field': field,
    });
    final result = await ApiHelper.post<Map<String, dynamic>>(
      endpoint: '/teams/$teamId/games',
      accessToken: accessToken,
      body: body,
    );
    return ApiHelper.extractData(result);
  }

  /// GET /teams/{id}/games - Get team games (paginated)
  static Future<List<Map<String, dynamic>>> getTeamGames(String teamId, String accessToken) async {
    final result = await ApiHelper.get<Map<String, dynamic>>(
      endpoint: '/teams/$teamId/games',
      accessToken: accessToken,
    );
    return ApiHelper.extractGames(result);
  }

  /// GET /teams/{id}/games/{game_id} - Get game details
  static Future<Map<String, dynamic>?> getGame({
    required String teamId,
    required String gameId,
    required String accessToken,
  }) async {
    final result = await ApiHelper.get<Map<String, dynamic>>(
      endpoint: '/teams/$teamId/games/$gameId',
      accessToken: accessToken,
    );
    return ApiHelper.extractData(result);
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
    final body = ApiHelper.buildRequestBody({
      'opponent': opponent,
      'start_datetime_utc': startDatetimeUtc,
      'timezone': timezone,
      'park': park,
      'field': field,
    });
    final result = await ApiHelper.put(
      endpoint: '/teams/$teamId/games/$gameId',
      accessToken: accessToken,
      body: body,
    );
    return result != null;
  }

  /// DELETE /teams/{id}/games/{game_id} - Delete game
  static Future<bool> deleteGame({
    required String teamId,
    required String gameId,
    required String accessToken,
  }) async {
    return await ApiHelper.delete(
      endpoint: '/teams/$teamId/games/$gameId',
      accessToken: accessToken,
    );
  }

  /// PUT /teams/{id}/games/{game_id}/lineup - Update game lineup
  static Future<bool> updateGameLineup({
    required String teamId,
    required String gameId,
    required List<Map<String, dynamic>> lineup,
    required String accessToken,
  }) async {
    final result = await ApiHelper.put(
      endpoint: '/teams/$teamId/games/$gameId/lineup',
      accessToken: accessToken,
      body: {'lineup': lineup},
    );
    return result != null;
  }

  // ============================
  // INVITES & BATCH ROSTER ENDPOINTS
  // ============================

  /// POST /teams/{id}/players/batch - Batch add ghost players
  static Future<bool> addPlayersBatch({
    required String teamId,
    required List<Map<String, dynamic>> players, // [{display_name, role?}]
    required String accessToken,
  }) async {
    final result = await ApiHelper.post(
      endpoint: '/teams/$teamId/players/batch',
      accessToken: accessToken,
      body: { 'players': players },
    );
    return result != null;
  }

  /// POST /teams/{id}/invites - Create an invite for a ghost player
  static Future<Map<String, dynamic>?> createInvite({
    required String teamId,
    required String playerId,
    required String email,
    required String accessToken,
  }) async {
    final result = await ApiHelper.post<Map<String, dynamic>>(
      endpoint: '/teams/$teamId/invites',
      accessToken: accessToken,
      body: { 'player_id': playerId, 'email': email },
    );
    return ApiHelper.extractData(result);
  }

  /// GET /teams/{id}/invites - List outgoing invites for a team
  static Future<List<Map<String, dynamic>>> getTeamInvites({
    required String teamId,
    required String accessToken,
  }) async {
    final result = await ApiHelper.get<Map<String, dynamic>>(
      endpoint: '/teams/$teamId/invites',
      accessToken: accessToken,
    );
    final data = ApiHelper.extractData<Map<String, dynamic>>(result);
    if (data == null) return [];
    final invites = data['invites'];
    if (invites is List) {
      return List<Map<String, dynamic>>.from(invites);
    }
    return [];
  }

  /// GET /invites - List incoming invites for current user
  static Future<List<Map<String, dynamic>>> getIncomingInvites({
    required String accessToken,
  }) async {
    final result = await ApiHelper.get<Map<String, dynamic>>(
      endpoint: '/invites',
      accessToken: accessToken,
    );
    final data = ApiHelper.extractData<Map<String, dynamic>>(result);
    if (data == null) return [];
    final invites = data['invites'];
    if (invites is List) {
      return List<Map<String, dynamic>>.from(invites);
    }
    return [];
  }

  /// POST /invites/{token}/accept - Accept invite
  static Future<bool> acceptInvite({
    required String token,
    required String accessToken,
  }) async {
    final result = await ApiHelper.post(
      endpoint: '/invites/$token/accept',
      accessToken: accessToken,
      body: {},
    );
    return result != null;
  }

  /// POST /invites/{token}/decline - Decline invite
  static Future<bool> declineInvite({
    required String token,
    required String accessToken,
  }) async {
    final result = await ApiHelper.post(
      endpoint: '/invites/$token/decline',
      accessToken: accessToken,
      body: {},
    );
    return result != null;
  }

  /// POST /invites/{token}/revoke - Revoke outgoing invite
  static Future<bool> revokeInvite({
    required String token,
    required String accessToken,
  }) async {
    final result = await ApiHelper.post(
      endpoint: '/invites/$token/revoke',
      accessToken: accessToken,
      body: {},
    );
    return result != null;
  }
}