import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class TeamProvider with ChangeNotifier {
  List<Map<String, dynamic>> _userTeams = [];
  Map<String, dynamic>? _selectedTeam;
  List<Map<String, dynamic>> _teamGames = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get userTeams => _userTeams;
  Map<String, dynamic>? get selectedTeam => _selectedTeam;
  List<Map<String, dynamic>> get teamGames => _teamGames;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasTeams => _userTeams.isNotEmpty;

  /// Load user's teams
  Future<void> loadUserTeams(String userId, String accessToken) async {
    _setLoading(true);
    try {
      _userTeams = await ApiService.getUserTeams(userId, accessToken);
      
      // If user has teams, automatically select the first one
      if (_userTeams.isNotEmpty) {
        await selectTeam(_userTeams.first['id'], accessToken);
      } else {
        _selectedTeam = null;
        _teamGames = [];
      }
      
      _clearError();
    } catch (e) {
      _setError('Failed to load teams: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Select a team and load its data
  Future<void> selectTeam(String teamId, String accessToken) async {
    try {
      // Get team details
      final teamDetails = await ApiService.getTeam(teamId, accessToken);
      if (teamDetails != null) {
        _selectedTeam = teamDetails;
        
        // Load team games
        _teamGames = await ApiService.getTeamGames(teamId, accessToken);
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to load team data: $e');
    }
  }

  /// Create a new team
  Future<bool> createTeam({
    required String teamName,
    required String ownerId,
    required String accessToken,
    String? iconCode,
    String? colorCode,
  }) async {
    print('🏆 TeamProvider: Starting team creation for: $teamName, owner: $ownerId, icon: $iconCode, color: $colorCode');
    _setLoading(true);
    try {
      print('🏆 TeamProvider: Calling ApiService.createTeam...');
      final newTeam = await ApiService.createTeam(
        teamName: teamName,
        ownerId: ownerId,
        accessToken: accessToken,
        iconCode: iconCode,
        colorCode: colorCode,
      );
      
      print('🏆 TeamProvider: ApiService returned: $newTeam');
      
      if (newTeam != null) {
        print('🏆 TeamProvider: Team created successfully, adding to list');
        // Add the new team to the current list
        _userTeams.add(newTeam);
        // Select the new team if it has an ID
        final teamId = newTeam['id'];
        if (teamId != null) {
          await selectTeam(teamId, accessToken);
        }
        _clearError();
        print('🏆 TeamProvider: Team creation complete');
        return true;
      }
      
      print('🏆 TeamProvider: Team creation failed - newTeam is null');
      _setError('Failed to create team - server returned no data');
      return false;
    } catch (e) {
      print('🏆 TeamProvider: Exception during team creation: $e');
      _setError('Failed to create team: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get next upcoming game
  Map<String, dynamic>? get nextGame {
    if (_teamGames.isEmpty) return null;
    
    // Sort games by date and return the next one
    final now = DateTime.now();
    final upcomingGames = _teamGames.where((game) {
      if (game['start_datetime_utc'] != null) {
        final gameDate = DateTime.parse(game['start_datetime_utc']);
        return gameDate.isAfter(now);
      }
      return false;
    }).toList();
    
    if (upcomingGames.isNotEmpty) {
      upcomingGames.sort((a, b) {
        final dateA = DateTime.parse(a['start_datetime_utc']);
        final dateB = DateTime.parse(b['start_datetime_utc']);
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
    return _selectedTeam!['record'] ?? '0-0';
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all data (for logout)
  void clear() {
    _userTeams = [];
    _selectedTeam = null;
    _teamGames = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
