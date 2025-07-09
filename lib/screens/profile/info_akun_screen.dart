import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InfoAkunScreen extends StatefulWidget {
  const InfoAkunScreen({super.key});

  @override
  State<InfoAkunScreen> createState() => _InfoAkunScreenState();
}

class _InfoAkunScreenState extends State<InfoAkunScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;

  // User data
  String _name = "";
  String _email = "";
  String _phoneNumber = "";
  String _role = "User"; // Default role

  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _fetchUserData();
    } else {
      // No user logged in, stop loading to avoid indefinite spinner
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_user!.uid)
              .get();
      if (userDoc.exists) {
        setState(() {
          _name = userDoc.get('name') ?? "";
          _email = userDoc.get('email') ?? "";
          _phoneNumber = userDoc.get('phoneNumber') ?? "";
          _role = userDoc.get('role') ?? "User";
          _isLoading = false;
        });
      } else {
        // Document does not exist
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memuat data pengguna")),
      );
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update Firestore with name and phone only (email is not editable)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .update({'name': _name, 'phoneNumber': _phoneNumber});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan berhasil disimpan')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
      }
    }
  }

  void _toggleEditing() {
    if (_isEditing) {
      // attempt save and toggle off editing
      if (_formKey.currentState!.validate()) {
        _updateUserData();
        setState(() {
          _isEditing = false;
        });
      }
    } else {
      // enable editing
      setState(() {
        _isEditing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Tidak ada pengguna yang login')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Akun'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined),
            onPressed: _toggleEditing,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile_placeholder.png'),
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              _isEditing
                  ? TextFormField(
                    initialValue: _name,
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => _name = value,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  )
                  : Text(
                    _name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _role,
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Email field always non-editable, display as text
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 24,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildEditableField(
                        icon: Icons.phone_outlined,
                        label: 'Nomor Telepon',
                        value: _phoneNumber,
                        isEditing: _isEditing,
                        validator:
                            (value) =>
                                (value == null || value.length < 10)
                                    ? 'Nomor tidak valid'
                                    : null,
                        onChanged: (value) => _phoneNumber = value,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required String value,
    required bool isEditing,
    required String? Function(String?)? validator,
    required Function(String) onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Expanded(
          child:
              isEditing
                  ? TextFormField(
                    initialValue: value,
                    decoration: InputDecoration(
                      labelText: label,
                      border: const OutlineInputBorder(),
                    ),
                    validator: validator,
                    onChanged: onChanged,
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }
}
