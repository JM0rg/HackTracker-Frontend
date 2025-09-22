import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_validators.dart';
import '../utils/icon_utils.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  
  // Get available team icons from utility
  late final List<Map<String, dynamic>> _teamIcons = IconUtils.getAllTeamIcons();
  String _selectedIconCode = 'sports_baseball'; // Default to baseball
  
  // Available team colors
  final List<Map<String, dynamic>> _teamColors = [
    {'color': const Color(0xFF00FF88), 'name': 'Neon Green', 'code': 'neon_green'},
    {'color': const Color(0xFF0088FF), 'name': 'Neon Blue', 'code': 'neon_blue'},
    {'color': const Color(0xFFFF0088), 'name': 'Neon Pink', 'code': 'neon_pink'},
    {'color': const Color(0xFFFF8800), 'name': 'Neon Orange', 'code': 'neon_orange'},
    {'color': const Color(0xFF8800FF), 'name': 'Neon Purple', 'code': 'neon_purple'},
    {'color': const Color(0xFFFFFF00), 'name': 'Neon Yellow', 'code': 'neon_yellow'},
    {'color': const Color(0xFF00FFFF), 'name': 'Neon Cyan', 'code': 'neon_cyan'},
    {'color': const Color(0xFFFF4444), 'name': 'Neon Red', 'code': 'neon_red'},
    {'color': const Color(0xFFFFFFFF), 'name': 'White', 'code': 'white'},
    {'color': const Color(0xFF888888), 'name': 'Gray', 'code': 'gray'},
  ];
  
  String _selectedColorCode = 'neon_green'; // Default to neon green

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  Color _getSelectedColor() {
    return _teamColors.firstWhere(
      (color) => color['code'] == _selectedColorCode,
      orElse: () => _teamColors.first,
    )['color'];
  }

  String _getSelectedColorName() {
    return _teamColors.firstWhere(
      (color) => color['code'] == _selectedColorCode,
      orElse: () => _teamColors.first,
    )['name'];
  }

  Widget _buildTeamIcon(String iconCode, Color color, double size) {
    return Icon(
      IconUtils.getIconFromCode(iconCode),
      color: color,
      size: size,
    );
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
          padding: const EdgeInsets.all(20),
          height: 650,
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Customize Team Logo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tektur',
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF888888)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF444444)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTeamIcon(_selectedIconCode, _getSelectedColor(), 32),
                    const SizedBox(width: 12),
                    Text(
                      '${IconUtils.getIconName(_selectedIconCode)} • ${_getSelectedColorName()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Color Selection (Compact)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Colors',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _teamColors.length,
                  itemBuilder: (context, index) {
                    final colorData = _teamColors[index];
                    final isSelected = _selectedColorCode == colorData['code'];
                    
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          _selectedColorCode = colorData['code'];
                        });
                        setState(() {}); // Update parent widget too
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: colorData['color'],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: isSelected 
                          ? const Icon(Icons.check, color: Colors.black, size: 16)
                          : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Icons Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Icons',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Icon Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _teamIcons.length,
                  itemBuilder: (context, index) {
                    final iconData = _teamIcons[index];
                    final isSelected = _selectedIconCode == iconData['code'];
                    
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          _selectedIconCode = iconData['code'];
                        });
                        setState(() {}); // Update parent widget too
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? _getSelectedColor().withOpacity(0.2) : const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? _getSelectedColor() : const Color(0xFF444444),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              iconData['icon'],
                              size: 20,
                              color: isSelected ? _getSelectedColor() : const Color(0xFF888888),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              iconData['name'],
                              style: TextStyle(
                                color: isSelected ? _getSelectedColor() : const Color(0xFF666666),
                                fontSize: 7,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
          },
        );
      },
    );
  }

  Future<void> _handleCreateTeam() async {
    print('🎯 CreateTeamScreen: Form submitted');
    
    // Show debug alert to confirm method is called
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('DEBUG: Create team method called'),
        duration: Duration(seconds: 1),
      ),
    );
    
    if (!_formKey.currentState!.validate()) {
      print('🎯 CreateTeamScreen: Form validation failed');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    
    final accessToken = authProvider.accessToken;
    final userId = authProvider.userId;
    
    print('🎯 CreateTeamScreen: AccessToken available: ${accessToken != null}');
    print('🎯 CreateTeamScreen: UserId: $userId');
    
    if (accessToken == null || userId == null) {
      print('🎯 CreateTeamScreen: Missing authentication data');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('🎯 CreateTeamScreen: Calling teamProvider.createTeam...');
    final success = await teamProvider.createTeam(
      teamName: _teamNameController.text.trim(),
      ownerId: userId!,
      accessToken: accessToken,
      iconCode: _selectedIconCode,
      colorCode: _selectedColorCode,
    );

    print('🎯 CreateTeamScreen: Team creation result: $success');
    
    if (success && mounted) {
      print('🎯 CreateTeamScreen: Success - navigating back');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Team "${_teamNameController.text.trim()}" created successfully!'),
          backgroundColor: const Color(0xFF00FF88),
        ),
      );
    } else if (mounted) {
      print('🎯 CreateTeamScreen: Failed - showing error message');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create team: ${teamProvider.error ?? "Unknown error"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Team',
          style: TextStyle(color: Colors.white, fontFamily: 'Tektur'),
        ),
      ),
      body: SafeArea(
        child: Consumer<TeamProvider>(
          builder: (context, teamProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Start Your Team',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Tektur',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a new softball team and invite your friends to join.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Team Name and Icon Row
                        Row(
                          children: [
                            // Icon Selector Button
                            GestureDetector(
                              onTap: _showIconPicker,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF333333)),
                                ),
                                child: _buildTeamIcon(_selectedIconCode, _getSelectedColor(), 28),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Team Name Field
                            Expanded(
                              child: TextFormField(
                                controller: _teamNameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Team Name',
                                  labelStyle: const TextStyle(color: Color(0xFF888888)),
                                  filled: true,
                                  fillColor: const Color(0xFF1E1E1E),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF333333)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF333333)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF00FF88)),
                                  ),
                                ),
                                validator: (value) => AuthValidators.validateRequiredText(value, 'team name'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Icon hint text
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 76), // Align with text field
                            child: Text(
                              'Tap icon to customize • ${IconUtils.getIconName(_selectedIconCode)} • ${_getSelectedColorName()}',
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Error Message
                        if (teamProvider.error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D1B1B),
                              border: Border.all(color: const Color(0xFFFF6B6B)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Color(0xFFFF6B6B), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    teamProvider.error!,
                                    style: const TextStyle(color: Color(0xFFFF6B6B)),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Create Team Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: teamProvider.isLoading ? null : _handleCreateTeam,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00FF88),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: teamProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                    ),
                                  )
                                : const Text(
                                    'Create Team',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Color(0xFF00FF88), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Team Owner Benefits',
                              style: TextStyle(
                                color: Color(0xFF00FF88),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Manage team roster and player roles\n'
                          '• Schedule games and update lineups\n'
                          '• Track team statistics and performance\n'
                          '• Generate team reports and insights',
                          style: TextStyle(color: Color(0xFF888888)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
