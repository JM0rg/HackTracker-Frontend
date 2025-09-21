import 'package:flutter/material.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  String selectedRole = 'All';
  
  final List<String> roles = ['All', 'OWNER', 'COACH', 'PLAYER'];

  // Mock data - will replace with real data later
  final List<Map<String, dynamic>> players = [
    {
      'name': 'Mike Johnson',
      'role': 'OWNER',
      'jersey': '7',
      'position': 'SS',
      'battingAvg': '.425',
      'rbi': 24,
    },
    {
      'name': 'Sarah Williams',
      'role': 'COACH',
      'jersey': '12',
      'position': 'C',
      'battingAvg': '.380',
      'rbi': 18,
    },
    {
      'name': 'Tom Brown',
      'role': 'PLAYER',
      'jersey': '23',
      'position': '3B',
      'battingAvg': '.365',
      'rbi': 22,
    },
    {
      'name': 'Lisa Davis',
      'role': 'PLAYER',
      'jersey': '9',
      'position': 'OF',
      'battingAvg': '.340',
      'rbi': 16,
    },
    {
      'name': 'Chris Wilson',
      'role': 'PLAYER',
      'jersey': '15',
      'position': '1B',
      'battingAvg': '.320',
      'rbi': 14,
    },
    {
      'name': 'Emma Garcia',
      'role': 'PLAYER',
      'jersey': '5',
      'position': '2B',
      'battingAvg': '.315',
      'rbi': 12,
    },
  ];

  List<Map<String, dynamic>> get filteredPlayers {
    if (selectedRole == 'All') return players;
    return players.where((player) => player['role'] == selectedRole).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roster'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showComingSoon('Add Player');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Role Filter
            _buildRoleFilter(),
            const SizedBox(height: 16),
            
            // Roster Stats
            _buildRosterStats(),
            const SizedBox(height: 16),
            
            // Players List
            Expanded(
              child: ListView.builder(
                itemCount: filteredPlayers.length,
                itemBuilder: (context, index) {
                  final player = filteredPlayers[index];
                  return _buildPlayerCard(player);
                },
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildRosterStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(filteredPlayers.length.toString(), 'Players'),
            _buildStatItem(
              players.where((p) => p['role'] == 'OWNER').length.toString(),
              'Owners'
            ),
            _buildStatItem(
              players.where((p) => p['role'] == 'COACH').length.toString(),
              'Coaches'
            ),
            _buildStatItem(
              players.where((p) => p['role'] == 'PLAYER').length.toString(),
              'Players'
            ),
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

  Widget _buildPlayerCard(Map<String, dynamic> player) {
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
                color: _getRoleColor(player['role']),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  player['jersey'],
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
                      Text(
                        player['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(player['role']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          player['role'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getRoleColor(player['role']),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Position: ${player['position']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Avg: ${player['battingAvg']}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'RBI: ${player['rbi']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
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
}
