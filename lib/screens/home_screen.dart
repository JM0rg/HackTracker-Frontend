import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/team_provider.dart';
import 'create_team_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedStatType = 'Player';
  String selectedStatPeriod = 'Season';

  @override
  void initState() {
    super.initState();
    // Load user teams when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    
    final accessToken = authProvider.accessToken;
    final userId = authProvider.userId;
    
    if (accessToken != null && userId != null) {
      await teamProvider.loadUserTeams(userId, accessToken);
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to profile
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final teamProvider = Provider.of<TeamProvider>(context, listen: false);
              teamProvider.clear(); // Clear team data on logout
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer2<TeamProvider, AuthProvider>(
          builder: (context, teamProvider, authProvider, child) {
            if (teamProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF88)),
                ),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team Selector or No Teams State
                  if (teamProvider.hasTeams) ...[
                    _buildTeamSelector(teamProvider),
                    const SizedBox(height: 16),
                    _buildNextGameCard(teamProvider),
                    const SizedBox(height: 16),
                    _buildStatsCard(teamProvider),
                  ] else ...[
                    _buildNoTeamsState(),
                    const SizedBox(height: 16),
                    _buildEmptyStatsCard(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTeamSelector(TeamProvider teamProvider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: teamProvider.selectedTeam?['id'],
            hint: const Text(
              'Select Team',
              style: TextStyle(color: Color(0xFF888888)),
            ),
            dropdownColor: const Color(0xFF1E1E1E),
            style: const TextStyle(color: Colors.white),
            items: teamProvider.userTeams.map<DropdownMenuItem<String>>((team) {
              return DropdownMenuItem<String>(
                value: team['id'],
                child: Row(
                  children: [
                    Text(team['emoji'] ?? '⚾'),
                    const SizedBox(width: 8),
                    Text(team['name'] ?? 'Unknown Team'),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? teamId) async {
              if (teamId != null) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final accessToken = authProvider.accessToken;
                if (accessToken != null) {
                  await teamProvider.selectTeam(teamId, accessToken);
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNoTeamsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.sports_baseball,
            size: 64,
            color: Color(0xFF888888),
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to HackTracker!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Tektur',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get started by creating a new team or joining an existing one.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateTeamScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Create Your First Team',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF444444)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF888888), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Team invites coming soon! For now, create a team and add players manually.',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextGameCard(TeamProvider teamProvider) {
    final nextGame = teamProvider.nextGame;
    
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Next Game',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00FF88),
              ),
            ),
            const SizedBox(height: 12),
            if (nextGame != null) ...[
              Text(
                'vs ${nextGame['opponent'] ?? 'TBD'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatGameDate(nextGame['start_datetime_utc'])}',
                style: const TextStyle(color: Color(0xFF888888)),
              ),
              Text(
                '${nextGame['park'] ?? 'TBD'} - ${nextGame['field'] ?? 'TBD'}',
                style: const TextStyle(color: Color(0xFF888888)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to lineup screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('📋 Lineup'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to game stats screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('📊 Stats'),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'No upcoming games scheduled',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to schedule game screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF88),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Schedule Game'),
              ),
            ],
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(TeamProvider teamProvider) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00FF88),
                  ),
                ),
                Row(
                  children: [
                    _buildStatsDropdown(
                      value: selectedStatType,
                      items: ['Player', 'Team'],
                      onChanged: (value) {
                        setState(() {
                          selectedStatType = value!;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildStatsDropdown(
                      value: selectedStatPeriod,
                      items: ['Season', 'All-time', 'Last Game'],
                      onChanged: (value) {
                        setState(() {
                          selectedStatPeriod = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (selectedStatType == 'Player') 
              _buildPlayerStats(teamProvider)
            else 
              _buildTeamStats(teamProvider),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStatsCard() {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00FF88),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 48,
                    color: const Color(0xFF888888).withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No stats available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Join a team to start tracking your performance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerStats(TeamProvider teamProvider) {
    // Mock player stats - replace with real data from backend
    return Column(
      children: [
        Row(
          children: [
            _buildStatItem('AVG', '.000', Colors.blue),
            _buildStatItem('H', '0', Colors.green),
            _buildStatItem('R', '0', Colors.orange),
            _buildStatItem('RBI', '0', Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamStats(TeamProvider teamProvider) {
    return Column(
      children: [
        Row(
          children: [
            _buildStatItem('Record', teamProvider.teamRecord, Colors.green),
            _buildStatItem('RS', '0', Colors.blue),
            _buildStatItem('RA', '0', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF333333),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _formatGameDate(String? dateTimeUtc) {
    if (dateTimeUtc == null) return 'TBD';
    
    try {
      final dateTime = DateTime.parse(dateTimeUtc);
      final local = dateTime.toLocal();
      return '${local.month}/${local.day} at ${_formatTime(local)}';
    } catch (e) {
      return 'TBD';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }
}