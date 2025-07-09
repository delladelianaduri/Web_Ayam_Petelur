import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;
  String _selectedCategory = 'Semua';
  final List<String> _categories = [
    'Semua',
    'Ayam',
    'Telur',
    'Vaksin',
    'Pakan',
    'Sanitasi',
  ];
  List<Map<String, dynamic>> _filteredData = [];
  List<Map<String, dynamic>> _historicalData = [];

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    _fetchHistoricalData();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() => _selectedDate = selected);
      await _fetchAllData();
    }
  }

  Future<void> _fetchAllData() async {
    setState(() {
      _loading = true;
      _filteredData = [];
    });

    try {
      final collections = ['ayam', 'telur', 'vaksin', 'pakan', 'sanitasi'];
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final results = await Future.wait(
        collections.map(
          (collection) =>
              FirebaseFirestore.instance
                  .collection(collection)
                  .where('tanggal', isEqualTo: formattedDate)
                  .get(),
        ),
      );

      List<Map<String, dynamic>> allData = [];
      for (int i = 0; i < collections.length; i++) {
        allData.addAll(
          results[i].docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {...data, 'docId': doc.id, 'kategori': collections[i]};
          }),
        );
      }

      setState(() {
        _filteredData = allData;
        _applyFilter();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchHistoricalData() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final formattedDate = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);

      final snapshot =
          await FirebaseFirestore.instance
              .collection('ayam')
              .where('tanggal', isGreaterThanOrEqualTo: formattedDate)
              .orderBy('tanggal')
              .get();

      setState(() {
        _historicalData =
            snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'date': DateFormat(
                  'dd/MM',
                ).format(DateTime.parse(data['tanggal'])),
                'sehat': data['jumlah_sehat'] ?? 0,
                'mati': data['jumlah_mati'] ?? 0,
                'total':
                    (data['jumlah_sehat'] ?? 0) + (data['jumlah_mati'] ?? 0),
              };
            }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data historis: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredData =
          _filteredData
              .where(
                (data) =>
                    _selectedCategory == 'Semua' ||
                    data['kategori'] == _selectedCategory.toLowerCase(),
              )
              .toList();
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan Harian',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, d MMMM y').format(_selectedDate),
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[50],
                      foregroundColor: Colors.green[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items:
                        _categories
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setState(() {
                          _selectedCategory = value!;
                          _applyFilter();
                        }),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await _fetchAllData();
                await _fetchHistoricalData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Muat Ulang Data'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyamChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty || _historicalData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final ayam = data.first;
    final sehat = ayam['jumlah_sehat'] ?? 0;
    final mati = ayam['jumlah_mati'] ?? 0;
    final total = sehat + mati;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend Kondisi Ayam (7 Hari Terakhir)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(labelRotation: -45),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Jumlah Ayam'),
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  LineSeries<Map<String, dynamic>, String>(
                    name: 'Ayam Sehat',
                    dataSource: _historicalData,
                    xValueMapper: (data, _) => data['date'] as String,
                    yValueMapper: (data, _) => data['sehat'] as int,
                    markerSettings: const MarkerSettings(isVisible: true),
                    color: Colors.green,
                    width: 3,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                  LineSeries<Map<String, dynamic>, String>(
                    name: 'Ayam Mati',
                    dataSource: _historicalData,
                    xValueMapper: (data, _) => data['date'] as String,
                    yValueMapper: (data, _) => data['mati'] as int,
                    markerSettings: const MarkerSettings(isVisible: true),
                    color: Colors.red,
                    width: 3,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Total Ayam', total.toString(), Icons.pets),
                _buildStatItem(
                  'Sehat',
                  '$sehat (${total > 0 ? (sehat / total * 100).toStringAsFixed(1) : '0'}%)',
                  Icons.health_and_safety,
                  Colors.green,
                ),
                _buildStatItem(
                  'Mati',
                  '$mati (${total > 0 ? (mati / total * 100).toStringAsFixed(1) : '0'}%)',
                  Icons.close,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.green[700]),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.green[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    if (_filteredData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tidak ada data untuk ditampilkan',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Kategori')),
            DataColumn(label: Text('Detail')),
            DataColumn(label: Text('Jumlah')),
          ],
          rows:
              _filteredData
                  .map(
                    (data) => DataRow(
                      cells: [
                        DataCell(
                          Text(data['kategori'].toString().toUpperCase()),
                        ),
                        DataCell(Text(_getDetailText(data))),
                        DataCell(Text(_getValueText(data))),
                      ],
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  String _getDetailText(Map<String, dynamic> data) {
    switch (data['kategori']) {
      case 'ayam':
        return 'Umur: ${data['umur'] ?? '-'} minggu';
      case 'telur':
        return 'Produksi Telur';
      case 'vaksin':
        return 'Vaksin: ${data['jenis_vaksin'] ?? '-'}';
      case 'pakan':
        return 'Pakan: ${data['jenis_pakan'] ?? '-'}';
      case 'sanitasi':
        return 'Sanitasi Kandang';
      default:
        return '-';
    }
  }

  String _getValueText(Map<String, dynamic> data) {
    switch (data['kategori']) {
      case 'ayam':
        return '${data['jumlah_sehat'] ?? 0} sehat';
      case 'telur':
        return '${data['jumlah_butir'] ?? 0} butir';
      case 'vaksin':
        return '${data['jumlah_ayam'] ?? 0} ekor';
      case 'pakan':
        return '${data['jumlah_kg']?.toStringAsFixed(1) ?? '0'} kg';
      case 'sanitasi':
        return '${data['jumlah_kandang'] ?? 0} kandang';
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Peternakan'),
        backgroundColor: Colors.green[700],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildControls(),
                    _buildAyamChart(
                      _filteredData
                          .where((d) => d['kategori'] == 'ayam')
                          .toList(),
                    ),
                    _buildDataTable(),
                  ],
                ),
              ),
    );
  }
}
