import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/auth_validators.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
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
            return Padding(
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
                        // Team Name Field
                        TextFormField(
                          controller: _teamNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Team Name',
                            labelStyle: const TextStyle(color: Color(0xFF888888)),
                            prefixIcon: const Icon(Icons.sports_baseball, color: Color(0xFF888888)),
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

                  const Spacer(),

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
