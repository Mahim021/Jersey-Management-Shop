import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/primary_button.dart';
import 'main_shell.dart';

class FavoritesSelectionScreen extends StatefulWidget {
  const FavoritesSelectionScreen({super.key});

  @override
  State<FavoritesSelectionScreen> createState() => _FavoritesSelectionScreenState();
}

class _FavoritesSelectionScreenState extends State<FavoritesSelectionScreen> {
  final Set<String> _selectedTeams = {};

  final List<Map<String, String>> _teams = [
    {'name': 'Man United', 'icon': '🔴'},
    {'name': 'Real Madrid', 'icon': '⚪'},
    {'name': 'Argentina', 'icon': '🇦🇷'},
    {'name': 'Brazil', 'icon': '🇧🇷'},
    {'name': 'France', 'icon': '🇫🇷'},
    {'name': 'Man City', 'icon': '💙'},
    {'name': 'Liverpool', 'icon': '❤️'},
    {'name': 'Barcelona', 'icon': '🔵'},
    {'name': 'Bayern', 'icon': '🔴'},
  ];

  void _toggleTeam(String teamName) {
    setState(() {
      if (_selectedTeams.contains(teamName)) {
        _selectedTeams.remove(teamName);
      } else {
        _selectedTeams.add(teamName);
      }
    });
  }

  void _continue() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Follow Your Favorites',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search teams or countries',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Teams grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.75,
                ),
                itemCount: _teams.length,
                itemBuilder: (context, index) {
                  final team = _teams[index];
                  final isSelected = _selectedTeams.contains(team['name']);

                  return GestureDetector(
                    onTap: () => _toggleTeam(team['name']!),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C3E50),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      team['icon']!,
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          team['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                text: 'Continue',
                onPressed: _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
