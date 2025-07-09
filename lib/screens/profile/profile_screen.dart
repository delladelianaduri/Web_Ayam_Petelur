import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ayam_petelur_web/screens/profile/change_password_screen.dart';
import 'package:ayam_petelur_web/screens/profile/info_akun_screen.dart';
import 'package:ayam_petelur_web/screens/login_screen.dart';
import 'package:ayam_petelur_web/screens/wawasan/wawasan_screen.dart';
import 'package:ayam_petelur_web/screens/home_screen.dart';
import 'package:ayam_petelur_web/screens/admin_home_screen.dart';
import 'package:logger/logger.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Logger logger = Logger();

  String userName = 'User';
  String userEmail = 'Tidak ada email';
  String formattedPhoneNumber = 'Tidak ada nomor telepon';
  bool isLoading = true;

  User? user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc.get('fullName') ?? 'User';
            userEmail = user?.email ?? 'Tidak ada email';
            final dynamic phoneNumberDynamic = userDoc.get('phoneNumber');
            String? phoneNumber;
            if (phoneNumberDynamic is String) {
              phoneNumber = phoneNumberDynamic;
            }
            if (phoneNumber != null && phoneNumber.isNotEmpty) {
              formattedPhoneNumber =
                  phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';
            } else {
              formattedPhoneNumber = 'Tidak ada nomor telepon';
            }
            isLoading = false;
          });
        } else {
          setState(() {
            userName = user?.displayName ?? 'User';
            userEmail = user?.email ?? 'Tidak ada email';
            final String? phoneNumber = user?.phoneNumber;
            if (phoneNumber != null && phoneNumber.isNotEmpty) {
              formattedPhoneNumber =
                  phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';
            } else {
              formattedPhoneNumber = 'Tidak ada nomor telepon';
            }
            isLoading = false;
          });
        }
      } catch (e, st) {
        logger.e(
          "Error fetching user data from Firestore",
          error: e,
          stackTrace: st,
        );
        setState(() {
          userName = user?.displayName ?? 'User';
          userEmail = user?.email ?? 'Tidak ada email';
          final String? phoneNumber = user?.phoneNumber;
          if (phoneNumber != null && phoneNumber.isNotEmpty) {
            formattedPhoneNumber =
                phoneNumber.startsWith('+') ? phoneNumber : '+$phoneNumber';
          } else {
            formattedPhoneNumber = 'Tidak ada nomor telepon';
          }
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> _isUserAdmin(User? user) async {
    if (user == null) return false;
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    return userDoc.get('role') == 'admin'; // Check the role field
  }

  void _navigateToHome(BuildContext context) async {
    bool isAdmin = await _isUserAdmin(user);
    if (isAdmin) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  void _navigateToWawasan(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WawasanScreen()),
      (route) => false,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, size: 48, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Keluar Akun?',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Anda akan keluar dari akun saat ini',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[800],
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Keluar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = 2; // Profile screen index

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
        ),
      );
    }

    final Color primaryColor = Color(0xFF2E7D32);
    final Color backgroundColor = Color(0xFFF8F9FA);
    final Color cardColor = Colors.white;
    final Color textColor = Color(0xFF212529);

    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: backgroundColor,
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
                _buildNavItem(
                  Icons.home,
                  'Home',
                  0,
                  currentIndex,
                  primaryColor,
                  context,
                ),
                _buildNavItem(
                  Icons.lightbulb,
                  'Wawasan',
                  1,
                  currentIndex,
                  primaryColor,
                  context,
                ),
                _buildNavItem(
                  Icons.person_outline,
                  'Profil',
                  2,
                  currentIndex,
                  primaryColor,
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: textColor),
        actions: const [SizedBox(width: 48)],
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
                maxWidth: isWideScreen ? 600 : double.infinity,
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0.8),
                                primaryColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child:
                              user?.photoURL != null
                                  ? ClipOval(
                                    child: Image.network(
                                      user!.photoURL!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Center(
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                formattedPhoneNumber,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildModernMenuItem(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'Informasi Akun',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InfoAkunScreen(),
                        ),
                      );
                    },
                    primaryColor: primaryColor,
                  ),
                  SizedBox(height: 12),
                  _buildModernMenuItem(
                    context: context,
                    icon: Icons.lock_outline,
                    title: 'Ubah Kata Sandi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                    primaryColor: primaryColor,
                  ),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red[400],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red[100]!, width: 1),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _showLogoutConfirmation(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Keluar Akun',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'v3.8.0',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    int currentIndex,
    Color primaryColor,
    BuildContext context,
  ) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        switch (index) {
          case 0:
            _navigateToHome(context);
            break;
          case 1:
            _navigateToWawasan(context);
            break;
          case 2:
            break;
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? primaryColor : Colors.grey[500],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? primaryColor : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: Color(0xFF212529),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
