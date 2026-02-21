import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart'; // مكتبة الكاش للصور

void main() {
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق المصحف',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.yellow.shade50, 
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List surahs = [];
  // دي أرقام الصفحات اللي بتبدأ منها كل سورة من الـ 114 بالترتيب
  final List<int> surahStartingPage = [
    1, 2, 50, 77, 106, 128, 151, 177, 187, 208, 221, 235, 249, 255, 262, 267, 282, 293, 305, 312, 322, 332, 342, 350, 359, 367, 377, 385, 396, 404, 411, 415, 418, 428, 434, 440, 446, 453, 458, 467, 477, 483, 489, 496, 499, 502, 507, 511, 515, 518, 520, 523, 526, 528, 531, 534, 537, 542, 545, 549, 551, 553, 554, 556, 558, 560, 562, 564, 566, 568, 570, 572, 574, 575, 577, 578, 580, 582, 583, 585, 586, 587, 587, 589, 590, 591, 591, 592, 593, 594, 595, 595, 596, 596, 597, 597, 598, 598, 599, 599, 600, 600, 601, 601, 601, 602, 602, 602, 603, 603, 603, 604, 604, 604
  ];

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/quran_full.json');
    final data = await json.decode(response);
    setState(() {
      surahs = data;
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'القرآن الكريم',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'AmiriQuran'),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: surahs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: surahs.length,
              itemBuilder: (context, index) {
                String typeAr = surahs[index]["type"] == "meccan" ? "مكية" : "مدنية";

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // هنا خلينا التطبيق يسحب رقم الصفحة الصح بناءً على ترتيب السورة
                          builder: (context) => MushafPage(initialPage: surahStartingPage[index]),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Text(
                        surahs[index]["id"].toString(),
                        style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      surahs[index]["name"],
                      style: const TextStyle(fontSize: 24, fontFamily: 'AmiriQuran', fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "آياتها: ${surahs[index]["total_verses"]} - $typeAr",
                      style: TextStyle(
                        fontFamily: 'AmiriQuran',
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}

// ==========================================
// --- الشاشة الجديدة (نظام صور المصحف بالكاش) ---
// ==========================================
class MushafPage extends StatefulWidget {
  final int initialPage;

  const MushafPage({super.key, required this.initialPage});

  @override
  State<MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends State<MushafPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "المصحف الشريف",
          style: TextStyle(fontFamily: 'AmiriQuran', fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.yellow.shade50,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: PageView.builder(
          controller: _pageController,
          itemCount: 604, 
          itemBuilder: (context, index) {
            String pageNumber = (index + 1).toString().padLeft(3, '0');
            
            return InteractiveViewer(
              child: CachedNetworkImage(
                // ده الرابط الجديد الشغال 100%
                imageUrl: 'https://raw.githubusercontent.com/GovarJabbar/Quran-PNG/master/$pageNumber.png',
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.red, size: 50)),
              ),
            );
          },
        ),
      ),
    );
  }
}