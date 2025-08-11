import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pitutur Luhur Jawi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFB3E283), // 🌿 hijau semangat
        scaffoldBackgroundColor: const Color(0xFFFFFDE7), // ☀️ kuning pastel
        textTheme: GoogleFonts.nunitoTextTheme(), // font bersih & mudah dibaca
      ),
      home: const PituturPage(),
    );
  }
}

class PituturPage extends StatefulWidget {
  const PituturPage({super.key});

  @override
  State<PituturPage> createState() => _PituturPageState();
}

class _PituturPageState extends State<PituturPage> {
  List<dynamic> pituturList = [];
  Map<String, dynamic>? lastPitutur;

  @override
  void initState() {
    super.initState();
    loadPitutur();
  }

  Future<void> loadPitutur() async {
    final String jsonString = await rootBundle.loadString(
      'assets/pitutur.json',
    );
    final List<dynamic> data = json.decode(jsonString);
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      pituturList = data;
      final saved = prefs.getString('lastPitutur');
      if (saved != null) {
        lastPitutur = json.decode(saved);
      }
    });
  }

  void acakPitutur() async {
    if (pituturList.isEmpty) return;

    final random = Random();
    final terpilih = pituturList[random.nextInt(pituturList.length)];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastPitutur', json.encode(terpilih));

    setState(() {
      lastPitutur = terpilih;
    });
  }

  String getEmoji(String text) {
    text = text.toLowerCase();
    if (text.contains('sabar')) return '🧘‍♂️';
    if (text.contains('urip') || text.contains('hidup')) return '🌱';
    if (text.contains('ilmu')) return '📚';
    if (text.contains('gawe') || text.contains('kerja')) return '💪';
    if (text.contains('ati') || text.contains('hati')) return '❤️';
    return '💡';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Pitutur Luhur Jawi',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ElevatedButton.icon(
                onPressed: acakPitutur,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Pirsani Pitutur Saking Acak'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (lastPitutur != null) ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          getEmoji(lastPitutur!['teks'] ?? ''),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        (lastPitutur!['teks'] ?? '').trim(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (lastPitutur!['arti'] ?? '').trim(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          final teks = (lastPitutur!['teks'] ?? '').trim();
                          final arti = (lastPitutur!['arti'] ?? '').trim();
                          final emoji = getEmoji(teks);
                          final message =
                              "$emoji Pitutur Luhur:\n\n\"$teks\"\n\nArti: $arti\n\n📱 via Pitutur Luhur App";

                          Share.share(message);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text("Bagikan ke WhatsApp"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade200,
                          foregroundColor: Colors.black87,
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Divider(),
            Text(
              "Kumpulan Pitutur:",
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: pituturList.length,
                itemBuilder: (context, index) {
                  final item = pituturList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(
                        Icons.format_quote_rounded,
                        color: Colors.green,
                      ),
                      title: Text(
                        item['teks'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(item['arti'] ?? ''),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
