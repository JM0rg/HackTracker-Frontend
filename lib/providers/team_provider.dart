import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/api_helper.dart';
import '../utils/team_error_handler.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/invite.dart';
import 'auth_provider.dart';

class TeamProvider with ChangeNotifier {
  List<Team> _userTeams = [];
  Team? _selectedTeam;
  List<Game> _teamGames = [];
  List<Player> _teamPlayers = [];
  List<Invite> _teamInvites = [];
  bool _isLoading = false;
  String? _error;
  
  // Race condition protection
  String? _lastRequestedTeamId;

  // Getters
  List<Team> get userTeams => _userTeams;
  Team? get selectedTeam => _selectedTeam;
  List<Game> get teamGames => _teamGames;
  List<Player> get teamPlayers => _teamPlayers;
  List<Invite> get teamInvites => _teamInvites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasTeams => _userTeams.isNotEmpty;

  /// Batch state updates to reduce notifyListeners() calls
  void _updateState({bool? loading, String? error}) {
    bool hasChanges = false;
    
    if (loading != null && _isLoading != loading) {
      _isLoading = loading;
      hasChanges = true;
    }
    
    if (error != null && _error != error) {
      _error = error;
      hasChanges = true;
    } else if (error == null && _error != null) {
      _error = null;
      hasChanges = true;
    }
    
    if (hasChanges) {
      notifyListeners();
    }
  }

  /// Load user's teams
  Future<void> loadUserTeams(String userId, AuthProvider authProvider) async {
    _updateState(loading: true, error: null); // Clear errors at start
    try {
      final teamsData = await ApiService.getUserTeams(userId, authProvider);
      // ApiService.getUserTeams already returns transformed data via ApiHelper.extractTeams
      _userTeams = teamsData.map((teamData) => Team.fromJson(teamData)).toList();
      
      // If user has teams, automatically select the first one
      if (_userTeams.isNotEmpty) {
        await selectTeam(_userTeams.first.id, authProvider);
      } else {
        _selectedTeam = null;
        _teamGames = [];
        _teamPlayers = [];
        _teamInvites = [];
        notifyListeners();
      }
    } catch (e) {
      _updateState(error: TeamErrorHandler.getFriendlyErrorMessage(e.toString()));
    } finally {
      _updateState(loading: false);
    }
  }

  /// Select a team and load its data
  Future<void> selectTeam(String teamId, AuthProvider authProvider) async {
    // Race condition protection: ignore stale responses
    _lastRequestedTeamId = teamId;
    _updateState(error: null); // Clear errors at start
    
    try {
      // Get team details
      final teamDetails = await ApiService.getTeam(teamId, authProvider);
      
      // Check if this is still the requested team (race condition protection)
      if (_lastRequestedTeamId != teamId) {
        if (kDebugMode) {
          print('🏆 TeamProvider: Ignoring stale response for team $teamId (current: $_lastRequestedTeamId)');
        }
        return;
      }
      
      if (teamDetails != null) {
        // Use ApiHelper transformation for consistency
        final transformedTeam = ApiHelper.transformTeam(teamDetails);
        _selectedTeam = Team.fromJson(transformedTeam);
        
        // Load all team data in parallel for better performance
        final results = await Future.wait([
          ApiService.getTeamGames(teamId, authProvider),
          ApiService.getTeamPlayers(teamId, authProvider),
          ApiService.getTeamInvites(teamId: teamId, authProvider: authProvider),
        ]);
        
        // Check again for race condition after parallel calls
        if (_lastRequestedTeamId != teamId) {
          if (kDebugMode) {
            print('🏆 TeamProvider: Ignoring stale data for team $teamId (current: $_lastRequestedTeamId)');
          }
          return;
        }
        
        // Transform and update data with error handling for partial failures
        try {
          _teamGames = (results[0] as List).map((gameData) => Game.fromJson(gameData)).toList();
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ TeamProvider: Failed to parse games data: $e');
          }
          _teamGames = []; // Set empty list on parse failure
        }
        
        try {
          _teamPlayers = (results[1] as List).map((playerData) => Player.fromJson(playerData)).toList();
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ TeamProvider: Failed to parse players data: $e');
          }
          _teamPlayers = []; // Set empty list on parse failure
        }
        
        try {
          _teamInvites = (results[2] as List).map((inviteData) => Invite.fromJson(inviteData)).toList();
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ TeamProvider: Failed to parse invites data: $e');
          }
          _teamInvites = []; // Set empty list on parse failure
        }
        
