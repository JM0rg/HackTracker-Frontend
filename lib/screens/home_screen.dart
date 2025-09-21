import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock data for now - will replace with real data later
  String selectedTeamId = 'team-1';
  String selectedTeamName = 'Hack Attack';
  
  final List<Map<String, dynamic>> userTeams = [
    {'id': 'team-1', 'name': 'Hack Attack', 'emoji': '⚾'},
    {'id': 'team-2', 'name': 'Weekend Warriors', 'emoji': '🥎'},
    {'id': 'team-3', 'name': 'Eagles', 'emoji': '🦅'},
  ];

  final Map<String, dynamic> nextGame = {
    'opponent': 'Thunder Bolts',
    'date': '2024-03-15',
    'time': '7:00 PM',
    'location': 'Central Park Field 3',
    'isLive': false,
  };

  final Map<String, dynamic> teamStats = {
    'record': '12-8',
    'runsScored': 156,
    'runsAllowed': 142,
    'recentGames': ['W', 'L', 'W'],
  };

  String userRole = 'OWNER'; // Mock role - will get from backend
  String selectedStatType = 'Player'; // Mock stat type selection
  String selectedStatPeriod = 'Season'; // Mock stat period selection

  // Mock player stats data
  final Map<String, dynamic> playerStats = {
    'battingAvg': '.425',
    'rbi': 24,
    'runs': 18,
    'hits': 34,
    'atBats': 80,
    'doubles': 8,
    'triples': 2,
    'homeRuns': 3,
    'stolenBases': 5,
  };

  final List<String> statTypes = ['Team', 'Player'];
  final List<String> statPeriods = ['Season', 'Last Game', 'All-time'];

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
              await authProvider.signOut();
              // AuthWrapper will automatically show login screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team Selector - Fixed at top
            _buildTeamSelector(),
            const SizedBox(height: 16),
            
            // Next Game Card
            Expanded(
              flex: 2,
              child: _buildGameCard(),
            ),
            const SizedBox(height: 16),
            
            // Combined Stats - Fixed height
            Expanded(
              flex: 2,
              child: _buildStatsSummary(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSelector() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF00FF88), width: 1.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF88).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedTeamId,
            isExpanded: true,
            dropdownColor: const Color(0xFF0F0F0F),
            style: const TextStyle(
              color: Color(0xFF00FF88),
              fontSize: 16,
            ),
            items: userTeams.map((team) {
              return DropdownMenuItem<String>(
                value: team['id'],
                child: Row(
                  children: [
                    Text(
                      team['emoji'],
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      team['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF00FF88),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedTeamId = newValue;
                  selectedTeamName = userTeams.firstWhere((team) => team['id'] == newValue)['name'];
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFF0F0F0F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF333333), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nextGame['isLive'] ? 'Live Game' : 'Next Game',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: nextGame['isLive'] ? const Color(0xFFFF0088) : const Color(0xFF00FF88),
                  ),
                ),
                if (nextGame['isLive'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0088),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF0088).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${selectedTeamName} vs ${nextGame['opponent']}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0E0E0),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF00FF88)),
                const SizedBox(width: 8),
                Text(
                  '${nextGame['date']} at ${nextGame['time']}',
                  style: const TextStyle(color: Color(0xFFB0B0B0)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Color(0xFF0088FF)),
                const SizedBox(width: 8),
                Text(
                  nextGame['location'],
                  style: const TextStyle(color: Color(0xFFB0B0B0)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (userRole == 'OWNER' || userRole == 'COACH') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showComingSoon('Lineup Editor');
                      },
                      icon: const Icon(Icons.list_alt, color: Colors.black),
                      label: const Text('Lineup', style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF88),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showComingSoon('Stats Entry');
                    },
                    icon: const Icon(Icons.bar_chart, color: Colors.black),
                    label: const Text('Stats', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0088FF),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Card(
      elevation: 0,
      color: const Color(0xFF0F0F0F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF333333), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Stats',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selectedStatType == 'Team' ? const Color(0xFF00FF88) : const Color(0xFF0088FF),
                  ),
                ),
                const Spacer(),
                // Type selector (Team/Player)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedStatType == 'Team' ? const Color(0xFF00FF88) : const Color(0xFF0088FF), 
                      width: 1
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: PopupMenuButton<String>(
                    initialValue: selectedStatType,
                    offset: const Offset(0, 30), // Force dropdown to open downward
                    color: const Color(0xFF0F0F0F),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedStatType,
                          style: TextStyle(
                            color: selectedStatType == 'Team' ? const Color(0xFF00FF88) : const Color(0xFF0088FF),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: selectedStatType == 'Team' ? const Color(0xFF00FF88) : const Color(0xFF0088FF),
                          size: 16,
                        ),
                      ],
                    ),
                    itemBuilder: (BuildContext context) {
                      return statTypes.map((type) {
                        return PopupMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: TextStyle(
                              color: selectedStatType == 'Team' ? const Color(0xFF00FF88) : const Color(0xFF0088FF),
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList();
                    },
                    onSelected: (String newValue) {
                      setState(() {
                        selectedStatType = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Period selector (Season/Last Game/All-time)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedStatType == 'Team' ? const Color(0xFF00FF88) : const Color(0xFF0088FF), 
                      width: 1
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: PopupMenuButton<String>(
                    initialValue: selectedStatPeriod,
                    offset: const Offset(0, 30), // Force dropdown to open downward
                    color: const Color(0xFF0F0F0F),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedStatPeriod,
                          style: TextStyle(
                            color: selectedStatType == 'Team' ? const Color(0xFF00FF88) : const Color(0xFF0088FF),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: selectedStatType == 'Team' ? const Color(0xFF00FF88) : const Color(0xFF0088FF),
                          size: 16,
                        ),
                      ],
                    ),
                    itemBuilder: (BuildContext context) {
                      return statPeriods.map((period) {
                        return PopupMenuItem<String>(
                          value: period,
                          child: Text(
                            period,
                            style: TextStyle(
                              color: selectedStatType == 'Team' ? const Color(0xFF00FF88) : const Color(0xFF0088FF),
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList();
                    },
                    onSelected: (String newValue) {
                      setState(() {
                        selectedStatPeriod = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: selectedStatType == 'Team' ? _buildTeamStatsContent() : _buildPlayerStatsContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamStatsContent() {
    return Column(
      children: [
        // First row - main team stats
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem('Record', teamStats['record'], const Color(0xFF00FF88)),
              ),
              Expanded(
                child: _buildStatItem('Runs For', teamStats['runsScored'].toString(), const Color(0xFF00FF88)),
              ),
              Expanded(
                child: _buildStatItem('Runs Against', teamStats['runsAllowed'].toString(), const Color(0xFF00FF88)),
              ),
              Expanded(
                child: _buildStatItem('Diff', '${teamStats['runsScored'] - teamStats['runsAllowed']}', const Color(0xFF00FF88)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Second row - recent games
        Expanded(
          child: Row(
            children: [
              const Expanded(
                flex: 1,
                child: Text('Recent: ', style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14)),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: teamStats['recentGames'].map<Widget>((result) {
                    final isWin = result == 'W';
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isWin ? const Color(0xFF00FF88) : const Color(0xFFFF0088),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: (isWin ? const Color(0xFF00FF88) : const Color(0xFFFF0088)).withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          result,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerStatsContent() {
    return Column(
      children: [
        // First row - main stats
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem('Avg', playerStats['battingAvg'], const Color(0xFF0088FF)),
              ),
              Expanded(
                child: _buildStatItem('RBI', playerStats['rbi'].toString(), const Color(0xFF0088FF)),
              ),
              Expanded(
                child: _buildStatItem('Runs', playerStats['runs'].toString(), const Color(0xFF0088FF)),
              ),
              Expanded(
                child: _buildStatItem('Hits', playerStats['hits'].toString(), const Color(0xFF0088FF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Second row - additional stats
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem('2B', playerStats['doubles'].toString(), const Color(0xFF0088FF)),
              ),
              Expanded(
                child: _buildStatItem('3B', playerStats['triples'].toString(), const Color(0xFF0088FF)),
              ),
              Expanded(
                child: _buildStatItem('HR', playerStats['homeRuns'].toString(), const Color(0xFF0088FF)),
              ),
              Expanded(
                child: _buildStatItem('SB', playerStats['stolenBases'].toString(), const Color(0xFF0088FF)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
