import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

// متغير عام للتحكم في الثيم من أي مكان في التطبيق
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

void main() async {
  // السطر ده ضروري عشان نقدر نستخدم SharedPreferences قبل ما التطبيق يفتح
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  isDarkModeNotifier.value = prefs.getBool('is_dark_mode') ?? false;
  
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    // الأداة دي بتراقب المتغير، وأول ما يتغير بتعمل ريفريش للتطبيق كله فورا
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'تطبيق المصحف',
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          // إعدادات الثيم الفاتح
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.yellow.shade50,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
            ),
          ),
          // إعدادات الثيم الغامق
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.white,
            ),
            cardColor: Colors.grey.shade800,
          ),
          home: const HomePage(),
        );
      },
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
  List filteredSurahs = [];
  int lastReadPage = 1;
  TextEditingController searchController = TextEditingController();

  final List<int> surahStartingPage = [
    1, 2, 50, 77, 106, 128, 151, 177, 187, 208, 221, 235, 249, 255, 262, 267, 282, 293, 305, 312, 322, 332, 342, 350, 359, 367, 377, 385, 396, 404, 411, 415, 418, 428, 434, 440, 446, 453, 458, 467, 477, 483, 489, 496, 499, 502, 507, 511, 515, 518, 520, 523, 526, 528, 531, 534, 537, 542, 545, 549, 551, 553, 554, 556, 558, 560, 562, 564, 566, 568, 570, 572, 574, 575, 577, 578, 580, 582, 583, 585, 586, 587, 587, 589, 590, 591, 591, 592, 593, 594, 595, 595, 596, 596, 597, 597, 598, 598, 599, 599, 600, 600, 601, 601, 601, 602, 602, 602, 603, 603, 603, 604, 604, 604
  ];

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/quran_full.json');
    final data = await json.decode(response);
    setState(() {
      surahs = data;
      filteredSurahs = data;
    });
  }

  Future<void> loadLastReadPage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lastReadPage = prefs.getInt('last_read_page') ?? 1;
    });
  }

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
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'القرآن الكريم',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'AmiriQuran'),
        ),
        centerTitle: true,
        actions: [
          // زرار التبديل بين الوضع الليلي والنهاري
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () async {
              isDarkModeNotifier.value = !isDark;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_dark_mode', !isDark);
            },
          )
        ],
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
        backgroundColor: isDark ? Colors.grey.shade700 : Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              onChanged: filterSearch,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: "ابحث عن اسم السورة...",
                hintTextDirection: TextDirection.rtl,
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey : Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: isDark ? Colors.grey : Colors.green.shade800),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.white,
              ),
            ),
          ),
          Expanded(
            child: filteredSurahs.isEmpty
                ? const Center(child: Text("جاري التحميل أو لا توجد نتائج", style: TextStyle(fontFamily: 'AmiriQuran', fontSize: 18)))
                : ListView.builder(
                    itemCount: filteredSurahs.length,
                    itemBuilder: (context, index) {
                      var currentSurah = filteredSurahs[index];
                      String typeAr = currentSurah["type"] == "meccan" ? "مكية" : "مدنية";
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
                            backgroundColor: isDark ? Colors.grey.shade700 : Colors.green.shade100,
                            child: Text(
                              surahId.toString(),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.green.shade900, 
                                fontWeight: FontWeight.bold
                              ),
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
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
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
  bool _showAppBar = false; // متغير للتحكم في ظهور وإخفاء الشريط

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage - 1);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // السطر ده بيخلي الصورة تمتد ورا الشريط عشان تاخد الشاشة كلها
      extendBodyBehindAppBar: true, 
      
      // الشريط هيظهر ويختفي بناءً على لمسة المستخدم
      appBar: _showAppBar 
          ? AppBar(
              backgroundColor: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
              elevation: 0, // بنشيل الظل عشان يبان مسطح واحترافي
              iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
              title: Text(
                "المصحف الشريف",
                style: TextStyle(
                  fontFamily: 'AmiriQuran', 
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold
                ),
              ),
              centerTitle: true,
            )
          : null, // لو المتغير بـ false الشريط بيختفي تماماً

      // كود لون الخلفية ده مقارب جداً للون أطراف صفحة المصحف عشان يندمج معاها
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xffFDF8F2),
      
      body: GestureDetector(
        // لما المستخدم يضغط في أي مكان في الشاشة، بنعكس حالة الشريط (يظهر أو يختفي)
        onTap: () {
          setState(() {
            _showAppBar = !_showAppBar;
          });
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 604, 
            onPageChanged: (index) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('last_read_page', index + 1);
            },
            itemBuilder: (context, index) {
              String pageNumber = (index + 1).toString().padLeft(3, '0');
              
              Widget quranImage = CachedNetworkImage(
                imageUrl: 'https://raw.githubusercontent.com/GovarJabbar/Quran-PNG/master/$pageNumber.png',
                // استخدمنا fitWidth عشان الصورة تعرض بعرض الشاشة بالكامل زي الصورة اللي بعتها
                fit: BoxFit.fitWidth,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.red, size: 50)),
              );
              
              return SafeArea(
                // بنلغي الـ SafeArea من تحت عشان الصورة تنزل للآخر
                bottom: false, 
                child: InteractiveViewer(
                  child: isDark 
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            -1,  0,  0, 0, 255,
                             0, -1,  0, 0, 255,
                             0,  0, -1, 0, 255,
                             0,  0,  0, 1,   0,
                          ]),
                          child: quranImage,
                        )
                      : quranImage,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}