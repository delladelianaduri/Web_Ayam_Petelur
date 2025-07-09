import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VaksinScreen extends StatefulWidget {
  const VaksinScreen({super.key});

  @override
  State<VaksinScreen> createState() => _VaksinScreenState();
}

class _VaksinScreenState extends State<VaksinScreen> {
  List<Map<String, dynamic>> _listVaksin = [];
  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchVaksinData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVaksinData() async {
    setState(() {
      _loading = true;
    });
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('vaksin')
              .orderBy('tanggal', descending: true)
              .get();
      List<Map<String, dynamic>> allDocs =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['docId'] = doc.id;
            return data;
          }).toList();

      String searchQuery = _searchController.text.toLowerCase().trim();
      if (searchQuery.isNotEmpty) {
        allDocs =
            allDocs.where((vaksin) {
              String date = (vaksin['tanggal'] ?? '').toString().toLowerCase();
              String jenisVaksin =
                  (vaksin['jenis_vaksin'] ?? '').toString().toLowerCase();
              return date.contains(searchQuery) ||
                  jenisVaksin.contains(searchQuery);
            }).toList();
      }

      _listVaksin = allDocs;
    } catch (e) {
      _listVaksin = [];
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data vaksin: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _refreshData() async {
    await _fetchVaksinData();
  }

  void _tambahDataVaksin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TambahVaksinScreen(
              onVaksinDitambahkan: (vaksinBaru) async {
                await FirebaseFirestore.instance
                    .collection('vaksin')
                    .add(vaksinBaru);
                _refreshData();
              },
            ),
      ),
    );
  }

  void _editDataVaksin(Map<String, dynamic> vaksin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TambahVaksinScreen(
              onVaksinDitambahkan: (vaksinBaru) async {
                await FirebaseFirestore.instance
                    .collection('vaksin')
                    .doc(vaksin['docId'])
                    .update(vaksinBaru);
                _refreshData();
              },
              vaksinData: vaksin,
            ),
      ),
    );
  }

  void _deleteDataVaksin(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('vaksin')
            .doc(docId)
            .delete();
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data vaksin berhasil dihapus')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data vaksin: $e')),
        );
      }
    }
  }

  void _lihatDetailVaksin(Map<String, dynamic> vaksin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailVaksinScreen(vaksin: vaksin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Data Vaksin Ayam',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Cari berdasarkan tanggal atau jenis vaksin',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (value) => _fetchVaksinData(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetchVaksinData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Cari',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total ${_listVaksin.length} Data Vaksin',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: _fetchVaksinData,
                      child:
                          _listVaksin.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.health_and_safety,
                                      size: 60,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada data vaksin ayam',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tambahkan data vaksin ayam Anda',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: _listVaksin.length,
                                itemBuilder: (context, index) {
                                  final vaksin = _listVaksin[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () => _lihatDetailVaksin(vaksin),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Tanggal: ${vaksin['tanggal'] ?? '-'}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit_outlined,
                                                        color: Colors.blueGrey,
                                                        size: 20,
                                                      ),
                                                      onPressed:
                                                          () => _editDataVaksin(
                                                            vaksin,
                                                          ),
                                                      tooltip: 'Edit',
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.redAccent,
                                                        size: 20,
                                                      ),
                                                      onPressed:
                                                          () =>
                                                              _deleteDataVaksin(
                                                                vaksin['docId'],
                                                              ),
                                                      tooltip: 'Hapus',
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Column(
                                                  children: [
                                                    Icon(
                                                      Icons.pets,
                                                      color: Colors.green,
                                                      size: 28,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      (vaksin['jumlah_ayam'] ??
                                                              0)
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.green,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Jumlah Ayam',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Icon(
                                                      Icons.medical_services,
                                                      color: Colors.blue,
                                                      size: 28,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      vaksin['jenis_vaksin'] ??
                                                          '-',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.blue,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Jenis Vaksin',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              vaksin['deskripsi'] ?? '-',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahDataVaksin,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Vaksin'),
      ),
    );
  }
}

class TambahVaksinScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onVaksinDitambahkan;
  final Map<String, dynamic>? vaksinData;

  const TambahVaksinScreen({
    super.key,
    required this.onVaksinDitambahkan,
    this.vaksinData,
  });

  @override
  State<TambahVaksinScreen> createState() => _TambahVaksinScreenState();
}

