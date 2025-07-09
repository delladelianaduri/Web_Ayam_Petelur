import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SanitasiScreen extends StatefulWidget {
  const SanitasiScreen({super.key});

  @override
  State<SanitasiScreen> createState() => _SanitasiScreenState();
}

class _SanitasiScreenState extends State<SanitasiScreen> {
  List<Map<String, dynamic>> _listSanitasi = [];
  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSanitasiData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSanitasiData() async {
    setState(() {
      _loading = true;
    });
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('sanitasi')
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
            allDocs.where((sanitasi) {
              String date =
                  (sanitasi['tanggal'] ?? '').toString().toLowerCase();
              String deskripsi =
                  (sanitasi['deskripsi'] ?? '').toString().toLowerCase();
              return date.contains(searchQuery) ||
                  deskripsi.contains(searchQuery);
            }).toList();
      }

      _listSanitasi = allDocs;
    } catch (e) {
      _listSanitasi = [];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data sanitasi: $e')),
        );
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
    await _fetchSanitasiData();
  }

  void _tambahDataSanitasi() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TambahSanitasiScreen(
              onSanitasiDitambahkan: (sanitasiBaru) async {
                await FirebaseFirestore.instance
                    .collection('sanitasi')
                    .add(sanitasiBaru);
                _refreshData();
              },
            ),
      ),
    );
  }

  // Added edit function
  void _editDataSanitasi(Map<String, dynamic> sanitasi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TambahSanitasiScreen(
              onSanitasiDitambahkan: (sanitasiBaru) async {
                await FirebaseFirestore.instance
                    .collection('sanitasi')
                    .doc(sanitasi['docId'])
                    .update(sanitasiBaru);
                _refreshData();
              },
              sanitasiData: sanitasi,
            ),
      ),
    );
  }

  // Added delete function
  void _deleteDataSanitasi(String docId) async {
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
            .collection('sanitasi')
            .doc(docId)
            .delete();
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data sanitasi berhasil dihapus')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data sanitasi: $e')),
        );
      }
    }
  }

  void _lihatDetailSanitasi(Map<String, dynamic> sanitasi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailSanitasiScreen(sanitasi: sanitasi),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Data Sanitasi',
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
                      hintText: 'Cari berdasarkan tanggal atau deskripsi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (value) => _fetchSanitasiData(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetchSanitasiData,
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
                    'Total ${_listSanitasi.length} Data Sanitasi',
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
                      onRefresh: _fetchSanitasiData,
                      child:
                          _listSanitasi.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.clean_hands,
                                      size: 60,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada data sanitasi',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tambahkan data sanitasi Anda',
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
                                itemCount: _listSanitasi.length,
                                itemBuilder: (context, index) {
                                  final sanitasi = _listSanitasi[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap:
                                          () => _lihatDetailSanitasi(sanitasi),
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
                                                    'Tanggal: ${sanitasi['tanggal'] ?? '-'}',
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
                                                          () =>
                                                              _editDataSanitasi(
                                                                sanitasi,
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
                                                          () => _deleteDataSanitasi(
                                                            sanitasi['docId'],
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
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  children: [
                                                    Icon(
                                                      Icons.house_siding,
                                                      color: Colors.green,
                                                      size: 28,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      (sanitasi['jumlah_kandang'] ??
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
                                                      'Jumlah Kandang',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              sanitasi['deskripsi'] ?? '-',
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
        onPressed: _tambahDataSanitasi,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Sanitasi'),
      ),
    );
  }
}

class TambahSanitasiScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSanitasiDitambahkan;
  final Map<String, dynamic>? sanitasiData;

  const TambahSanitasiScreen({
    super.key,
    required this.onSanitasiDitambahkan,
    this.sanitasiData,
  });

  @override
  State<TambahSanitasiScreen> createState() => _TambahSanitasiScreenState();
}

class _TambahSanitasiScreenState extends State<TambahSanitasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahKandangController = TextEditingController();
  final _deskripsiController = TextEditingController();
  DateTime? _tanggal;

  @override
  void initState() {
    super.initState();
    if (widget.sanitasiData != null) {
      _jumlahKandangController.text =
          (widget.sanitasiData!['jumlah_kandang'] ?? 0).toString();
      _deskripsiController.text = widget.sanitasiData!['deskripsi'] ?? '';
      _tanggal = DateTime.tryParse(widget.sanitasiData!['tanggal'] ?? '');
    }
  }

  @override
  void dispose() {
    _jumlahKandangController.dispose();
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

  void _simpanDataSanitasi() {
    if (_formKey.currentState!.validate() && _tanggal != null) {
      final sanitasiBaru = {
        'tanggal': _tanggal!.toIso8601String().split('T').first,
        'jumlah_kandang': int.tryParse(_jumlahKandangController.text) ?? 0,
        'deskripsi': _deskripsiController.text,
      };
      widget.onSanitasiDitambahkan(sanitasiBaru);
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
          widget.sanitasiData == null
              ? 'Tambah Data Sanitasi'
              : 'Edit Data Sanitasi',
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
                controller: _jumlahKandangController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Kandang yang Disanitasi',
                  prefixIcon: Icon(
                    Icons.house_siding,
                    color: Colors.green[700],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: _validatePositiveInt,
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
                  onPressed: _simpanDataSanitasi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.sanitasiData == null ? 'SIMPAN' : 'UPDATE',
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

class DetailSanitasiScreen extends StatelessWidget {
  final Map<String, dynamic> sanitasi;

  const DetailSanitasiScreen({super.key, required this.sanitasi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sanitasi['tanggal'] ?? 'Detail Data Sanitasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.clean_hands, color: Colors.orange, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detail Data Sanitasi',
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
                      value: sanitasi['tanggal'] ?? '-',
                      iconColor: Colors.green[700],
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.house_siding,
                      label: 'Jumlah Kandang yang Disanitasi',
                      value: (sanitasi['jumlah_kandang'] ?? '-').toString(),
                      iconColor: Colors.green[700],
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.description,
                      label: 'Deskripsi',
                      value: sanitasi['deskripsi'] ?? '-',
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
