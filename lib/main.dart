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
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const LudoBoardScreen(),
    );
  }
}

class LudoBoardScreen extends StatefulWidget {
  const LudoBoardScreen({super.key});

  @override
  State<LudoBoardScreen> createState() => _LudoBoardScreenState();
}

class _LudoBoardScreenState extends State<LudoBoardScreen> {
  int diceValue = 1;
  bool isRolling = false;
  bool isMicMuted = false;
  int currentTurn = 0; // 0: Red, 1: Green, 2: Yellow, 3: Blue
  final List<String> players = ["Red (आप)", "Green", "Yellow", "Blue"];
  final List<Color> playerColors = [
    Colors.redAccent,
    Colors.greenAccent,
    Colors.amberAccent,
    Colors.lightBlueAccent,
  ];

  void rollDice() {
    if (isRolling) return;
    setState(() => isRolling = true);

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        diceValue = Random().nextInt(6) + 1;
        isRolling = false;
        // अगर 6 नहीं आया तो अगली बारी
        if (diceValue != 6) {
          currentTurn = (currentTurn + 1) % 4;
        }
      });
    });
  }

  void toggleMic() async {
    await Permission.microphone.request();
    setState(() {
      isMicMuted = !isMicMuted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isMicMuted ? "माइक म्यूट है" : "माइक चालू है (Voice Active)"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.sports_esports, color: Colors.amber),
            SizedBox(width: 8),
            Text('Ludo Champ', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isMicMuted ? Icons.mic_off : Icons.mic,
              color: isMicMuted ? Colors.red : Colors.greenAccent,
              size: 28,
            ),
            onPressed: toggleMic,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // वॉइस एक्टिव प्लेयर्स स्टेटस
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: const Color(0xFF1E293B),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (index) {
                  bool isTurn = currentTurn == index;
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: isTurn ? 22 : 18,
                        backgroundColor: playerColors[index],
                        child: Icon(Icons.person, color: Colors.black, size: isTurn ? 24 : 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        players[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isTurn ? FontWeight.bold : FontWeight.normal,
                          color: isTurn ? Colors.white : Colors.white60,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            const Spacer(),

            // लूडो बोर्ड UI
            Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black87, width: 4),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2)
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildBase(Colors.red.shade600, "RED"),
                          _buildCenterPath(true),
                          _buildBase(Colors.green.shade600, "GREEN"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildCenterPath(false),
                          Container(
                            width: 64,
                            color: Colors.amber.shade700,
                            child: const Center(
                              child: Icon(Icons.star, color: Colors.white, size: 32),
                            ),
                          ),
                          _buildCenterPath(false),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildBase(Colors.blue.shade600, "BLUE"),
                          _buildCenterPath(true),
                          _buildBase(Colors.yellow.shade600, "YELLOW"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // डाइस कंट्रोल बार
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("वर्तमान चाल:", style: TextStyle(color: Colors.white70)),
                      Text(
                        players[currentTurn],
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
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: playerColors[currentTurn], width: 3),
                      ),
                      child: Center(
                        child: isRolling
                            ? const CircularProgressIndicator()
                            : Text(
                                '$diceValue',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
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

  Widget _buildBase(Color color, String text) {
    return Container(
      width: 128,
      height: 128,
      color: color,
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterPath(bool isVertical) {
    return Container(
      width: isVertical ? 64 : 128,
      height: isVertical ? 128 : 64,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.apps, color: Colors.black26),
      ),
    );
  }
}
