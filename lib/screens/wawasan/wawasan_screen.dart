import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ayam_petelur_web/screens/home_screen.dart';
import 'package:ayam_petelur_web/screens/admin_home_screen.dart';
import 'package:ayam_petelur_web/screens/profile/profile_screen.dart';
import 'package:ayam_petelur_web/screens/wawasan/wawasan_content.dart';

class WawasanScreen extends StatefulWidget {
  const WawasanScreen({super.key});

  @override
  State<WawasanScreen> createState() => _WawasanScreenState();
}

class _WawasanScreenState extends State<WawasanScreen> {
  // Consistent Color Scheme with HomeScreen
  final Color _primaryColor = const Color(0xFF2E7D32); // Dark green
  final Color _lightGreen = const Color(0xFF81C784); // Light green
  final Color _darkGreen = const Color(0xFF1B5E20); // Darker green
  final Color _backgroundColor = const Color(0xFFF5F5F5); // Light background
  final Color _cardColor = Colors.white;

  int _selectedIndex = 1; // Set the selected index to Wawasan

  // Initialize WawasanContent with the color scheme
  late final WawasanContent wawasanContent = WawasanContent(
    primaryColor: _primaryColor,
    darkGreen: _darkGreen,
    lightGreen: _lightGreen,
  );

  String userRole = '';
  bool isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        userRole = userDoc.get('role') ?? '';
        isLoadingRole = false;
      });
    } else {
      setState(() {
        userRole = '';
        isLoadingRole = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Do nothing if current tab tapped

    setState(() => _selectedIndex = index);

    // Navigate to respective screens
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    userRole == 'admin'
                        ? const AdminHomeScreen()
                        : const HomeScreen(),
          ),
        );
        break;
      case 1: // Wawasan
        // Stay on WawasanScreen
        break;
      case 2: // Profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
    }
  }

  void _showDetailContent(String title) {
    Widget content;

    switch (title) {
      case 'Manajemen Kandang':
        content = wawasanContent.buildCageManagementContent();
        break;
      case 'Pakan Berkualitas':
        content = wawasanContent.buildFeedQualityContent();
        break;
      case 'Kesehatan Ayam':
        content = wawasanContent.buildChickenHealthContent();
        break;
      case 'Produksi Telur':
        content = wawasanContent.buildEggProductionContent();
        break;
      case 'Sanitasi Kandang':
        content = wawasanContent.buildSanitationContent();
        break;
      case 'Pencegahan Stres':
        content = wawasanContent.buildStressPreventionContent();
        break;
      case 'Pengendalian Hama':
        content = wawasanContent.buildPestControlContent();
        break;
      case 'Pengelolaan Suhu':
        content = wawasanContent.buildTemperatureManagementContent();
        break;
      case 'Peningkatan Produktivitas':
        content = wawasanContent.buildProductivityImprovementContent();
        break;
      default:
        content = Container();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: content),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: _backgroundColor,
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
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, color: _primaryColor),
            const SizedBox(width: 10),
            Text('Wawasan', style: TextStyle(color: _darkGreen)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [const SizedBox(width: 8)],
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
                children: [
                  _buildKnowledgeCard(
                    title: 'Manajemen Kandang',
                    subtitle: 'Teknik modern pengelolaan kandang ayam',
                    icon: Icons.agriculture,
                    onTap: () => _showDetailContent('Manajemen Kandang'),
                  ),
                  const SizedBox(height: 8),
                  _buildKnowledgeCard(
                    title: 'Pakan Berkualitas',
                    subtitle: 'Formula nutrisi untuk produksi telur optimal',
                    icon: Icons.restaurant,
                    onTap: () => _showDetailContent('Pakan Berkualitas'),
                  ),
                  const SizedBox(height: 8),
                  _buildKnowledgeCard(
                    title: 'Kesehatan Ayam',
                    subtitle: 'Pencegahan dan penanganan penyakit',
                    icon: Icons.medical_services,
                    onTap: () => _showDetailContent('Kesehatan Ayam'),
                  ),
                  const SizedBox(height: 8),
                  _buildKnowledgeCard(
                    title: 'Produksi Telur',
                    subtitle: 'Tips meningkatkan kualitas dan kuantitas telur',
                    icon: Icons.insights,
                    onTap: () => _showDetailContent('Produksi Telur'),
                  ),
                  const SizedBox(height: 8),
                  _buildKnowledgeCard(
                    title: 'Sanitasi Kandang',
                    subtitle: 'Pentingnya sanitasi dan kebersihan',
                    icon: Icons.cleaning_services,
                    onTap: () => _showDetailContent('Sanitasi Kandang'),
                  ),
                  const SizedBox(height: 8),
                  _buildKnowledgeCard(
                    title: 'Pencegahan Stres',
                    subtitle: 'Cara mencegah stres pada ayam',
                    icon: Icons.spa,
                    onTap: () => _showDetailContent('Pencegahan Stres'),
                  ),
                  const SizedBox(height: 8),
                  _buildKnowledgeCard(
                    title: 'Pengendalian Hama',
                    subtitle: 'Metode pengendalian hama dan parasit',
                    icon: Icons.bug_report,
                    onTap: () => _showDetailContent('Pengendalian Hama'),
                  ),
                  const SizedBox(height: 8),
                  _buildKnowledgeCard(
                    title: 'Pengelolaan Suhu',
                    subtitle: 'Pengelolaan suhu lingkungan yang ideal',
                    icon: Icons.thermostat,
                    onTap: () => _showDetailContent('Pengelolaan Suhu'),
                  ),
                  const SizedBox(height: 8),
                  _buildKnowledgeCard(
                    title: 'Peningkatan Produktivitas',
                    subtitle: 'Strategi untuk meningkatkan produktivitas',
                    icon: Icons.trending_up,
                    onTap:
                        () => _showDetailContent('Peningkatan Produktivitas'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
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
              color: isSelected ? _primaryColor : Colors.grey[500],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? _primaryColor : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: _cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _lightGreen.withAlpha(76), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _primaryColor, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _darkGreen,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: _primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
