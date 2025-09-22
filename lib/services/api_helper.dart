import 'dart:convert';
import 'package:http/http.dart' as http;

/// Helper class for API operations with reduced redundancy
class ApiHelper {
  static const String baseUrl = 'https://1bp6rtodo2.execute-api.us-east-1.amazonaws.com/hacktracker-test';
  
  /// Common headers for authenticated requests
  static Map<String, String> getHeaders(String accessToken) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  /// Standard GET request helper
  static Future<T?> get<T>({
    required String endpoint,
    required String accessToken,
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      String url = '$baseUrl$endpoint';
      if (queryParams != null && queryParams.isNotEmpty) {
        final queryString = Uri(queryParameters: queryParams).query;
        url += '?$queryString';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: getHeaders(accessToken),
      );

      final data = _handleResponse(response);
      if (data != null && parser != null) {
        return parser(data);
      }
      return data as T?;
    } catch (e) {
      print('API GET Error [$endpoint]: $e');
      return null;
    }
  }

  /// Standard POST request helper
  static Future<T?> post<T>({
    required String endpoint,
    required String accessToken,
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: getHeaders(accessToken),
        body: json.encode(body),
      );

      final data = _handleResponse(response);
      if (data != null && parser != null) {
        return parser(data);
      }
      return data as T?;
    } catch (e) {
      print('API POST Error [$endpoint]: $e');
      return null;
    }
  }

  /// Standard PUT request helper
  static Future<T?> put<T>({
    required String endpoint,
    required String accessToken,
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: getHeaders(accessToken),
        body: json.encode(body),
      );

      final data = _handleResponse(response);
      if (data != null && parser != null) {
        return parser(data);
      }
      return data as T?;
    } catch (e) {
      print('API PUT Error [$endpoint]: $e');
      return null;
    }
  }

  /// Standard DELETE request helper
  static Future<bool> delete({
    required String endpoint,
    required String accessToken,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: getHeaders(accessToken),
      );

      return _handleResponse(response) != null;
    } catch (e) {
      print('API DELETE Error [$endpoint]: $e');
      return false;
    }
  }

  /// Handle API response and extract data
  static Map<String, dynamic>? _handleResponse(http.Response response) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        
        // Backend returns data directly, not wrapped in {"success": true, "data": {...}}
        // So we'll wrap it ourselves for consistency
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorData = json.decode(response.body);
        print('API Error ${response.statusCode}: ${errorData['error'] ?? errorData}');
      }
      return null;
    } catch (e) {
      print('Error parsing response: $e');
      return null;
    }
  }

  /// Extract data from response wrapper
  static T? extractData<T>(Map<String, dynamic>? response) {
    if (response != null && response['success'] == true) {
      return response['data'] as T?;
    }
    return null;
  }

  /// Transform team data to frontend format
  static Map<String, dynamic> transformTeam(Map<String, dynamic> team) {
    return {
      'id': team['PK']?.toString().replaceFirst('TEAM#', '') ?? '',
      'name': team['team_name'] ?? 'Unknown Team',
      'emoji': team['emoji'] ?? '⚾',
      'icon_code': team['icon_code'] ?? 'sports_baseball',
      'color_code': team['color_code'] ?? 'neon_green',
      'created_at': team['created_at'],
      'owner_id': team['owner_id'],
    };
  }

  /// Transform list of teams
  static List<Map<String, dynamic>> transformTeams(List<dynamic> teams) {
    return teams.map((team) => transformTeam(team as Map<String, dynamic>)).toList();
  }

  /// Extract teams from various response formats
  static List<Map<String, dynamic>> extractTeams(Map<String, dynamic>? result) {
    if (result == null || result['data'] == null) return [];
    
    final data = result['data'];
    List<Map<String, dynamic>> teams = [];
    
    if (data is Map<String, dynamic> && data.containsKey('teams')) {
      teams = List<Map<String, dynamic>>.from(data['teams'] ?? []);
    } else if (data is List) {
      teams = List<Map<String, dynamic>>.from(data);
    }
    
    return transformTeams(teams);
  }

  /// Extract games from various response formats  
  static List<Map<String, dynamic>> extractGames(Map<String, dynamic>? result) {
    if (result == null || result['data'] == null) return [];
    
    final data = result['data'];
    if (data is Map<String, dynamic> && data.containsKey('games')) {
      return List<Map<String, dynamic>>.from(data['games'] ?? []);
    } else if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    
    return [];
  }

  /// Build request body with optional fields
  static Map<String, dynamic> buildRequestBody(Map<String, dynamic?> fields) {
    final body = <String, dynamic>{};
    fields.forEach((key, value) {
      if (value != null) {
        body[key] = value;
      }
    });
    return body;
  }
}
