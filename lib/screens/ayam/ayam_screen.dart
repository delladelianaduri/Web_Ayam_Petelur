import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AyamScreen extends StatefulWidget {
  const AyamScreen({super.key});

  @override
  State<AyamScreen> createState() => _AyamScreenState();
}

class _AyamScreenState extends State<AyamScreen> {
  List<Map<String, dynamic>> _listAyam = [];
  bool _loading = true;
  String _selectedStatus = 'Semua'; // Default status

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAyamData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAyamData() async {
    setState(() {
      _loading = true;
    });
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('ayam')
              .orderBy('tanggal', descending: true)
              .get();
      List<Map<String, dynamic>> allDocs =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['docId'] = doc.id;
            return data;
          }).toList();

      // Filter by selected status
      if (_selectedStatus != 'Semua') {
        allDocs =
            allDocs.where((ayam) {
              switch (_selectedStatus) {
                case 'Sehat':
                  return (ayam['jumlah_sehat'] ?? 0) > 0;
                case 'Mati':
                  return (ayam['jumlah_mati'] ?? 0) > 0;
                default:
                  return true;
              }
            }).toList();
      }

      // Filter by search query if not empty
      String searchQuery = _searchController.text.toLowerCase().trim();
      if (searchQuery.isNotEmpty) {
        allDocs =
            allDocs.where((ayam) {
              String date = (ayam['tanggal'] ?? '').toString().toLowerCase();
              String umur = (ayam['umur'] ?? '').toString().toLowerCase();
              return date.contains(searchQuery) || umur.contains(searchQuery);
            }).toList();
      }

      _listAyam = allDocs;
    } catch (e) {
      _listAyam = [];
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data ayam: $e')));
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
    await _fetchAyamData();
  }

  void _tambahDataAyam() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TambahAyamScreen(
              onAyamDitambahkan: (ayamBaru) async {
                await FirebaseFirestore.instance
                    .collection('ayam')
                    .add(ayamBaru);
                _refreshData();
              },
            ),
      ),
    );
  }

  void _editDataAyam(Map<String, dynamic> ayam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TambahAyamScreen(
              ayamData: ayam,
              onAyamDitambahkan: (ayamBaru) async {
                await FirebaseFirestore.instance
                    .collection('ayam')
                    .doc(ayam['docId'])
                    .update(ayamBaru);
                _refreshData();
              },
            ),
      ),
    );
  }

  void _deleteDataAyam(String docId) async {
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
        await FirebaseFirestore.instance.collection('ayam').doc(docId).delete();
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data ayam berhasil dihapus')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data ayam: $e')),
        );
      }
    }
  }

  void _lihatDetailAyam(Map<String, dynamic> ayam) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailAyamScreen(ayam: ayam)),
    );
  }

  int _totalJumlah(Map<String, dynamic> ayam) {
    int sehat = ayam['jumlah_sehat'] ?? 0;
    int mati = ayam['jumlah_mati'] ?? 0;
    return sehat + mati;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Tambah Data Ayam',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: Colors.green[800]),
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
                _refreshData();
              });
            },
            itemBuilder:
                (context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Semua',
                    child: Text('Semua Status'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Sehat',
                    child: Text('Sehat'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Mati',
                    child: Text('Mati'),
                  ),
                ],
          ),
        ],
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
                      hintText: 'Cari berdasarkan tanggal atau umur',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSubmitted: (value) {
                      _fetchAyamData();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _fetchAyamData,
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
                    'Total ${_listAyam.length} Jenis Ayam',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                Chip(
                  label: Text(_selectedStatus),
                  backgroundColor: Colors.green[50],
                  labelStyle: TextStyle(color: Colors.green[800]),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: _fetchAyamData,
                      child:
                          _listAyam.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.pets,
                                      size: 60,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum ada data ayam',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tambahkan data ayam Anda',
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
                                itemCount: _listAyam.length,
                                itemBuilder: (context, index) {
                                  final ayam = _listAyam[index];
                                  return _buildAyamCard(ayam);
                                },
                              ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahDataAyam,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildAyamCard(Map<String, dynamic> ayam) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _lihatDetailAyam(ayam),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with date and buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tanggal: ${ayam['tanggal'] ?? '-'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                        onPressed: () => _editDataAyam(ayam),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () => _deleteDataAyam(ayam['docId']),
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
                  _statusInfo('Sehat', ayam['jumlah_sehat'] ?? 0, Colors.green),
                  _statusInfo('Mati', ayam['jumlah_mati'] ?? 0, Colors.red),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${_totalJumlah(ayam)} ekor',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusInfo(String label, int jumlah, Color color) {
    return Column(
      children: [
        Icon(Icons.pets, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          jumlah.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 13,
          ),
        ),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }
}

class TambahAyamScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAyamDitambahkan;
  final Map<String, dynamic>? ayamData;

  const TambahAyamScreen({
    super.key,
    required this.onAyamDitambahkan,
    this.ayamData,
  });

  @override
  State<TambahAyamScreen> createState() => _TambahAyamScreenState();
}

class _TambahAyamScreenState extends State<TambahAyamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahSehatController = TextEditingController();
  final _jumlahMatiController = TextEditingController();
  final _umurController = TextEditingController();
  final _deskripsiController = TextEditingController();
  DateTime? _tanggal;

  @override
  void initState() {
    super.initState();
    if (widget.ayamData != null) {
      _jumlahSehatController.text =
          (widget.ayamData!['jumlah_sehat'] ?? 0).toString();
      _jumlahMatiController.text =
          (widget.ayamData!['jumlah_mati'] ?? 0).toString();
      _umurController.text = widget.ayamData!['umur'] ?? '';
      _deskripsiController.text = widget.ayamData!['deskripsi'] ?? '';
      _tanggal = DateTime.tryParse(widget.ayamData!['tanggal'] ?? '');
    }
  }

  @override
  void dispose() {
    _jumlahSehatController.dispose();
    _jumlahMatiController.dispose();
    _umurController.dispose();
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

  void _simpanDataAyam() {
    if (_formKey.currentState!.validate() && _tanggal != null) {
      final ayamBaru = {
        'tanggal': _tanggal!.toIso8601String().split('T').first,
        'jumlah_sehat': int.tryParse(_jumlahSehatController.text) ?? 0,
        'jumlah_mati': int.tryParse(_jumlahMatiController.text) ?? 0,
        'umur': _umurController.text,
        'deskripsi': _deskripsiController.text,
      };

      widget.onAyamDitambahkan(ayamBaru);
      Navigator.pop(context);
    } else if (_tanggal == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Silakan pilih tanggal')));
    }
  }

  String? _validateOptionalPositiveInt(String? value) {
    if (value == null || value.isEmpty) {
      return null; // allow empty field
    }
    final n = int.tryParse(value);
    if (n == null || n < 0) {
      return 'Masukkan angka valid >= 0';
    }
    return null;
  }

  String? _validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tidak boleh kosong';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Data Ayam')),
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
                controller: _jumlahSehatController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Ayam Sehat',
                  prefixIcon: Icon(
                    Icons.health_and_safety,
                    color: Colors.green[700],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: _validateOptionalPositiveInt,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahMatiController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Ayam Mati',
                  prefixIcon: Icon(Icons.close_rounded, color: Colors.red[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: _validateOptionalPositiveInt,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _umurController,
                decoration: InputDecoration(
                  labelText: 'Umur Ayam (minggu)',
                  prefixIcon: Icon(Icons.schedule, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
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
                  onPressed: _simpanDataAyam,
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

class DetailAyamScreen extends StatelessWidget {
  final Map<String, dynamic> ayam;

  const DetailAyamScreen({super.key, required this.ayam});

  @override
  Widget build(BuildContext context) {
    int sehat = ayam['jumlah_sehat'] ?? 0;
    int mati = ayam['jumlah_mati'] ?? 0;
    int total = sehat + mati;

    return Scaffold(
      appBar: AppBar(title: Text(ayam['tanggal'] ?? 'Detail Ayam')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal: ${ayam['tanggal'] ?? '-'}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statusInfo('Sehat', sehat, Colors.green),
                    _statusInfo('Mati', mati, Colors.red),
                    Column(
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$total',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              children: [
                _buildDetailItem('Umur', '${ayam['umur'] ?? '-'} minggu'),
                _buildDetailItem('Deskripsi', ayam['deskripsi'] ?? '-'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusInfo(String label, int jumlah, Color color) {
    return Column(
      children: [
        Icon(Icons.pets, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          jumlah.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
