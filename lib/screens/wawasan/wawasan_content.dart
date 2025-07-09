import 'package:flutter/material.dart';

class WawasanContent {
  final Color primaryColor;
  final Color darkGreen;
  final Color lightGreen;

  WawasanContent({
    required this.primaryColor,
    required this.darkGreen,
    required this.lightGreen,
  });

  // ================ MANAJEMEN KANDANG ================
  Widget buildCageManagementContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Manajemen Kandang Modern'),

          _buildInfoCard(
            icon: Icons.thermostat,
            title: "Kontrol Lingkungan",
            items: [
              "Suhu ideal: 20-25°C",
              "Kelembaban: 60-70%",
              "Ventilasi udara yang cukup",
              "Kadar amonia < 10 ppm",
            ],
          ),

          _buildComparisonTable(
            title: "Standar Kepadatan Kandang",
            headers: ["Tipe Kandang", "Jumlah Ayam/m²", "Ketinggian"],
            rows: [
              ["Baterai", "6-8 ekor", "40-45 cm"],
              ["Litter", "4-5 ekor", "Minimal 2 m"],
              ["Koloni", "3-4 ekor", "Minimal 2.5 m"],
            ],
          ),

          _buildTechFeature(
            icon: Icons.settings,
            title: "Sistem Otomatisasi",
            description:
                "Kontrol suhu, kelembaban, dan pencahayaan secara otomatis",
          ),