class _TambahVaksinScreenState extends State<TambahVaksinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahAyamController = TextEditingController();
  final _jenisVaksinController = TextEditingController();
  final _deskripsiController = TextEditingController();
  DateTime? _tanggal;

  @override
  void initState() {
    super.initState();
    if (widget.vaksinData != null) {
      _jumlahAyamController.text =
          (widget.vaksinData!['jumlah_ayam'] ?? 0).toString();
      _jenisVaksinController.text = widget.vaksinData!['jenis_vaksin'] ?? '';
      _deskripsiController.text = widget.vaksinData!['deskripsi'] ?? '';
      _tanggal = DateTime.tryParse(widget.vaksinData!['tanggal'] ?? '');
    }
  }

  @override
  void dispose() {
    _jumlahAyamController.dispose();
    _jenisVaksinController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickTanggal() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() {
        _tanggal = selected;
      });
    }
  }

  String? _validatePositiveInt(String? value) {
    if (value == null || value.isEmpty) return 'Tidak boleh kosong';
    final n = int.tryParse(value);
    if (n == null || n < 0) return 'Masukkan angka valid >= 0';
    return null;
  }

  String? _validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) return 'Tidak boleh kosong';
    return null;
  }

  void _simpanDataVaksin() {
    if (_formKey.currentState!.validate() && _tanggal != null) {
      final vaksinBaru = {
        'tanggal': _tanggal!.toIso8601String().split('T').first,
        'jumlah_ayam': int.tryParse(_jumlahAyamController.text) ?? 0,
        'jenis_vaksin': _jenisVaksinController.text,
        'deskripsi': _deskripsiController.text,
      };
      widget.onVaksinDitambahkan(vaksinBaru);
      Navigator.pop(context);
    } else if (_tanggal == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan pilih tanggal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vaksinData == null ? 'Tambah Data Vaksin' : 'Edit Data Vaksin',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InkWell(
                onTap: _pickTanggal,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _tanggal == null
                        ? 'Pilih tanggal'
                        : _tanggal!.toIso8601String().split('T').first,
                    style: TextStyle(
                      color: _tanggal == null ? Colors.grey[600] : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahAyamController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Ayam yang Divaksin',
                  prefixIcon: Icon(Icons.pets, color: Colors.green[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: _validatePositiveInt,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jenisVaksinController,
                decoration: InputDecoration(
                  labelText: 'Jenis Vaksin',
                  prefixIcon: Icon(
                    Icons.medical_services,
                    color: Colors.green[700],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: _validateNotEmpty,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  prefixIcon: Icon(Icons.description, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _simpanDataVaksin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.vaksinData == null ? 'SIMPAN' : 'UPDATE',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailVaksinScreen extends StatelessWidget {
  final Map<String, dynamic> vaksin;

  const DetailVaksinScreen({super.key, required this.vaksin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vaksin['tanggal'] ?? 'Detail Data Vaksin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.health_and_safety,
                  color: Colors.orange,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detail Data Vaksin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.green[50],
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Tanggal',
                      value: vaksin['tanggal'] ?? '-',
                      iconColor: Colors.green[700],
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.pets,
                      label: 'Jumlah Ayam yang Divaksin',
                      value: (vaksin['jumlah_ayam'] ?? '-').toString(),
                      iconColor: Colors.green[700],
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.medical_services,
                      label: 'Jenis Vaksin',
                      value: vaksin['jenis_vaksin'] ?? '-',
                      iconColor: Colors.blue[700],
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.description,
                      label: 'Deskripsi',
                      value: vaksin['deskripsi'] ?? '-',
                      iconColor: Colors.grey[700],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor ?? Colors.black87, size: 28),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
