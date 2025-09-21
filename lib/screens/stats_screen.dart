import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - will replace with real data later
    final Map<String, dynamic> teamStats = {
      'record': '12-8',
      'winPercentage': '60.0%',
      'runsScored': 156,
      'runsAllowed': 142,
      'runDifferential': 14,
      'avgRunsPerGame': 7.8,
      'avgRunsAllowed': 7.1,
    };

    final List<Map<String, dynamic>> topPerformers = [
      {'name': 'Mike Johnson', 'stat': 'Batting Avg', 'value': '.425'},
      {'name': 'Sarah Williams', 'stat': 'HR', 'value': '8'},
      {'name': 'Tom Brown', 'stat': 'RBI', 'value': '24'},
      {'name': 'Lisa Davis', 'stat': 'Runs', 'value': '18'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Stats'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Overall Record
            _buildRecordCard(teamStats),
            const SizedBox(height: 16),
            
            // Offensive Stats
            Expanded(
              flex: 1,
              child: _buildStatsCard('Offense', [
                {'label': 'Runs Scored', 'value': teamStats['runsScored'].toString()},
                {'label': 'Avg per Game', 'value': teamStats['avgRunsPerGame'].toString()},
                {'label': 'Run Differential', 'value': '+${teamStats['runDifferential']}'},
              ]),
            ),
            const SizedBox(height: 16),
            
            // Defensive Stats
            Expanded(
              flex: 1,
              child: _buildStatsCard('Defense', [
                {'label': 'Runs Allowed', 'value': teamStats['runsAllowed'].toString()},
                {'label': 'Avg per Game', 'value': teamStats['avgRunsAllowed'].toString()},
                {'label': 'Win %', 'value': teamStats['winPercentage']},
              ]),
            ),
            const SizedBox(height: 16),
            
            // Top Performers
            Expanded(
              flex: 2,
              child: _buildTopPerformersCard(topPerformers),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> stats) {
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
                _buildRecordItem('12', 'Wins', Colors.green),
                _buildRecordItem('8', 'Losses', Colors.red),
                _buildRecordItem('60.0%', 'Win %', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
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

  Widget _buildStatsCard(String title, List<Map<String, String>> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: stats.map((stat) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stat['label']!,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          stat['value']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformersCard(List<Map<String, dynamic>> performers) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: performers.length,
                itemBuilder: (context, index) {
                  final performer = performers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                performer['name'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                performer['stat'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            performer['value'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
