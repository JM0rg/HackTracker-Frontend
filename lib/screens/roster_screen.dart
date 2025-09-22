import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/ui_helpers.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  String selectedRole = 'All';
  final List<String> roles = ['All', 'OWNER', 'COACH', 'PLAYER'];

  List<Map<String, dynamic>> _filterPlayers(List<Map<String, dynamic>> players) {
    if (selectedRole == 'All') return players;
    return players.where((p) => (p['role'] ?? 'PLAYER') == selectedRole).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TeamProvider, AuthProvider>(
      builder: (context, teamProvider, authProvider, child) {
        final players = _filterPlayers(teamProvider.teamPlayers);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Roster'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                tooltip: 'Batch Add Players',
                icon: const Icon(Icons.playlist_add),
                onPressed: () => _showBatchAddModal(teamProvider, authProvider),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildRoleFilter(),
                const SizedBox(height: 16),
                _buildRosterStats(players, teamProvider.teamPlayers),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return _buildPlayerCard(player, teamProvider, authProvider);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _buildOutgoingInvites(teamProvider, authProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: roles.length,
        itemBuilder: (context, index) {
          final role = roles[index];
          final isSelected = role == selectedRole;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(role),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedRole = role;
                  });
                }
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRosterStats(List<Map<String, dynamic>> filtered, List<Map<String, dynamic>> all) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(filtered.length.toString(), 'Players'),
            _buildStatItem(all.where((p) => (p['role'] ?? 'PLAYER') == 'OWNER').length.toString(), 'Owners'),
            _buildStatItem(all.where((p) => (p['role'] ?? 'PLAYER') == 'COACH').length.toString(), 'Coaches'),
            _buildStatItem(all.where((p) => (p['role'] ?? 'PLAYER') == 'PLAYER').length.toString(), 'Players'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> player, TeamProvider teamProvider, AuthProvider authProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Jersey Number
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getRoleColor(player['role'] ?? 'PLAYER'),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  (player['jersey'] ?? '').toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Player Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          player['display_name'] ?? player['name'] ?? 'Unknown Player',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(player['role'] ?? 'PLAYER').withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (player['role'] ?? 'PLAYER'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getRoleColor(player['role'] ?? 'PLAYER'),
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildPlayerMenu(player, teamProvider, authProvider),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Player ID: ${player['player_id'] ?? ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Right-side actions (kept empty for spacing consistency)
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'OWNER':
        return Colors.purple;
      case 'COACH':
        return Colors.blue;
      case 'PLAYER':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showBatchAddModal(TeamProvider teamProvider, AuthProvider authProvider) {
    final rows = <TextEditingController>[];
    void addRow() => rows.add(TextEditingController());
    addRow();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16, right: 16, top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Batch Add Players', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...rows.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TextField(
                        controller: e.value,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Player ${e.key + 1} name',
                          labelStyle: const TextStyle(color: Color(0xFF888888)),
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF444444)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () { setModalState(() { addRow(); }); },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Add Row', style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final names = rows.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
                          if (names.isEmpty) { Navigator.pop(ctx); return; }
                          final payload = names.map((n) => { 'display_name': n, 'role': 'PLAYER' }).toList();
                          final token = authProvider.accessToken;
                          if (token == null) { Navigator.pop(ctx); return; }
                          final ok = await teamProvider.addPlayersBatch(accessToken: token, players: payload);
                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(ok ? 'Players added' : 'Failed to add players'),
                            ));
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlayerMenu(Map<String, dynamic> player, TeamProvider teamProvider, AuthProvider authProvider) {
    final isGhost = (player['linked_user_id'] == null || (player['linked_user_id'] as String?)?.isEmpty == true);
    return PopupMenuButton<String>(
      onSelected: (val) async {
        if (val == 'invite') {
          _showInviteSheet(player, teamProvider, authProvider);
        }
      },
      itemBuilder: (ctx) => [
        if (isGhost)
          const PopupMenuItem(value: 'invite', child: Text('Invite via email')),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }

  void _showInviteSheet(Map<String, dynamic> player, TeamProvider teamProvider, AuthProvider authProvider) {
    final emailController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Invite Player', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    labelStyle: TextStyle(color: Color(0xFF888888)),
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                  ),
                  onSubmitted: (_) {},
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text.trim();
                      // Prefer ID token for endpoints that rely on email claim
                      final token = authProvider.idToken ?? authProvider.accessToken;
                      if (email.isEmpty || token == null) { Navigator.pop(ctx); return; }
                      final ok = await teamProvider.createInvite(
                        accessToken: token,
                        playerId: (player['player_id'] ?? '') as String,
                        email: email,
                      );
                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok ? 'Invite sent' : 'Failed to send invite'),
                        ));
                      }
                    },
                    child: const Text('Send Invite'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOutgoingInvites(TeamProvider teamProvider, AuthProvider authProvider) {
    if (teamProvider.teamInvites.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Outgoing Invites', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...teamProvider.teamInvites.map((inv) {
          return Card(
            child: ListTile(
              title: Text(inv['email'] ?? ''),
              subtitle: Text('Player: ${inv['player_id'] ?? ''} • Status: ${inv['status'] ?? ''}'),
              trailing: inv['status'] == 'PENDING' ? TextButton(
                onPressed: () async {
                  final token = authProvider.idToken ?? authProvider.accessToken;
                  if (token == null) return;
                  final ok = await teamProvider.revokeInvite(accessToken: token, token: (inv['token'] ?? '') as String);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok ? 'Invite revoked' : 'Failed to revoke invite'),
                    ));
                  }
                },
                child: const Text('Revoke'),
              ) : null,
            ),
          );
        }),
      ],
    );
  }
}
