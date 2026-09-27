import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const LudoChampApp());
}

class LudoChampApp extends StatelessWidget {
  const LudoChampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo Champ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const LudoGamePage(),
    );
  }
}

class LudoGamePage extends StatefulWidget {
  const LudoGamePage({super.key});

  @override
  State<LudoGamePage> createState() => _LudoGamePageState();
}

class _LudoGamePageState extends State<LudoGamePage> {
  int diceNumber = 1;
  bool isRolling = false;
  bool isMicActive = true;
  int currentTurn = 0; // 0: Red, 1: Green, 2: Yellow, 3: Blue

  final List<String> playerNames = ["लाल (आप)", "हरा", "पीला", "नीला"];
  final List<Color> playerColors = [
    const Color(0xFFE53935), // Red
    const Color(0xFF2E7D32), // Green
    const Color(0xFFF9A825), // Yellow
    const Color(0xFF1565C0), // Blue
  ];

  // 4 प्लेयर्स की 4-4 गोटियों की स्थिति (-1 मतलब बेस में)
  List<List<int>> pawns = [
    [-1, -1, -1, -1],
    [-1, -1, -1, -1],
    [-1, -1, -1, -1],
    [-1, -1, -1, -1],
  ];

  void rollDice() {
    if (isRolling) return;
    setState(() => isRolling = true);

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        diceNumber = Random().nextInt(6) + 1;
        isRolling = false;

        // गोटी बाहर निकालने या आगे बढ़ाने का बेसिक नियम
        bool moved = false;
        for (int i = 0; i < 4; i++) {
          if (pawns[currentTurn][i] == -1 && diceNumber == 6) {
            pawns[currentTurn][i] = 0;
            moved = true;
            break;
          } else if (pawns[currentTurn][i] >= 0 && pawns[currentTurn][i] + diceNumber <= 56) {
            pawns[currentTurn][i] += diceNumber;
            moved = true;
            break;
          }
        }

        // 6 नहीं आया तो अगली बारी
        if (diceNumber != 6 || !moved) {
          currentTurn = (currentTurn + 1) % 4;
        }
      });
    });
  }

  void toggleMic() async {
    try {
      await Permission.microphone.request();
    } catch (_) {}
    setState(() => isMicActive = !isMicActive);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isMicActive ? "🎙️ वॉयस चैट ऑन है (पबजी स्टाइल)" : "🔇 माइक म्यूट है"),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double boardSize = screenWidth - 24;
    if (boardSize > 380) boardSize = 380;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 3,
        title: const Row(
          children: [
            Icon(Icons.stars, color: Colors.amber, size: 26),
            SizedBox(width: 8),
            Text('Ludo Champ', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isMicActive ? Icons.mic : Icons.mic_off,
              color: isMicActive ? Colors.greenAccent : Colors.redAccent,
              size: 28,
            ),
            onPressed: toggleMic,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // वॉयस चैट स्टेटस और प्लेयर्स लिस्ट
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (i) {
                  bool active = currentTurn == i;
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: active ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: playerColors[i],
                          child: const Icon(Icons.person, color: Colors.white, size: 19),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        playerNames[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.bold : FontWeight.normal,
                          color: active ? Colors.amberAccent : Colors.white60,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            const Spacer(),

            // असली 15x15 लूडो बोर्ड
            Center(
              child: Container(
                width: boardSize,
                height: boardSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black87, blurRadius: 16, spreadRadius: 2)
                  ],
                  border: Border.all(color: Colors.black, width: 4),
                ),
                child: CustomPaint(
                  size: Size(boardSize, boardSize),
                  painter: ClassicLudoPainter(pawns: pawns, playerColors: playerColors),
                ),
              ),
            ),

            const Spacer(),

            // पासा और टर्न बार
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: playerColors[currentTurn],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${playerNames[currentTurn]} की चाल",
                        style: TextStyle(
                          color: playerColors[currentTurn],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: rollDice,
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: playerColors[currentTurn], width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: playerColors[currentTurn].withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Center(
                        child: isRolling
                            ? CircularProgressIndicator(color: playerColors[currentTurn])
                            : Text(
                                '$diceNumber',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: playerColors[currentTurn],
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// असली लूडो बोर्ड और गोटियां बनाने वाला पेंटर
class ClassicLudoPainter extends CustomPainter {
  final List<List<int>> pawns;
  final List<Color> playerColors;

  ClassicLudoPainter({required this.pawns, required this.playerColors});

  @override
  void paint(Canvas canvas, Size size) {
    double step = size.width / 15.0;

    // 1. ग्रिड बैकग्राउंड और लाइनें
    Paint linePaint = Paint()
      ..color = Colors.black38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 15; i++) {
      canvas.drawLine(Offset(0, i * step), Offset(size.width, i * step), linePaint);
      canvas.drawLine(Offset(i * step, 0), Offset(i * step, size.height), linePaint);
    }

    // 2. चारों होम बेस
    _drawBase(canvas, 0, 0, step * 6, playerColors[0]); // Red
    _drawBase(canvas, step * 9, 0, step * 6, playerColors[1]); // Green
    _drawBase(canvas, step * 9, step * 9, step * 6, playerColors[2]); // Yellow
    _drawBase(canvas, 0, step * 9, step * 6, playerColors[3]); // Blue

    // 3. सेफ होम स्ट्रेच (रास्ते)
    Paint fill = Paint()..style = PaintingStyle.fill;

    // लाल रास्ता
    fill.color = playerColors[0];
    for (int i = 1; i <= 5; i++) {
      canvas.drawRect(Rect.fromLTWH(i * step, 7 * step, step, step), fill);
      canvas.drawRect(Rect.fromLTWH(i * step, 7 * step, step, step), linePaint);
    }
    canvas.drawRect(Rect.fromLTWH(1 * step, 6 * step, step, step), fill); // Start tile

    // हरा रास्ता
    fill.color = playerColors[1];
    for (int i = 1; i <= 5; i++) {
      canvas.drawRect(Rect.fromLTWH(7 * step, i * step, step, step), fill);
      canvas.drawRect(Rect.fromLTWH(7 * step, i * step, step, step), linePaint);
    }
    canvas.drawRect(Rect.fromLTWH(8 * step, 1 * step, step, step), fill);

    // पीला रास्ता
    fill.color = playerColors[2];
    for (int i = 9; i <= 13; i++) {
      canvas.drawRect(Rect.fromLTWH(i * step, 7 * step, step, step), fill);
      canvas.drawRect(Rect.fromLTWH(i * step, 7 * step, step, step), linePaint);
    }
    canvas.drawRect(Rect.fromLTWH(13 * step, 8 * step, step, step), fill);

    // नीला रास्ता
    fill.color = playerColors[3];
    for (int i = 9; i <= 13; i++) {
      canvas.drawRect(Rect.fromLTWH(7 * step, i * step, step, step), fill);
      canvas.drawRect(Rect.fromLTWH(7 * step, i * step, step, step), linePaint);
    }
    canvas.drawRect(Rect.fromLTWH(6 * step, 13 * step, step, step), fill);

    // 4. सेंटर होम त्रिभुज
    Path p = Path();
    p.moveTo(6 * step, 6 * step);
    p.lineTo(7.5 * step, 7.5 * step);
    p.lineTo(6 * step, 9 * step);
    p.close();
    fill.color = playerColors[0];
    canvas.drawPath(p, fill);

    p.reset();
    p.moveTo(6 * step, 6 * step);
    p.lineTo(7.5 * step, 7.5 * step);
    p.lineTo(9 * step, 6 * step);
    p.close();
    fill.color = playerColors[1];
    canvas.drawPath(p, fill);

    p.reset();
    p.moveTo(9 * step, 6 * step);
    p.lineTo(7.5 * step, 7.5 * step);
    p.lineTo(9 * step, 9 * step);
    p.close();
    fill.color = playerColors[2];
    canvas.drawPath(p, fill);

    p.reset();
    p.moveTo(6 * step, 9 * step);
    p.lineTo(7.5 * step, 7.5 * step);
    p.lineTo(9 * step, 9 * step);
    p.close();
    fill.color = playerColors[3];
    canvas.drawPath(p, fill);

    // 5. स्टार (सेफ ज़ोन)
    _drawStar(canvas, 6.5 * step, 2.5 * step, step * 0.35);
    _drawStar(canvas, 12.5 * step, 6.5 * step, step * 0.35);
    _drawStar(canvas, 8.5 * step, 12.5 * step, step * 0.35);
    _drawStar(canvas, 2.5 * step, 8.5 * step, step * 0.35);
  }

  void _drawBase(Canvas canvas, double x, double y, double size, Color color) {
    Paint basePaint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(x, y, size, size), basePaint);

    Paint border = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(Rect.fromLTWH(x, y, size, size), border);

    Paint innerWhite = Paint()..color = Colors.white;
    double m = size * 0.16;
    double s = size * 0.68;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + m, y + m, s, s),
        const Radius.circular(12),
      ),
      innerWhite,
    );

    // बेस के अंदर 4 गोटियों के सर्कल
    Paint slotPaint = Paint()..color = color;
    Paint tokenBorder = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double r = size * 0.12;
    List<Offset> centers = [
      Offset(x + size * 0.32, y + size * 0.32),
      Offset(x + size * 0.68, y + size * 0.32),
      Offset(x + size * 0.32, y + size * 0.68),
      Offset(x + size * 0.68, y + size * 0.68),
    ];

    for (var c in centers) {
      canvas.drawCircle(c, r, slotPaint);
      canvas.drawCircle(c, r, tokenBorder);
      // गोटी का इनर 3D लुक
      canvas.drawCircle(c, r * 0.5, Paint()..color = Colors.white.withOpacity(0.4));
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double radius) {
    Paint starPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    Path path = Path();
    for (int i = 0; i < 5; i++) {
      double angle = i * 4 * pi / 5 - pi / 2;
      double x = cx + radius * cos(angle);
      double y = cy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
