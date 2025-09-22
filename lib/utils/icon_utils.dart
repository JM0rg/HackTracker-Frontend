import 'package:flutter/material.dart';

class IconUtils {
  /// Map of color codes to Color objects
  static const Map<String, Color> _colorMap = {
    'neon_green': Color(0xFF00FF88),
    'neon_blue': Color(0xFF0088FF),
    'neon_pink': Color(0xFFFF0088),
    'neon_orange': Color(0xFFFF8800),
    'neon_purple': Color(0xFF8800FF),
    'neon_yellow': Color(0xFFFFFF00),
    'neon_cyan': Color(0xFF00FFFF),
    'neon_red': Color(0xFFFF4444),
    'white': Color(0xFFFFFFFF),
    'gray': Color(0xFF888888),
  };
  /// Map of icon codes to IconData
  static const Map<String, IconData> _iconMap = {
    'sports_bar': Icons.sports_bar,
    'sports_baseball': Icons.sports_baseball,
    'emoji_events': Icons.emoji_events,
    'fitness_center': Icons.fitness_center,
    'attach_money': Icons.attach_money,
    'brightness_high': Icons.brightness_high,
    'directions_walk': Icons.directions_walk,
    'build': Icons.build,
    'cyclone': Icons.cyclone,
    'electric_bolt': Icons.electric_bolt,
    'engineering': Icons.engineering,
    'favorite': Icons.favorite,
    'local_fire_department': Icons.local_fire_department,
    'logo_dev': Icons.logo_dev,
    'network_wifi_2_bar': Icons.network_wifi_2_bar,
    'outdoor_grill': Icons.outdoor_grill,
    'park': Icons.park,
    'pets': Icons.pets,
    'pest_control': Icons.pest_control,
    'rocket_launch': Icons.rocket_launch,
    'square': Icons.square,
    'stars': Icons.stars,
    'stadium': Icons.stadium,
  };

  /// Convert icon code to IconData
  static IconData getIconFromCode(String iconCode) {
    return _iconMap[iconCode] ?? Icons.sports_baseball;
  }

  /// Convert color code to Color
  static Color getColorFromCode(String colorCode) {
    return _colorMap[colorCode] ?? const Color(0xFF00FF88);
  }


  /// Get icon name from code
  static String getIconName(String iconCode) {
    switch (iconCode) {
      case 'sports_bar': return 'Sports Bar';
      case 'sports_baseball': return 'Baseball';
      case 'emoji_events': return 'Trophy';
      case 'fitness_center': return 'Fitness';
      case 'attach_money': return 'Money';
      case 'brightness_high': return 'Sun';
      case 'directions_walk': return 'Walker';
      case 'build': return 'Tools';
      case 'cyclone': return 'Cyclone';
      case 'electric_bolt': return 'Lightning';
      case 'engineering': return 'Gear';
      case 'favorite': return 'Heart';
      case 'local_fire_department': return 'Fire';
      case 'logo_dev': return 'Dev';
      case 'network_wifi_2_bar': return 'Signal';
      case 'outdoor_grill': return 'Grill';
      case 'park': return 'Park';
      case 'pets': return 'Paw';
      case 'pest_control': return 'Bug';
      case 'rocket_launch': return 'Rocket';
      case 'square': return 'Square';
      case 'stars': return 'Stars';
      case 'stadium': return 'Stadium';
      default: return 'Baseball';
    }
  }

  /// Get all available team icons
  static List<Map<String, dynamic>> getAllTeamIcons() {
    return [
      // Curated Team Logo Icons
      {'icon': Icons.sports_bar, 'name': 'Sports Bar', 'code': 'sports_bar'},
      {'icon': Icons.sports_baseball, 'name': 'Baseball', 'code': 'sports_baseball'},
      {'icon': Icons.emoji_events, 'name': 'Trophy', 'code': 'emoji_events'},
      {'icon': Icons.fitness_center, 'name': 'Fitness', 'code': 'fitness_center'},
      {'icon': Icons.attach_money, 'name': 'Money', 'code': 'attach_money'},
      {'icon': Icons.brightness_high, 'name': 'Sun', 'code': 'brightness_high'},
      {'icon': Icons.directions_walk, 'name': 'Walker', 'code': 'directions_walk'},
      {'icon': Icons.build, 'name': 'Tools', 'code': 'build'},
      {'icon': Icons.cyclone, 'name': 'Cyclone', 'code': 'cyclone'},
      {'icon': Icons.electric_bolt, 'name': 'Lightning', 'code': 'electric_bolt'},
      {'icon': Icons.engineering, 'name': 'Gear', 'code': 'engineering'},
      {'icon': Icons.favorite, 'name': 'Heart', 'code': 'favorite'},
      {'icon': Icons.local_fire_department, 'name': 'Fire', 'code': 'local_fire_department'},
      {'icon': Icons.logo_dev, 'name': 'Dev', 'code': 'logo_dev'},
      {'icon': Icons.network_wifi_2_bar, 'name': 'Signal', 'code': 'network_wifi_2_bar'},
      {'icon': Icons.outdoor_grill, 'name': 'Grill', 'code': 'outdoor_grill'},
      {'icon': Icons.park, 'name': 'Park', 'code': 'park'},
      {'icon': Icons.pets, 'name': 'Paw', 'code': 'pets'},
      {'icon': Icons.pest_control, 'name': 'Bug', 'code': 'pest_control'},
      {'icon': Icons.rocket_launch, 'name': 'Rocket', 'code': 'rocket_launch'},
      {'icon': Icons.square, 'name': 'Square', 'code': 'square'},
      {'icon': Icons.stars, 'name': 'Stars', 'code': 'stars'},
      {'icon': Icons.stadium, 'name': 'Stadium', 'code': 'stadium'},
    ];
  }
}
