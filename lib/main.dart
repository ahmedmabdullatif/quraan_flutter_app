import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:ui';

// Dark Mode Notifier
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحجيم الذاكرة لمنع خروج التطبيق (OOM Fix)
  PaintingBinding.instance.imageCache.maximumSize = 50;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;

  final prefs = await SharedPreferences.getInstance();
  isDarkModeNotifier.value = prefs.getBool('is_dark_mode') ?? false;

  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'تطبيق المصحف الشريف',

          // إعدادات اللغة العربية والاتجاه من اليمين لليسار
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar', 'AE')],
          locale: const Locale('ar', 'AE'),

          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.yellow.shade50,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.white,
            ),
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

  // خريطة بدايات السور
  final List<int> surahStartingPage = [
    1,
    2,
    50,
    77,
    106,
    128,
    151,
    177,
    187,
    208,
    221,
    235,
    249,
    255,
    262,
    267,
    282,
    293,
    305,
    312,
    322,
    332,
    342,
    350,
    359,
    367,
    377,
    385,
    396,
    404,
    411,
    415,
    418,
    428,
    434,
    440,
    446,
    453,
    458,
    467,
    477,
    483,
    489,
    496,
    499,
    502,
    507,
    511,
    515,
    518,
    520,
    523,
    526,
    528,
    531,
    534,
    537,
    542,
    545,
    549,
    551,
    553,
    554,
    556,
    558,
    560,
    562,
    564,
    566,
    568,
    570,
    572,
    574,
    575,
    577,
    578,
    580,
    582,
    583,
    585,
    586,
    587,
    587,
    589,
    590,
    591,
    591,
    592,
    593,
    594,
    595,
    595,
    596,
    596,
    597,
    597,
    598,
    598,
    599,
    599,
    600,
    600,
    601,
    601,
    601,
    602,
    602,
    602,
    603,
    603,
    603,
    604,
    604,
    604,
  ];

  // خريطة بدايات الأجزاء
  final List<int> juzStartingPages = [
    1,
    22,
    42,
    62,
    82,
    102,
    121,
    142,
    162,
    182,
    201,
    222,
    242,
    262,
    282,
    302,
    322,
    342,
    362,
    382,
    402,
    422,
    442,
    462,
    482,
    502,
    522,
    542,
    562,
    582,
  ];

  Future<void> readJson() async {
    final String response = await rootBundle.loadString(
      'assets/quran_full.json',
    );
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

  @override
  void initState() {
    super.initState();
    readJson();
    loadLastReadPage();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'فهرس المصحف',
            style: TextStyle(
              fontFamily: 'AmiriQuran',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "السور"),
              Tab(text: "الأجزاء"),
            ],
            indicatorColor: Colors.amber,
            labelStyle: TextStyle(
              fontFamily: 'AmiriQuran',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () async {
                isDarkModeNotifier.value = !isDark;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('is_dark_mode', !isDark);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => MushafPage(initialPage: lastReadPage),
              ),
            );
            loadLastReadPage();
          },
          label: Text(
            'متابعة القراءة ($lastReadPage)',
            style: const TextStyle(fontFamily: 'AmiriQuran'),
          ),
          icon: const Icon(Icons.menu_book),
          backgroundColor: isDark
              ? Colors.grey.shade800
              : Colors.green.shade800,
          foregroundColor: Colors.white,
        ),
        body: TabBarView(
          children: [
            // التبويب الأول: السور
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => setState(
                      () => filteredSurahs = surahs
                          .where((s) => s["name"].contains(value))
                          .toList(),
                    ),
                    decoration: InputDecoration(
                      hintText: "ابحث عن سورة...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredSurahs.length,
                    itemBuilder: (context, index) {
                      var surah = filteredSurahs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          title: Text(
                            surah["name"],
                            style: const TextStyle(
                              fontFamily: 'AmiriQuran',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text("آياتها: ${surah["total_verses"]}"),
                          leading: CircleAvatar(
                            child: Text(surah["id"].toString()),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => MushafPage(
                                  initialPage:
                                      surahStartingPage[surah["id"] - 1],
                                ),
                              ),
                            );
                            loadLastReadPage();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // التبويب الثاني: الأجزاء
            ListView.builder(
              itemCount: 30,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isDark
                          ? Colors.amber.shade900
                          : Colors.green.shade100,
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.green.shade900,
                        ),
                      ),
                    ),
                    title: Text(
                      "الجزء ${index + 1}",
                      style: const TextStyle(
                        fontFamily: 'AmiriQuran',
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Text("يبدأ من صفحة: ${juzStartingPages[index]}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) =>
                              MushafPage(initialPage: juzStartingPages[index]),
                        ),
                      );
                      loadLastReadPage();
                    },
                  ),
                );
              },
            ),
          ],
        ),
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
  bool _showAppBar = false;
  final TextEditingController _jumpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage - 1);
    _saveCurrentPage(widget.initialPage);
    _precachePages(widget.initialPage - 1);
  }

  Future<void> _saveCurrentPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_page', pageNumber);
  }

  void _precachePages(int currentIndex) {
    Future.delayed(const Duration(seconds: 1), () {
      for (var i = 1; i <= 2; i++) {
        if (currentIndex + i < 604) {
          String nextPg = (currentIndex + i + 1).toString().padLeft(3, '0');
          if (mounted) {
            precacheImage(
              CachedNetworkImageProvider(
                'https://raw.githubusercontent.com/GovarJabbar/Quran-PNG/master/$nextPg.png',
              ),
              context,
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color screenBgColor = isDark
        ? const Color(0xFF000000)
        : const Color(0xffEAEAEA);
    Color paperColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xffFAF7F3);

    return Scaffold(
      backgroundColor: screenBgColor,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showAppBar = !_showAppBar),
            child: PageView.builder(
              controller: _pageController,
              itemCount: 604,
              onPageChanged: (index) {
                _saveCurrentPage(index + 1);
                _precachePages(index);
              },
              itemBuilder: (context, index) {
                String pg = (index + 1).toString().padLeft(3, '0');

                return LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWeb = constraints.maxWidth > 600;

                    Widget pageText = CachedNetworkImage(
                      imageUrl:
                          'https://raw.githubusercontent.com/GovarJabbar/Quran-PNG/master/$pg.png',
                      fit: BoxFit.fitWidth,
                      placeholder: (context, url) => Container(
                        height: constraints.maxHeight,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error, color: Colors.red),
                      ),
                    );

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      // التعديل هنا: إجبار المحتوى على أخذ طول الشاشة كحد أدنى للتوسيط
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        // السنتر دلوقتي هيوسطن الصفحة رأسياً وأفقياً بامتياز
                        child: Center(
                          child: Container(
                            width: isWeb ? 500 : constraints.maxWidth,
                            margin: EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: isWeb ? 20 : 0,
                            ),
                            decoration: BoxDecoration(
                              color: paperColor,
                              borderRadius: isWeb
                                  ? BorderRadius.circular(15)
                                  : BorderRadius.zero,
                              boxShadow: isWeb
                                  ? [
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black54
                                            : Colors.black12,
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize
                                  .min, // مهمة عشان الورقة متتمطش بزيادة
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 60,
                                    bottom: 20,
                                    left: 0,
                                    right: 0,
                                  ),
                                  child: isDark
                                      ? ColorFiltered(
                                          colorFilter: const ColorFilter.matrix(
                                            [
                                              -1,
                                              0,
                                              0,
                                              0,
                                              255,
                                              0,
                                              -1,
                                              0,
                                              0,
                                              255,
                                              0,
                                              0,
                                              -1,
                                              0,
                                              255,
                                              0,
                                              0,
                                              0,
                                              1,
                                              0,
                                            ],
                                          ),
                                          child: pageText,
                                        )
                                      : pageText,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      fontFamily: 'AmiriQuran',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.grey.shade500
                                          : Colors.brown.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // الشريط العلوي كما هو
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: _showAppBar ? 0 : -130,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: isDark
                      ? Colors.black.withOpacity(0.6)
                      : Colors.white.withOpacity(0.7),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Text(
                          "المصحف الشريف",
                          style: TextStyle(
                            fontFamily: 'AmiriQuran',
                            fontSize: 22,
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          onPressed: () => _showJumpDialog(context, isDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showJumpDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "الانتقال السريع",
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'AmiriQuran'),
        ),
        content: TextField(
          controller: _jumpController,
          keyboardType: TextInputType.number,
          autofocus: true,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: "رقم الصفحة (1 - 604)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text(
                "ذهاب",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                int? p = int.tryParse(_jumpController.text);
                if (p != null && p >= 1 && p <= 604) {
                  _pageController.jumpToPage(p - 1);
                  Navigator.pop(context);
                  _jumpController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