          _buildTechFeature(
            icon: Icons.light_mode,
            title: "Pencahayaan",
            description: "Durasi 14-16 jam/hari dengan intensitas 10-20 lux",
          ),
        ],
      ),
    );
  }

  // ================ PAKAN BERKUALITAS ================
  Widget buildFeedQualityContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Nutrisi Ayam Petelur'),

          _buildNutritionCard(
            protein: "16-18%",
            calcium: "3.5-4%",
            phosphorus: "0.4-0.5%",
            energy: "2800-2900 kcal/kg",
          ),

          _buildInfoCard(
            icon: Icons.schedule,
            title: "Jadwal Pemberian Pakan",
            items: [
              "Pagi (06.00): 40% kebutuhan",
              "Siang (12.00): 30% kebutuhan",
              "Sore (17.00): 30% kebutuhan",
            ],
          ),

          _buildFeedIngredient(
            name: "Bungkil Kedelai",
            benefit: "Sumber protein nabati (45-50% protein)",
            usage: "20-25% campuran pakan",
          ),

          _buildFeedIngredient(
            name: "Tepung Ikan",
            benefit: "Sumber protein hewani dan asam amino",
            usage: "5-8% campuran pakan",
          ),
        ],
      ),
    );
  }

  // ================ KESEHATAN AYAM ================
  Widget buildChickenHealthContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Manajemen Kesehatan'),

          _buildVaccineSchedule(),

          _buildDiseaseCard(
            disease: "Newcastle Disease (ND)",
            symptoms: "Sesak nafas, diare, leher terpuntir",
            prevention: "Vaksinasi teratur dan biosekuriti ketat",
          ),

          _buildDiseaseCard(
            disease: "Avian Influenza (AI)",
            symptoms: "Demam tinggi, batuk, diare, kematian mendadak",
            prevention: "Vaksinasi dan isolasi kandang saat wabah",
          ),

          _buildPreventionStep(
            step: "1",
            title: "Biosekuriti",
            description: "Kontrol lalu lintas orang dan peralatan",
          ),

          _buildPreventionStep(
            step: "2",
            title: "Sanitasi",
            description: "Desinfeksi kandang secara rutin",
          ),
        ],
      ),
    );
  }

  // ================ PRODUKSI TELUR ================
  Widget buildEggProductionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Optimalisasi Produksi Telur'),

          _buildProductionChart(),

          _buildInfoCard(
            icon: Icons.egg,
            title: "Faktor Kualitas Telur",
            items: [
              "Ketebalan cangkang (>0.33 mm)",
              "Indeks kuning telur (0.42-0.48)",
              "Berat telur (55-65 gram)",
            ],
          ),

          _buildQualityTip(
            tip: "Tingkatkan kalsium untuk cangkang yang kuat",
            icon: Icons.construction,
          ),
        ],
      ),
    );
  }

  // ================ SANITASI KANDANG ================
  Widget buildSanitationContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Sanitasi dan Kebersihan Kandang'),

          _buildInfoCard(
            icon: Icons.cleaning_services,
            title: 'Pentingnya Sanitasi',
            items: [
              'Membersihkan kandang secara rutin',
              'Pengelolaan limbah dan kotoran',
              'Desinfeksi alat dan peralatan',
            ],
          ),

          _buildTechFeature(
            icon: Icons.water_damage,
            title: 'Pengelolaan Air',
            description: 'Penyediaan air bersih dan teratur untuk ayam',
          ),
        ],
      ),
    );
  }

  // ================ PENCEGAHAN STRES AYAM ================
  Widget buildStressPreventionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Pencegahan Stres pada Ayam Petelur'),

          _buildInfoCard(
            icon: Icons.spa,
            title: 'Faktor Penyebab Stres',
            items: [
              'Kepadatan kandang terlalu tinggi',
              'Cahaya berlebihan atau kurang',
              'Suhu lingkungan ekstrem',
              'Perubahan lingkungan mendadak',
            ],
          ),

          _buildTechFeature(
            icon: Icons.mood,
            title: 'Strategi Pencegahan',
            description:
                'Pemberian vitamin dan makanan bergizi, pengaturan cahaya, dan lingkungan nyaman',
          ),
        ],
      ),
    );
  }

  // ================ PENGENDALIAN HAMA ================
  Widget buildPestControlContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Pengendalian Hama dan Parasit'),

          _buildInfoCard(
            icon: Icons.bug_report,
            title: 'Jenis Hama Umum',
            items: ['Kutu ayam', 'Lalat', 'Tikus'],
          ),

          _buildTechFeature(
            icon: Icons.shield,
            title: 'Metode Pengendalian',
            description:
                'Penggunaan pestisida alami, sanitasi kandang, dan penghalang fisik',
          ),
        ],
      ),
    );
  }

  // ================ PENGELOLAAN SUHU ================
  Widget buildTemperatureManagementContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Pengelolaan Suhu Lingkungan'),

          _buildInfoCard(
            icon: Icons.thermostat_outlined,
            title: 'Rentang Suhu Ideal',
            items: [
              '20-25°C untuk pertumbuhan optimal',
              'Suhu ekstrem dapat mengganggu produksi telur',
            ],
          ),

          _buildTechFeature(
            icon: Icons.ac_unit,
            title: 'Teknologi Pendinginan',
            description:
                'Penggunaan kipas angin dan sistem pendingin evaporatif',
          ),
        ],
      ),
    );
  }

  // ================ PENINGKATAN PRODUKTIVITAS ================
  Widget buildProductivityImprovementContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Peningkatan Produktivitas Ayam Petelur'),

          _buildInfoCard(
            icon: Icons.trending_up,
            title: 'Faktor-Faktor Utama',
            items: [
              'Nutrisi berkualitas',
              'Manajemen kandang yang baik',
              'Kesehatan ayam terjaga',
            ],
          ),

          _buildTechFeature(
            icon: Icons.auto_awesome,
            title: 'Praktik Terbaik',
            description:
                'Rotasi kandang, program vaksinasi, dan monitoring perkembangan produksi',
          ),
        ],
      ),
    );
  }

  // ============== COMPONENT BUILDERS ==============
  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: darkGreen,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $item'),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedIngredient({
    required String name,
    required String benefit,
    required String usage,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: lightGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold, color: darkGreen),
          ),
          const SizedBox(height: 4),
          Text(benefit),
          const SizedBox(height: 4),
          Text(
            "Penggunaan: $usage",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineSchedule() {
    return _buildInfoCard(
      icon: Icons.medical_services,
      title: "Jadwal Vaksinasi",
      items: [
        "Hari 1: Vaksin Marek (in ovo)",
        "Minggu 1: Vaksin ND-IB",
        "Minggu 4: Vaksin ND-IB-EDS",
        "Minggu 8: Vaksin AI",
        "Minggu 12: Booster ND-IB",
      ],
    );
  }

  Widget _buildDiseaseCard({
    required String disease,
    required String symptoms,
    required String prevention,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              disease,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text("Gejala: $symptoms"),
            const SizedBox(height: 4),
            Text("Pencegahan: $prevention"),
          ],
        ),
      ),
    );
  }

  Widget _buildPreventionStep({
    required String step,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard({
    required String protein,
    required String calcium,
    required String phosphorus,
    required String energy,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Komposisi Nutrisi Pakan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildNutritionRow("Protein", protein),
            _buildNutritionRow("Kalsium", calcium),
            _buildNutritionRow("Fosfor", phosphorus),
            _buildNutritionRow("Energi", energy),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [SizedBox(width: 80, child: Text(label)), Text(": $value")],
      ),
    );
  }

  Widget _buildProductionChart() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Siklus Produksi Telur",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildChartRow("Starter", "0-6 minggu", "0%"),
            _buildChartRow("Grower", "6-18 minggu", "0%"),
            _buildChartRow("Pre-lay", "18-20 minggu", "5-50%"),
            _buildChartRow("Peak", "25-40 minggu", "90-95%"),
            _buildChartRow("Post-peak", "40-72 minggu", "80-85%"),
          ],
        ),
      ),
    );
  }

  Widget _buildChartRow(String phase, String age, String production) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              phase,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text("$age ($production)"),
        ],
      ),
    );
  }

  Widget _buildQualityTip({required String tip, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(tip)),
        ],
      ),
    );
  }

  Widget _buildComparisonTable({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: darkGreen),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns:
                    headers
                        .map(
                          (header) => DataColumn(
                            label: Text(
                              header,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                rows:
                    rows
                        .map(
                          (row) => DataRow(
                            cells:
                                row
                                    .map((cell) => DataCell(Text(cell)))
                                    .toList(),
                          ),
                        )
                        .toList(),
                headingRowHeight: 40,
                dataRowHeight: 36,
                columnSpacing: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
