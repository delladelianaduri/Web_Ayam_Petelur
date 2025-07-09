import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TelurScreen extends StatefulWidget {
  const TelurScreen({super.key});

  @override
  State<TelurScreen> createState() => _TelurScreenState();
}

class _TelurScreenState extends State<TelurScreen> {
  List<Map<String, dynamic>> _listTelur = [];
  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTelurData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTelurData() async {
    setState(() {
      _loading = true;
    });
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('telur')
              .orderBy('tanggal', descending: true)
              .get();
      List<Map<String, dynamic>> allDocs =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['docId'] = doc.id;
            return data;
          }).toList();

      // Filter by search query if not empty
      String searchQuery = _searchController.text.toLowerCase().trim();
      if (searchQuery.isNotEmpty) {
        allDocs =
            allDocs.where((telur) {
              String date = (telur['tanggal'] ?? '').toString().toLowerCase();
              String jumlahButir = (telur['jumlah_butir'] ?? '').toString();
              String jumlahKg = (telur['jumlah_kg'] ?? '').toString();
              return date.contains(searchQuery) ||
                  jumlahButir.contains(searchQuery) ||
                  jumlahKg.contains(searchQuery);
            }).toList();
      }

      _listTelur = allDocs;
    } catch (e) {
      _listTelur = [];
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data telur: $e')));
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
    await _fetchTelurData();
  }

  void _tambahDataTelur() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TambahTelurScreen(
              onTelurDitambahkan: (telurBaru) async {
                await FirebaseFirestore.instance
                    .collection('telur')
                    .add(telurBaru);
                _refreshData();
              },
            ),
      ),
    );
  }

  void _editDataTelur(Map<String, dynamic> telur) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TambahTelurScreen(
              onTelurDitambahkan: (telurBaru) async {
                await FirebaseFirestore.instance
                    .collection('telur')
                    .doc(telur['docId'])
                    .update(telurBaru);
                _refreshData();
              },
              telurData: telur,
            ),
      ),
    );
  }

  void _deleteDataTelur(String docId) async {
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
            .collection('telur')
            .doc(docId)
            .delete();
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data telur berhasil dihapus')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data telur: $e')),
        );
      }
    }
  }

  void _lihatDetailTelur(Map<String, dynamic> telur) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailTelurScreen(telur: telur)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Produksi Telur',
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
                      hintText: 'Cari berdasarkan tanggal atau jumlah',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (value) {
                      _fetchTelurData();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetchTelurData,
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
                    'Total ${_listTelur.length} Data Telur',
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
                      onRefresh: _fetchTelurData,
                      child:
                          _listTelur.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.egg,
                                      size: 60,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada data produksi telur',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tambahkan data produksi telur Anda',
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
                                itemCount: _listTelur.length,
                                itemBuilder: (context, index) {
                                  final telur = _listTelur[index];
                                  return _buildTelurCard(telur);
                                },
                              ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahDataTelur,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produksi Telur'),
      ),
    );
  }

  Widget _buildTelurCard(Map<String, dynamic> telur) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _lihatDetailTelur(telur),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with date and buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Tanggal: ${telur['tanggal'] ?? '-'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
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
                        onPressed: () => _editDataTelur(telur),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () => _deleteDataTelur(telur['docId']),
                        tooltip: 'Hapus',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.egg, size: 40, color: Colors.green[700]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jumlah Butir: ${telur['jumlah_butir'] ?? '-'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Berat (kg): ${telur['jumlah_kg']?.toStringAsFixed(2) ?? '-'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TambahTelurScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onTelurDitambahkan;
  final Map<String, dynamic>? telurData;

  const TambahTelurScreen({
    super.key,
    required this.onTelurDitambahkan,
    this.telurData,
  });

  @override
  State<TambahTelurScreen> createState() => _TambahTelurScreenState();
}

class _TambahTelurScreenState extends State<TambahTelurScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahButirController = TextEditingController();
  final _jumlahKgController = TextEditingController();
  DateTime? _tanggal;

  @override
  void initState() {
    super.initState();
    if (widget.telurData != null) {
      _jumlahButirController.text =
          (widget.telurData!['jumlah_butir'] ?? 0).toString();
      _jumlahKgController.text =
          (widget.telurData!['jumlah_kg'] ?? 0).toString();
      _tanggal = DateTime.tryParse(widget.telurData!['tanggal'] ?? '');
    }
  }

  @override
  void dispose() {
    _jumlahButirController.dispose();
    _jumlahKgController.dispose();
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
    if (value == null || value.isEmpty) {
      return 'Tidak boleh kosong';
    }
    final n = int.tryParse(value);
    if (n == null || n < 0) {
      return 'Masukkan angka valid >= 0';
    }
    return null;
  }

  String? _validatePositiveDouble(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tidak boleh kosong';
    }
    final d = double.tryParse(value);
    if (d == null || d < 0) {
      return 'Masukkan angka valid >= 0';
    }
    return null;
  }

  void _simpanDataTelur() {
    if (_formKey.currentState!.validate() && _tanggal != null) {
      final telurBaru = {
        'tanggal': _tanggal!.toIso8601String().split('T').first,
        'jumlah_butir': int.tryParse(_jumlahButirController.text) ?? 0,
        'jumlah_kg': double.tryParse(_jumlahKgController.text) ?? 0,
      };

      widget.onTelurDitambahkan(telurBaru);
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
      appBar: AppBar(title: const Text('Tambah Produksi Telur')),
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
                controller: _jumlahButirController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Telur (butir)',
                  prefixIcon: Icon(Icons.egg, color: Colors.green[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: _validatePositiveInt,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahKgController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Telur (kg)',
                  prefixIcon: Icon(Icons.line_weight, color: Colors.green[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: _validatePositiveDouble,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _simpanDataTelur,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'SIMPAN DATA TELUR',
                    style: TextStyle(color: Colors.white),
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

class DetailTelurScreen extends StatelessWidget {
  final Map<String, dynamic> telur;

  const DetailTelurScreen({super.key, required this.telur});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(telur['tanggal'] ?? 'Detail Produksi Telur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.egg, color: Colors.orange, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detail Produksi Telur',
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
                      value: telur['tanggal'] ?? '-',
                      iconColor: Colors.green[700],
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.egg,
                      label: 'Jumlah Telur (butir)',
                      value: (telur['jumlah_butir'] ?? '-').toString(),
                      iconColor: Colors.green[700],
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.line_weight,
                      label: 'Jumlah Telur (kg)',
                      value:
                          telur['jumlah_kg'] != null
                              ? (telur['jumlah_kg'] as num).toStringAsFixed(2)
                              : '-',
                      iconColor: Colors.blue[700],
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
