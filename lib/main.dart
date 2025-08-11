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
        colorSchemeSeed: const Color(0xFFB3E283),
        scaffoldBackgroundColor: const Color(0xFFFFFDE7),
        textTheme: GoogleFonts.nunitoTextTheme(),
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
  static const _lastIndexKey = 'lastIndex';
  static const _favKey = 'favorite_ids';

  List<dynamic> pituturList = [];
  int? lastIndex; // simpan indeks terakhir
  final Set<int> favoriteIds = {}; // simpan id favorit (pakai index)

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

    final ids = prefs.getStringList(_favKey) ?? [];
    setState(() {
      pituturList = data;
      lastIndex = prefs.getInt(_lastIndexKey);
      favoriteIds
        ..clear()
        ..addAll(ids.map(int.parse));
    });
  }

  Future<void> acakPitutur() async {
    if (pituturList.isEmpty) return;
    final random = Random();
    final idx = random.nextInt(pituturList.length);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastIndexKey, idx);

    setState(() {
      lastIndex = idx;
    });
  }

  Future<void> _saveFavorites() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(
      _favKey,
      favoriteIds.map((e) => e.toString()).toList(),
    );
  }

  void _toggleFavorite(int id) async {
    if (favoriteIds.contains(id)) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }
    await _saveFavorites();
    setState(() {});
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
    final Map<String, dynamic>? lastPitutur =
        (lastIndex != null && lastIndex! < pituturList.length)
        ? pituturList[lastIndex!]
        : null;

    final favItems = favoriteIds
        .where((i) => i >= 0 && i < pituturList.length)
        .map((i) => pituturList[i])
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: TabBarView(
            children: [_buildAllTab(lastPitutur), _buildFavoritesTab(favItems)],
          ),
        ),
      ),
    );
  }

  /// TAB: ALL
  Widget _buildAllTab(Map<String, dynamic>? lastPitutur) {
    return Column(
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: const StadiumBorder(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (lastPitutur != null) ...[
          _buildHighlightCard(lastPitutur, lastIndex!),
          const SizedBox(height: 24),
        ],
        const Divider(),
        Text(
          "Kumpulan Pitutur:",
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildQuoteList(pituturList)),
      ],
    );
  }

  /// TAB: FAVORITES
  Widget _buildFavoritesTab(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Belum ada favorit'));
    }
    return _buildQuoteList(items, isFavoritesView: true);
  }

  /// Kartu highlight (random)
  Widget _buildHighlightCard(Map<String, dynamic> item, int id) {
    final teks = (item['teks'] ?? '').trim();
    final arti = (item['arti'] ?? '').trim();
    final emoji = getEmoji(teks);
    final isFav = favoriteIds.contains(id);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleFavorite(id),
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                  color: isFav ? Colors.red : Colors.grey[700],
                  tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              teks,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              arti,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
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
    );
  }

  /// List pitutur (dipakai All & Favorites)
  Widget _buildQuoteList(List<dynamic> items, {bool isFavoritesView = false}) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, idx) {
        // cari id asli (index pada list penuh)
        final item = items[idx];
        final id = isFavoritesView ? pituturList.indexOf(item) : idx;
        final isFav = favoriteIds.contains(id);

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
            trailing: IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
              color: isFav ? Colors.red : null,
              onPressed: () => _toggleFavorite(id),
              tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
            ),
          ),
        );
      },
    );
  }
}
