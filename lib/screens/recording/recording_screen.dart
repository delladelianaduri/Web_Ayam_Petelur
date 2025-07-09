import 'package:flutter/material.dart';
import 'package:ayam_petelur_web/screens/recording/telur_screen.dart';
import 'package:ayam_petelur_web/screens/recording/pakan_screen.dart';
import 'package:ayam_petelur_web/screens/recording/vaksin_screen.dart';
import 'package:ayam_petelur_web/screens/recording/sanitasi_screen.dart';

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : 16,
          vertical: 16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1200 : double.infinity,
            ),
            child: GridView.count(
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: isDesktop ? 24 : 16,
              mainAxisSpacing: isDesktop ? 24 : 16,
              childAspectRatio: isDesktop ? 0.9 : 1.1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildRecordingCard(
                  context,
                  icon: Icons.egg,
                  title: 'Produksi Telur',
                  color: Colors.blue[700]!,
                  destination: const TelurScreen(),
                  isDesktop: isDesktop,
                ),
                _buildRecordingCard(
                  context,
                  icon: Icons.fastfood,
                  title: 'Pakan',
                  color: Colors.green[700]!,
                  destination: const PakanScreen(),
                  isDesktop: isDesktop,
                ),
                _buildRecordingCard(
                  context,
                  icon: Icons.medical_services,
                  title: 'Vaksin',
                  color: Colors.orange[700]!,
                  destination: const VaksinScreen(),
                  isDesktop: isDesktop,
                ),
                _buildRecordingCard(
                  context,
                  icon: Icons.cleaning_services,
                  title: 'Sanitasi',
                  color: Colors.purple[700]!,
                  destination: const SanitasiScreen(),
                  isDesktop: isDesktop,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Widget destination,
    required bool isDesktop,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) => destination,
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 16 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                ),
                child: Icon(icon, size: isDesktop ? 36 : 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              if (isDesktop) ...[
                const SizedBox(height: 8),
                Text(
                  _getCardDescription(title),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getCardDescription(String title) {
    switch (title) {
      case 'Produksi Telur':
        return 'Catat hasil produksi harian';
      case 'Pakan':
        return 'Kelola konsumsi pakan';
      case 'Vaksin':
        return 'Jadwal dan riwayat vaksinasi';
      case 'Sanitasi':
        return 'Pembersihan dan desinfeksi';
      default:
        return '';
    }
  }
}
