import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late final CollectionReference usersCollection;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'user';
  bool _isActive = true;
  late TabController _tabController;

  // State untuk sembunyikan/lihat password
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    usersCollection = FirebaseFirestore.instance.collection('users');
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    final String email = _emailController.text.trim();
    final String name = _nameController.text.trim();
    final String fullName = _fullNameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty ||
        name.isEmpty ||
        fullName.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    try {
      // Buat user di Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Simpan data tambahan user di Firestore dengan dokumen id sama dengan UID
      await usersCollection.doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'fullName': fullName,
        'phoneNumber': phone,
        'role': _selectedRole,
        'isActive': _isActive,
        'password':
            password, // Password disimpan di Firestore (catatan: metode ini kurang aman dalam produksi)
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Bersihkan form
      _emailController.clear();
      _nameController.clear();
      _fullNameController.clear();
      _phoneController.clear();
      _passwordController.clear();

      setState(() {
        _selectedRole = 'user';
        _isActive = true;
        _obscurePassword = true; // Reset visibility password ke sembunyikan
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User berhasil ditambahkan')),
      );

      // Pindah tab ke daftar user
      _tabController.animateTo(0);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan user: $e')));
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await usersCollection.doc(userId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User berhasil dihapus')));
      // Catatan: Hapus user dari Firebase Authentication harus pakai Admin SDK atau Cloud Functions
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus user: $e')));
    }
  }

  void _showDeleteConfirmation(String userId, String userName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus User'),
            content: Text('Yakin ingin hapus user "$userName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteUser(userId);
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          usersCollection.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(child: Text('Belum ada pengguna'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            final userId = users[index].id;
            final name = user['name'] ?? 'No Name';
            final email = user['email'] ?? 'No Email';
            final role = user['role'] ?? 'user';
            final isActive = user['isActive'] ?? false;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      role == 'admin'
                          ? Colors.deepOrange[100]
                          : Colors.blue[100],
                  child: Icon(
                    role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                    color: role == 'admin' ? Colors.deepOrange : Colors.blue,
                  ),
                ),
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email),
                    Row(
                      children: [
                        Icon(
                          isActive ? Icons.check_circle : Icons.remove_circle,
                          color: isActive ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(userId, name),
                ),
                onTap: () {
                  // Bisa ditambah fitur edit profil user jika diperlukan
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddUserForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.people),
            ),
            items: const [
              DropdownMenuItem(value: 'user', child: Text('User')),
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
            ],
            onChanged: (value) => setState(() => _selectedRole = value!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.power_settings_new, color: Colors.grey),
              const SizedBox(width: 12),
              const Text('Active Status'),
              const Spacer(),
              Switch(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addUser,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('TAMBAH USER'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Daftar User'),
            Tab(icon: Icon(Icons.person_add), text: 'Tambah User'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildUserList(), _buildAddUserForm()],
      ),
    );
  }
}
