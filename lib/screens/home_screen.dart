import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/team_provider.dart';
import '../utils/icon_utils.dart';
import '../utils/ui_helpers.dart';
import '../utils/theme_constants.dart';
import '../widgets/team_icon_widget.dart';
import '../widgets/app_card.dart';
import '../widgets/stat_item.dart';
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
    
    final userId = authProvider.userId;
    
    if (userId != null) {
      await teamProvider.loadUserTeams(userId, authProvider);
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
              print('🔐 HomeScreen: Sign out tapped - clearing team state and calling AuthProvider.signOut');
              teamProvider.clear(); // Clear team data on logout
              await authProvider.signOut();
              print('🔐 HomeScreen: Sign out flow completed');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer2<TeamProvider, AuthProvider>(
          builder: (context, teamProvider, authProvider, child) {
          // Show profile validation state
          if (authProvider.isProfileValidating) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Setting up your account...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we verify your profile.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
          
          if (teamProvider.isLoading) {
            return UIHelpers.buildLoadingIndicator();
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
                    TeamIconWidget.withDefaults(
                      iconCode: team['icon_code'],
                      colorCode: team['color_code'],
                    ),
                    const SizedBox(width: 8),
                    Text(team['name'] ?? 'Unknown Team'),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? teamId) async {
              if (teamId != null) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await teamProvider.selectTeam(teamId, authProvider);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNoTeamsState() {
    return UIHelpers.buildCard(
      padding: const EdgeInsets.all(UIHelpers.paddingLarge),
      child: Column(
        children: [
          Icon(
            Icons.sports_baseball,
            size: 64,
            color: ThemeConstants.textSecondary,
          ),
          const SizedBox(height: UIHelpers.paddingMedium),
          Text('Welcome to HackTracker!', style: ThemeConstants.headerSmall),
          const SizedBox(height: UIHelpers.paddingSmall),
          Text(
            'Get started by creating a new team or joining an existing one.',
            textAlign: TextAlign.center,
            style: ThemeConstants.subtitle,
          ),
          const SizedBox(height: UIHelpers.paddingLarge),
          UIHelpers.buildPrimaryButton(
            text: 'Create Your First Team',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateTeamScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: UIHelpers.paddingMedium),
          UIHelpers.buildInfoCard(
            title: '',
            content: 'Team invites coming soon! For now, create a team and add players manually.',
            icon: Icons.info_outline,
            iconColor: ThemeConstants.textSecondary,
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
                UIHelpers.formatGameDateTime(nextGame['start_datetime_utc']),
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
      color: ThemeConstants.surfacePrimary,
      child: Padding(
        padding: const EdgeInsets.all(UIHelpers.paddingMedium),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UIHelpers.buildSectionHeader('Stats'),
              const SizedBox(height: UIHelpers.paddingMedium),
              UIHelpers.buildEmptyState(
                icon: Icons.bar_chart,
                title: 'No stats available',
                subtitle: 'Join a team to start tracking your performance',
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
            StatItem(label: 'AVG', value: '.000', color: Colors.blue),
            StatItem(label: 'H', value: '0', color: Colors.green),
            StatItem(label: 'R', value: '0', color: Colors.orange),
            StatItem(label: 'RBI', value: '0', color: Colors.purple),
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
            StatItem(label: 'Record', value: teamProvider.teamRecord, color: Colors.green),
            StatItem(label: 'RS', value: '0', color: Colors.blue),
            StatItem(label: 'RA', value: '0', color: Colors.red),
          ],
        ),
      ],
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

}