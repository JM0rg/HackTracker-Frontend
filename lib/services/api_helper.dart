import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_exception.dart';

/// Helper class for API operations with reduced redundancy
class ApiHelper {
  static const String baseUrl = 'https://1bp6rtodo2.execute-api.us-east-1.amazonaws.com/hacktracker-test';
  
  /// Common headers for authenticated requests
  static Map<String, String> getHeaders(String authorizationHeader) {
    return {
      'Content-Type': 'application/json',
      'Authorization': authorizationHeader,
    };
  }

  /// Standard GET request helper
  static Future<T?> get<T>({
    required String endpoint,
    required String authorizationHeader,
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
        headers: getHeaders(authorizationHeader),
      );

      final data = _handleResponse<Map<String, dynamic>>(response, endpoint);
      if (data != null && parser != null) {
        return parser(data);
      }
      return data as T?;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException.fromError(
        endpoint: endpoint,
        error: 'GET request failed: $e',
      );
    }
  }

  /// Standard POST request helper
  static Future<T?> post<T>({
    required String endpoint,
    required String authorizationHeader,
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: getHeaders(authorizationHeader),
        body: json.encode(body),
      );

      final data = _handleResponse<Map<String, dynamic>>(response, endpoint);
      if (data != null && parser != null) {
        return parser(data);
      }
      return data as T?;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException.fromError(
        endpoint: endpoint,
        error: 'POST request failed: $e',
      );
    }
  }

  /// Standard PUT request helper
  static Future<T?> put<T>({
    required String endpoint,
    required String authorizationHeader,
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: getHeaders(authorizationHeader),
        body: json.encode(body),
      );

      final data = _handleResponse<Map<String, dynamic>>(response, endpoint);
      if (data != null && parser != null) {
        return parser(data);
      }
      return data as T?;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException.fromError(
        endpoint: endpoint,
        error: 'PUT request failed: $e',
      );
    }
  }

  /// Standard DELETE request helper
  static Future<bool> delete({
    required String endpoint,
    required String authorizationHeader,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: getHeaders(authorizationHeader),
      );

      _handleResponse<Map<String, dynamic>>(response, endpoint);
      return true; // If no exception thrown, operation succeeded
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException.fromError(
        endpoint: endpoint,
        error: 'DELETE request failed: $e',
      );
    }
  }

  /// Handle API response and extract data
  static T? _handleResponse<T>(http.Response response, String endpoint) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        
        // Normalize response handling - always return the actual data
        // Backend returns data directly, not wrapped in {"success": true, "data": {...}}
        return data as T?;
      } else {
        // Parse error response and throw structured exception
        Map<String, dynamic>? errorData;
        try {
          errorData = json.decode(response.body);
        } catch (_) {
          // If we can't parse the error response, use the raw body
        }
        
        throw ApiException.fromResponse(
          statusCode: response.statusCode,
          endpoint: endpoint,
          responseBody: response.body,
          responseData: errorData,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      // Parsing error
      throw ApiException.fromError(
        endpoint: endpoint,
        error: 'Failed to parse response: $e',
      );
    }
  }

  /// Extract data from response wrapper (legacy support)
  /// Note: This method is deprecated as responses are now normalized directly
  @Deprecated('Responses are now normalized directly in _handleResponse')
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
  static List<Map<String, dynamic>> extractTeams(dynamic result) {
    if (result == null) return [];
    
    List<Map<String, dynamic>> teams = [];
    
    if (result is Map<String, dynamic> && result.containsKey('teams')) {
      teams = List<Map<String, dynamic>>.from(result['teams'] ?? []);
    } else if (result is List) {
      teams = List<Map<String, dynamic>>.from(result);
    }
    
    return transformTeams(teams);
  }

  /// Extract games from various response formats  
  static List<Map<String, dynamic>> extractGames(dynamic result) {
    if (result == null) return [];
    
    if (result is Map<String, dynamic> && result.containsKey('games')) {
      return List<Map<String, dynamic>>.from(result['games'] ?? []);
    } else if (result is List) {
      return List<Map<String, dynamic>>.from(result);
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
