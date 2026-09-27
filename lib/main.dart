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
        scaffoldBackgroundColor: const Color(0xFF0D131F),
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
    const Color(0xFF43A047), // Green
    const Color(0xFFFDD835), // Yellow
    const Color(0xFF1E88E5), // Blue
  ];

  // 4 खिलाड़ियों की 4-4 गोटियां (-1 मतलब बेस में बंद हैं)
  List<List<int>> pawns = [
    [-1, -1, -1, -1], // Red
    [-1, -1, -1, -1], // Green
    [-1, -1, -1, -1], // Yellow
    [-1, -1, -1, -1], // Blue
  ];

  void rollDice() {
    if (isRolling) return;
    setState(() => isRolling = true);

    Future.delayed(const Duration(milliseconds: 350), () {
      setState(() {
        diceNumber = Random().nextInt(6) + 1;
        isRolling = false;

        // बेस में बंद गोटियों में से अगर कोई बाहर निकल सकती है (पासे में 6 आने पर)
        bool hasMove = false;
        for (int i = 0; i < 4; i++) {
          if (pawns[currentTurn][i] == -1 && diceNumber == 6) {
            pawns[currentTurn][i] = 0; // पहली गोटी बाहर निकली
            hasMove = true;
            break;
          } else if (pawns[currentTurn][i] >= 0 && pawns[currentTurn][i] + diceNumber <= 56) {
            pawns[currentTurn][i] += diceNumber; // चाल आगे बढ़ी
            hasMove = true;
            break;
          }
        }

        // अगर 6 नहीं आया तो अगले खिलाड़ी की बारी
        if (diceNumber != 6 || !hasMove) {
          currentTurn = (currentTurn + 1) % 4;
        }
      });
    });
  }

  void toggleMic() async {
    await Permission.microphone.request();
    setState(() => isMicActive = !isMicActive);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isMicActive ? "🎙️ माइक चालू है (Live Voice)" : "🔇 माइक बंद है"),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double boardSize = MediaQuery.of(context).size.width - 20;
    if (boardSize > 400) boardSize = 400;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF161F30),
        elevation: 4,
        title: const Row(
          children: [
            Icon(Icons.military_tech, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('LUDO CHAMP', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isMicActive ? Icons.mic : Icons.mic_off,
              color: isMicActive ? Colors.greenAccent : Colors.redAccent,
              size: 26,
            ),
            onPressed: toggleMic,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // वॉयस चैट स्टेटस और प्लेयर्स
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF161F30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (i) {
                  bool active = currentTurn == i;
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: active ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: playerColors[i],
                          child: const Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        playerNames[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.bold : FontWeight.normal,
                          color: active ? Colors.amberAccent : Colors.white70,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            const Spacer(),

            // असली 15x15 ग्रिड वाला लूडो बोर्ड
            Center(
              child: Container(
                width: boardSize,
                height: boardSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black87, blurRadius: 16, spreadRadius: 4)
                  ],
                  border: Border.all(color: const Color(0xFF1E293B), width: 6),
                ),
                child: CustomPaint(
                  painter: LudoBoardPainter(pawns: pawns, playerColors: playerColors),
                ),
              ),
            ),

            const Spacer(),

            // पासा (Dice) और टर्न बार
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF161F30),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
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
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
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

// असली लूडो बोर्ड बनाने वाला कस्टम पेंटर
class LudoBoardPainter extends CustomPainter {
  final List<List<int>> pawns;
  final List<Color> playerColors;

  LudoBoardPainter({required this.pawns, required this.playerColors});

  @override
  void paint(Canvas canvas, Size size) {
    double step = size.width / 15.0;

    // 1. चारों कोने के होम बेस
    _drawBase(canvas, 0, 0, step * 6, playerColors[0]); // Red
    _drawBase(canvas, step * 9, 0, step * 6, playerColors[1]); // Green
    _drawBase(canvas, step * 9, step * 9, step * 6, playerColors[2]); // Yellow
    _drawBase(canvas, 0, step * 9, step * 6, playerColors[3]); // Blue

    // 2. ग्रिड लाइनें
    Paint linePaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 15; i++) {
      canvas.drawLine(Offset(0, i * step), Offset(size.width, i * step), linePaint);
      canvas.drawLine(Offset(i * step, 0), Offset(i * step, size.height), linePaint);
    }

    // 3. सेफ रास्ते (Home Stretches)
    Paint fill = Paint()..style = PaintingStyle.fill;
    
    // Red Path
    fill.color = playerColors[0];
    for (int i = 1; i <= 5; i++) canvas.drawRect(Rect.fromLTWH(i * step, 7 * step, step, step), fill);
    canvas.drawRect(Rect.fromLTWH(1 * step, 6 * step, step, step), fill);

    // Green Path
    fill.color = playerColors[1];
    for (int i = 1; i <= 5; i++) canvas.drawRect(Rect.fromLTWH(7 * step, i * step, step, step), fill);
    canvas.drawRect(Rect.fromLTWH(8 * step, 1 * step, step, step), fill);

    // Yellow Path
    fill.color = playerColors[2];
    for (int i = 9; i <= 13; i++) canvas.drawRect(Rect.fromLTWH(i * step, 7 * step, step, step), fill);
    canvas.drawRect(Rect.fromLTWH(13 * step, 8 * step, step, step), fill);

    // Blue Path
    fill.color = playerColors[3];
    for (int i = 9; i <= 13; i++) canvas.drawRect(Rect.fromLTWH(7 * step, i * step, step, step), fill);
    canvas.drawRect(Rect.fromLTWH(6 * step, 13 * step, step, step), fill);

    // 4. सेंटर होम त्रिभुज (Winning Center)
    Path centerPath = Path();
    centerPath.moveTo(6 * step, 6 * step);
    centerPath.lineTo(7.5 * step, 7.5 * step);
    centerPath.lineTo(6 * step, 9 * step);
    centerPath.close();
    fill.color = playerColors[0];
    canvas.drawPath(centerPath, fill);

    centerPath.reset();
    centerPath.moveTo(6 * step, 6 * step);
    centerPath.lineTo(7.5 * step, 7.5 * step);
    centerPath.lineTo(9 * step, 6 * step);
    centerPath.close();
    fill.color = playerColors[1];
    canvas.drawPath(centerPath, fill);

    centerPath.reset();
    centerPath.moveTo(9 * step, 6 * step);
    centerPath.lineTo(7.5 * step, 7.5 * step);
    centerPath.lineTo(9 * step, 9 * step);
    centerPath.close();
    fill.color = playerColors[2];
    canvas.drawPath(centerPath, fill);

    centerPath.reset();
    centerPath.moveTo(6 * step, 9 * step);
    centerPath.lineTo(7.5 * step, 7.5 * step);
    centerPath.lineTo(9 * step, 9 * step);
    centerPath.close();
    fill.color = playerColors[3];
    canvas.drawPath(centerPath, fill);

    // 5. सेफ स्टार्स (Safe Zones)
    _drawStar(canvas, 6.5 * step, 2.5 * step, step * 0.35);
    _drawStar(canvas, 12.5 * step, 6.5 * step, step * 0.35);
    _drawStar(canvas, 8.5 * step, 12.5 * step, step * 0.35);
    _drawStar(canvas, 2.5 * step, 8.5 * step, step * 0.35);
  }

  void _drawBase(Canvas canvas, double x, double y, double size, Color color) {
    Paint basePaint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(x, y, size, size), basePaint);

    Paint innerWhite = Paint()..color = Colors.white;
    double innerMargin = size * 0.16;
    double innerSize = size * 0.68;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + innerMargin, y + innerMargin, innerSize, innerSize),
        const Radius.circular(10),
      ),
      innerWhite,
    );

    // 4 गोटियों के सर्कल बेस
    Paint slotPaint = Paint()..color = color.withOpacity(0.8);
    double r = size * 0.12;
    canvas.drawCircle(Offset(x + size * 0.32, y + size * 0.32), r, slotPaint);
    canvas.drawCircle(Offset(x + size * 0.68, y + size * 0.32), r, slotPaint);
    canvas.drawCircle(Offset(x + size * 0.32, y + size * 0.68), r, slotPaint);
    canvas.drawCircle(Offset(x + size * 0.68, y + size * 0.68), r, slotPaint);
  }

  void _drawStar(Canvas canvas, double cx, double cy, double radius) {
    Paint starPaint = Paint()
      ..color = Colors.black45
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