        notifyListeners();
      }
    } catch (e) {
      // Only update error if this is still the requested team
      if (_lastRequestedTeamId == teamId) {
        _updateState(error: TeamErrorHandler.getFriendlyErrorMessage(e.toString()));
      }
    }
  }

  /// Create a new team
  Future<bool> createTeam({
    required String teamName,
    required String ownerId,
    required AuthProvider authProvider,
    String? iconCode,
    String? colorCode,
  }) async {
    _updateState(loading: true, error: null); // Clear errors at start
    try {
      final newTeamData = await ApiService.createTeam(
        teamName: teamName,
        ownerId: ownerId,
        authProvider: authProvider,
        iconCode: iconCode,
        colorCode: colorCode,
      );
      
      if (newTeamData != null) {
        // Always re-fetch from API after mutation to ensure data consistency
        await loadUserTeams(ownerId, authProvider);
        return true;
      }
      
      _updateState(error: 'Failed to create team - server returned no data');
      return false;
    } catch (e) {
      _updateState(error: TeamErrorHandler.getFriendlyErrorMessage(e.toString()));
      return false;
    } finally {
      _updateState(loading: false);
    }
  }

  /// Batch add ghost players
  Future<bool> addPlayersBatch({
    required AuthProvider authProvider,
    required List<Map<String, dynamic>> players,
  }) async {
    if (_selectedTeam == null) return false;
    _updateState(loading: true, error: null); // Clear errors at start
    try {
      final ok = await ApiService.addPlayersBatch(
        teamId: _selectedTeam!.id,
        players: players,
        authProvider: authProvider,
      );
      if (ok) {
        // Always re-fetch from API after mutation to ensure data consistency
        await selectTeam(_selectedTeam!.id, authProvider);
      }
      return ok;
    } catch (e) {
      _updateState(error: TeamErrorHandler.getFriendlyErrorMessage(e.toString()));
      return false;
    } finally {
      _updateState(loading: false);
    }
  }

  /// Create invite for a ghost player
  Future<bool> createInvite({
    required AuthProvider authProvider,
    required String playerId,
    required String email,
  }) async {
    if (_selectedTeam == null) return false;
    _updateState(loading: true, error: null); // Clear errors at start
    try {
      final res = await ApiService.createInvite(
        teamId: _selectedTeam!.id,
        playerId: playerId,
        email: email,
        authProvider: authProvider,
      );
      if (res != null) {
        // Always re-fetch from API after mutation to ensure data consistency
        await selectTeam(_selectedTeam!.id, authProvider);
        return true;
      }
      _updateState(error: 'Failed to create invite');
      return false;
    } catch (e) {
      _updateState(error: TeamErrorHandler.getFriendlyErrorMessage(e.toString()));
      return false;
    } finally {
      _updateState(loading: false);
    }
  }

  /// Revoke outgoing invite
  Future<bool> revokeInvite({
    required AuthProvider authProvider,
    required String token,
  }) async {
    _updateState(loading: true, error: null); // Clear errors at start
    try {
      final ok = await ApiService.revokeInvite(token: token, authProvider: authProvider);
      if (ok && _selectedTeam != null) {
        // Always re-fetch from API after mutation to ensure data consistency
        await selectTeam(_selectedTeam!.id, authProvider);
      }
      return ok;
    } catch (e) {
      _updateState(error: TeamErrorHandler.getFriendlyErrorMessage(e.toString()));
      return false;
    } finally {
      _updateState(loading: false);
    }
  }

  /// Get next upcoming game
  Game? get nextGame {
    if (_teamGames.isEmpty) return null;
    
    // Sort games by date and return the next one
    final now = DateTime.now();
    final upcomingGames = _teamGames.where((game) {
      if (game.startDateTimeUtc != null) {
        return game.startDateTimeUtc!.isAfter(now);
      }
      return false;
    }).toList();
    
    if (upcomingGames.isNotEmpty) {
      upcomingGames.sort((a, b) {
        // Use tryParse for null safety
        final dateA = a.startDateTimeUtc;
        final dateB = b.startDateTimeUtc;
        
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        
        return dateA.compareTo(dateB);
      });
      return upcomingGames.first;
    }
    
    return null;
  }

  /// Get team record (wins-losses)
  String get teamRecord {
    if (_selectedTeam == null) return '0-0';
    
    // This would come from team stats in the backend
    // For now, return a placeholder
    return _selectedTeam!.record ?? '0-0';
  }

  /// Clear all data (for logout)
  void clear() {
    _userTeams = [];
    _selectedTeam = null;
    _teamGames = [];
    _teamPlayers = [];
    _teamInvites = [];
    _error = null;
    _isLoading = false;
    _lastRequestedTeamId = null; // Reset race condition protection
    notifyListeners();
  }
}
