import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart'; // مكتبة الحفظ

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
  List filteredSurahs = []; // قائمة جديدة هنخزن فيها نتائج البحث
  int lastReadPage = 1;
  TextEditingController searchController = TextEditingController(); // متحكم شريط البحث

  final List<int> surahStartingPage = [
    1, 2, 50, 77, 106, 128, 151, 177, 187, 208, 221, 235, 249, 255, 262, 267, 282, 293, 305, 312, 322, 332, 342, 350, 359, 367, 377, 385, 396, 404, 411, 415, 418, 428, 434, 440, 446, 453, 458, 467, 477, 483, 489, 496, 499, 502, 507, 511, 515, 518, 520, 523, 526, 528, 531, 534, 537, 542, 545, 549, 551, 553, 554, 556, 558, 560, 562, 564, 566, 568, 570, 572, 574, 575, 577, 578, 580, 582, 583, 585, 586, 587, 587, 589, 590, 591, 591, 592, 593, 594, 595, 595, 596, 596, 597, 597, 598, 598, 599, 599, 600, 600, 601, 601, 601, 602, 602, 602, 603, 603, 603, 604, 604, 604
  ];

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/quran_full.json');
    final data = await json.decode(response);
    setState(() {
      surahs = data;
      filteredSurahs = data; // في البداية، بنعرض كل السور
    });
  }

  Future<void> loadLastReadPage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lastReadPage = prefs.getInt('last_read_page') ?? 1;
    });
  }

  // دالة البحث اللي بتفلتر السور حسب الحروف اللي المستخدم بيكتبها
  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSurahs = surahs;
      } else {
        filteredSurahs = surahs.where((surah) {
          return surah["name"].contains(query);
        }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
    loadLastReadPage();
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MushafPage(initialPage: lastReadPage),
            ),
          );
          loadLastReadPage();
        },
        label: Text('متابعة القراءة ($lastReadPage)', 
          style: const TextStyle(fontFamily: 'AmiriQuran', fontWeight: FontWeight.bold, fontSize: 16)),
        icon: const Icon(Icons.menu_book),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              onChanged: filterSearch,
              textDirection: TextDirection.rtl, // الكتابة من اليمين
              decoration: InputDecoration(
                hintText: "ابحث عن اسم السورة...",
                hintTextDirection: TextDirection.rtl,
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.green.shade800),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // قائمة السور
          Expanded(
            child: filteredSurahs.isEmpty
                ? const Center(child: Text("جاري التحميل أو لا توجد نتائج", style: TextStyle(fontFamily: 'AmiriQuran', fontSize: 18)))
                : ListView.builder(
                    itemCount: filteredSurahs.length,
                    itemBuilder: (context, index) {
                      // هنا التريك: بنجيب بيانات السورة الحالية من القائمة المفلترة
                      var currentSurah = filteredSurahs[index];
                      String typeAr = currentSurah["type"] == "meccan" ? "مكية" : "مدنية";
                      
                      // بنستخدم الـ id الحقيقي للسورة عشان نجيب صفحتها، مش ترتيبها في القائمة
                      int surahId = currentSurah["id"]; 
                      int startingPage = surahStartingPage[surahId - 1];

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MushafPage(initialPage: startingPage),
                              ),
                            );
                            loadLastReadPage();
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Text(
                              surahId.toString(),
                              style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            currentSurah["name"],
                            style: const TextStyle(fontSize: 24, fontFamily: 'AmiriQuran', fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "آياتها: ${currentSurah["total_verses"]} - $typeAr",
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
          ),
        ],
      ),
    );
  }
}

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
          // الخاصية دي بتشتغل مع كل تقليبة صفحة عشان تحفظ الرقم الجديد
          onPageChanged: (index) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('last_read_page', index + 1);
          },
          itemBuilder: (context, index) {
            String pageNumber = (index + 1).toString().padLeft(3, '0');
            
            return InteractiveViewer(
              child: CachedNetworkImage(
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