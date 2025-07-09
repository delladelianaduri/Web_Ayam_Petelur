import 'package:flutter/material.dart';

class KandangScreen extends StatelessWidget {
  const KandangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Kandang')),
      body: const Center(child: Text('Halaman Manajemen Kandang')),
    );
  }
}
