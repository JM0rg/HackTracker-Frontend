import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - will replace with real data later
    final List<Map<String, dynamic>> games = [
      {
        'date': '2024-03-15',
        'opponent': 'Thunder Bolts',
        'result': 'Upcoming',
        'score': null,
        'location': 'Central Park Field 3',
      },
      {
        'date': '2024-03-10',
        'opponent': 'Lightning',
        'result': 'W',
        'score': '8-5',
        'location': 'Memorial Field',
      },
      {
        'date': '2024-03-08',
        'opponent': 'Storm',
        'result': 'L',
        'score': '3-7',
        'location': 'Riverside Park',
      },
      {
        'date': '2024-03-05',
        'opponent': 'Eagles',
        'result': 'W',
        'score': '12-4',
        'location': 'Central Park Field 1',
      },
      {
        'date': '2024-03-01',
        'opponent': 'Hawks',
        'result': 'L',
        'score': '6-9',
        'location': 'Memorial Field',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Team Stats Summary
            _buildTeamStatsHeader(),
            const SizedBox(height: 16),
            
            // Games List
            Expanded(
              child: ListView.builder(
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return _buildGameCard(game);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamStatsHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Season Record',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('12', 'Wins'),
                _buildStatColumn('8', 'Losses'),
                _buildStatColumn('156', 'Runs Scored'),
                _buildStatColumn('142', 'Runs Allowed'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
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

  Widget _buildGameCard(Map<String, dynamic> game) {
    final isUpcoming = game['result'] == 'Upcoming';
    final isWin = game['result'] == 'W';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Date column
            Container(
              width: 60,
              child: Column(
                children: [
                  Text(
                    _formatDate(game['date']),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getMonthDay(game['date']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Game info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isUpcoming)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'UPCOMING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isWin ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              game['result'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'vs ${game['opponent']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          game['location'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Score
            if (!isUpcoming) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isWin ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isWin ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  game['score'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isWin ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  String _getMonthDay(String dateString) {
    final date = DateTime.parse(dateString);
    return date.day.toString();
  }
}
