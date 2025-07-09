import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ayam_petelur_web/screens/profile/profile_screen.dart';
import 'package:ayam_petelur_web/screens/wawasan/wawasan_screen.dart';
import 'package:ayam_petelur_web/screens/ayam/ayam_screen.dart';
import 'package:ayam_petelur_web/screens/recording/recording_screen.dart';
import 'package:ayam_petelur_web/screens/laporan/laporan_screen.dart';
import 'package:ayam_petelur_web/screens/users/user_management_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  String userName = "";

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        userName = userDoc['name'] ?? 'User';
      });
    } else {
      setState(() {
        userName = 'User';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // remain on home
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WawasanScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: SizedBox(
        height: 72,
        child: BottomAppBar(
          elevation: 4,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.lightbulb, 'Wawasan', 1),
                _buildNavItem(Icons.person_outline, 'Profil', 2),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWideScreen ? 40 : 20,
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWideScreen ? 800 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isWideScreen),
                  const SizedBox(height: 24),
                  _buildMainMenuGrid(isWideScreen),
                  const SizedBox(height: 24),
                  _buildQuickStatsSection(isWideScreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isWideScreen) {
    return Row(
      children: [
        CircleAvatar(
          radius: isWideScreen ? 28 : 24,
          backgroundColor: Colors.green[700],
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: isWideScreen ? 28 : 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, $userName',
              style: TextStyle(
                fontSize: isWideScreen ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              'Layer Link',
              style: TextStyle(
                fontSize: isWideScreen ? 15 : 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainMenuGrid(bool isWideScreen) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isWideScreen ? 4 : 2,
      childAspectRatio: 1.1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMenuCard(
          icon: Icons.pets,
          title: 'Ayam',
          color: Colors.blue[700]!,
          isWideScreen: isWideScreen,
          onTap: () => _navigateTo(const AyamScreen()),
        ),
        _buildMenuCard(
          icon: Icons.assignment,
          title: 'Recording',
          color: Colors.orange[700]!,
          isWideScreen: isWideScreen,
          onTap: () => _navigateTo(const RecordingScreen()),
        ),
        _buildMenuCard(
          icon: Icons.bar_chart,
          title: 'Laporan',
          color: Colors.purple[700]!,
          isWideScreen: isWideScreen,
          onTap: () => _navigateTo(const LaporanScreen()),
        ),
        _buildMenuCard(
          icon: Icons.group,
          title: 'Users',
          color: Colors.teal[700]!,
          isWideScreen: isWideScreen,
          onTap: () => _navigateTo(const UserManagementScreen()),
        ),
      ],
    );
  }

  Widget _buildQuickStatsSection(bool isWideScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Cepat',
          style: TextStyle(
            fontSize: isWideScreen ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Ayam',
                value: '5,000',
                color: Colors.blue[100]!,
                isWideScreen: isWideScreen,
              ),
            ),
            SizedBox(width: isWideScreen ? 16 : 12),
            Expanded(
              child: _buildStatCard(
                title: 'Produksi Hari Ini',
                value: '320',
                color: Colors.green[100]!,
                isWideScreen: isWideScreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Kesehatan',
                value: '95%',
                color: Colors.orange[100]!,
                isWideScreen: isWideScreen,
              ),
            ),
            SizedBox(width: isWideScreen ? 16 : 12),
            Expanded(
              child: _buildStatCard(
                title: 'FCR',
                value: '1.8',
                color: Colors.purple[100]!,
                isWideScreen: isWideScreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required bool isWideScreen,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(isWideScreen ? 20 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isWideScreen ? 14 : 12),
                decoration: BoxDecoration(
                  color: Color.alphaBlend(color.withOpacity(0.2), Colors.white),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: isWideScreen ? 32 : 30, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isWideScreen ? 17 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required bool isWideScreen,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isWideScreen ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isWideScreen ? 15 : 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isWideScreen ? 26 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color:
                  _selectedIndex == index
                      ? Colors.green[700]
                      : Colors.grey[500],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color:
                    _selectedIndex == index
                        ? Colors.green[700]
                        : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
