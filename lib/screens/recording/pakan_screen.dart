import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PakanScreen extends StatefulWidget {
  const PakanScreen({super.key});

  @override
  State<PakanScreen> createState() => _PakanScreenState();
}

class _PakanScreenState extends State<PakanScreen> {
  List<Map<String, dynamic>> _listPakan = [];
  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPakanData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPakanData() async {
    setState(() {
      _loading = true;
    });
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('pakan')
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
            allDocs.where((pakan) {
              String date = (pakan['tanggal'] ?? '').toString().toLowerCase();
              String jenisPakan =
                  (pakan['jenis_pakan'] ?? '').toString().toLowerCase();
              return date.contains(searchQuery) ||
                  jenisPakan.contains(searchQuery);
            }).toList();
      }

      _listPakan = allDocs;
    } catch (e) {
      _listPakan = [];
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data pakan: \$e')));
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
    await _fetchPakanData();
  }

  void _tambahDataPakan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TambahPakanScreen(
              onPakanDitambahkan: (pakanBaru) async {
                await FirebaseFirestore.instance
                    .collection('pakan')
                    .add(pakanBaru);
                _refreshData();
              },
            ),
      ),
    );
  }

  void _editDataPakan(Map<String, dynamic> pakan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TambahPakanScreen(
              onPakanDitambahkan: (pakanBaru) async {
                await FirebaseFirestore.instance
                    .collection('pakan')
                    .doc(pakan['docId'])
                    .update(pakanBaru);
                _refreshData();
              },
              pakanData: pakan,
            ),
      ),
    );
  }

  void _deleteDataPakan(String docId) async {
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
            .collection('pakan')
            .doc(docId)
            .delete();
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data pakan berhasil dihapus')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data pakan: \$e')),
        );
      }
    }
  }

  void _lihatDetailPakan(Map<String, dynamic> pakan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPakanScreen(pakan: pakan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Data Pakan Ayam',
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
                      hintText: 'Cari berdasarkan tanggal atau jenis pakan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (value) => _fetchPakanData(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetchPakanData,
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
                    'Total ${_listPakan.length} Data Pakan',
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
                      onRefresh: _fetchPakanData,
                      child:
                          _listPakan.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu,
                                      size: 60,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada data pakan ayam',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tambahkan data pakan Anda',
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
                                itemCount: _listPakan.length,
                                itemBuilder: (context, index) {
                                  final pakan = _listPakan[index];
                                  return _buildPakanCard(pakan);
                                },
                              ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahDataPakan,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pakan'),
      ),
    );
  }

  Widget _buildPakanCard(Map<String, dynamic> pakan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _lihatDetailPakan(pakan),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Tanggal: ${pakan['tanggal'] ?? '-'}',
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
                        onPressed: () => _editDataPakan(pakan),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () => _deleteDataPakan(pakan['docId']),
                        tooltip: 'Hapus',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(Icons.pets, color: Colors.green, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        (pakan['jumlah_ekor_gram'] ?? 0).toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 13,
                        ),
                      ),
                      const Text(
                        'Jumlah Ekor/Gram',
                        style: TextStyle(color: Colors.green, fontSize: 11),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.line_weight, color: Colors.blue, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        (pakan['jumlah_kg'] ?? 0).toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 13,
                        ),
                      ),
                      const Text(
                        'Jumlah Kg',
                        style: TextStyle(color: Colors.blue, fontSize: 11),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: Colors.orange,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pakan['jenis_pakan'] ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 13,
                        ),
                      ),
                      const Text(
                        'Jenis Pakan',
                        style: TextStyle(color: Colors.orange, fontSize: 11),
                      ),
                    ],
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

class TambahPakanScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onPakanDitambahkan;
  final Map<String, dynamic>? pakanData;
  const TambahPakanScreen({
    super.key,
    required this.onPakanDitambahkan,
    this.pakanData,
  });

  @override
  State<TambahPakanScreen> createState() => _TambahPakanScreenState();
}

class _TambahPakanScreenState extends State<TambahPakanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahEkorGramController = TextEditingController();
  final _jumlahKgController = TextEditingController();
  final _jenisPakanController = TextEditingController();
  DateTime? _tanggal;

  @override
  void initState() {
    super.initState();
    if (widget.pakanData != null) {
      _jumlahEkorGramController.text =
          (widget.pakanData!['jumlah_ekor_gram'] ?? 0).toString();
      _jumlahKgController.text =
          (widget.pakanData!['jumlah_kg'] ?? 0).toString();
      _jenisPakanController.text = widget.pakanData!['jenis_pakan'] ?? '';
      _tanggal = DateTime.tryParse(widget.pakanData!['tanggal'] ?? '');
    }
  }

  @override
  void dispose() {
    _jumlahEkorGramController.dispose();
    _jumlahKgController.dispose();
    _jenisPakanController.dispose();
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

  String? _validatePositiveDouble(String? value) {
    if (value == null || value.isEmpty) return 'Tidak boleh kosong';
    final d = double.tryParse(value);
    if (d == null || d < 0) return 'Masukkan angka valid >= 0';
    return null;
  }

  String? _validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) return 'Tidak boleh kosong';
    return null;
  }

  void _simpanDataPakan() {
    if (_formKey.currentState!.validate() && _tanggal != null) {
      final pakanBaru = {
        'tanggal': _tanggal!.toIso8601String().split('T').first,
        'jumlah_ekor_gram': int.tryParse(_jumlahEkorGramController.text) ?? 0,
        'jumlah_kg': double.tryParse(_jumlahKgController.text) ?? 0,
        'jenis_pakan': _jenisPakanController.text,
      };
      widget.onPakanDitambahkan(pakanBaru);
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
      appBar: AppBar(title: const Text('Tambah Data Pakan')),
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
                controller: _jumlahEkorGramController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Pakan (ekor/gram)',
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
                controller: _jumlahKgController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Pakan (kg)',
                  prefixIcon: Icon(Icons.line_weight, color: Colors.green[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validatePositiveDouble,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jenisPakanController,
                decoration: InputDecoration(
                  labelText: 'Jenis Pakan',
                  prefixIcon: Icon(
                    Icons.restaurant_menu,
                    color: Colors.green[700],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: _validateNotEmpty,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _simpanDataPakan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'SIMPAN',
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

class DetailPakanScreen extends StatelessWidget {
  final Map<String, dynamic> pakan;

  const DetailPakanScreen({super.key, required this.pakan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pakan['tanggal'] ?? 'Detail Data Pakan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  color: Colors.orange,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detail Produksi Pakan',
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
                      value: pakan['tanggal'] ?? '-',
                      iconColor: Colors.green[700],
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.sports_kabaddi,
                      label: 'Jumlah Pakan (ekor/gram)',
                      value: (pakan['jumlah_ekor_gram'] ?? '-').toString(),
                      iconColor: Colors.green[700],
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.line_weight,
                      label: 'Jumlah Pakan (kg)',
                      value:
                          pakan['jumlah_kg'] != null
                              ? (pakan['jumlah_kg'] as num).toStringAsFixed(2)
                              : '-',
                      iconColor: Colors.blue[700],
                    ),
                    const Divider(height: 30, thickness: 1),
                    _buildDetailRow(
                      icon: Icons.amp_stories,
                      label: 'Jenis Pakan',
                      value: pakan['jenis_pakan'] ?? '-',
                      iconColor: Colors.orange[700],
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
