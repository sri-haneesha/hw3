import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class CardModel {
  String front;
  String back;
  bool isFaceUp;
  bool isMatched;

  CardModel(
      {required this.front,
      required this.back,
      this.isFaceUp = false,
      this.isMatched = false});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Card Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MemoryCardGame(),
    );
  }
}

class MemoryCardGame extends StatefulWidget {
  const MemoryCardGame({super.key});

  @override
  _MemoryCardGameState createState() => _MemoryCardGameState();
}

class _MemoryCardGameState extends State<MemoryCardGame> {
  late List<CardModel> cards;
  late List<int> selectedCards;
  late bool isBusy;
  late int score;
  late int timeElapsed;
  late Timer timer;
  int consecutiveMatches = 0;

  final int gridSize = 4; // Change grid size here

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    List<String> icons = [
      '🐶',
      '🐱',
      '🐰',
      '🦊',
      '🐻',
      '🐼',
      '🐨',
      '🐯',
      '🐷',
      '🐸',
      '🦁',
      '🐵'
    ];
    int totalPairs = (gridSize * gridSize) ~/ 2;
    if (icons.length < totalPairs) {
      throw Exception('Not enough icons to populate the grid.');
    }
    cards = [];
    for (int i = 0; i < totalPairs; i++) {
      cards.add(CardModel(front: icons[i], back: '❓'));
      cards.add(CardModel(front: icons[i], back: '❓'));
    }
    cards.shuffle();
    selectedCards = [];
    isBusy = false;
    score = 0;
    timeElapsed = 0;
    consecutiveMatches = 0;

    // Start timer
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeElapsed++;
      });
    });
  }

  Future<void> flipCard(int index) async {
    if (isBusy || cards[index].isFaceUp || cards[index].isMatched) return;

    setState(() {
      cards[index].isFaceUp = true;
    });

    selectedCards.add(index);

    if (selectedCards.length == 2) {
      isBusy = true;
      await Future.delayed(const Duration(seconds: 1));
      if (cards[selectedCards[0]].front != cards[selectedCards[1]].front) {
        setState(() {
          cards[selectedCards[0]].isFaceUp = false;
          cards[selectedCards[1]].isFaceUp = false;
          score -= 5; // Deduct points for mismatch
          consecutiveMatches = 0; // Reset consecutive matches
        });
      } else {
        consecutiveMatches++;
        int bonus = (consecutiveMatches > 1) ? 5 * (consecutiveMatches - 1) : 0;
        setState(() {
          cards[selectedCards[0]].isMatched = true;
          cards[selectedCards[1]].isMatched = true;
          score += 10 +
              bonus; // Add points for match and bonus for consecutive matches
        });
      }
      selectedCards.clear();
      isBusy = false;
    }

    if (cards.every((card) => card.isMatched)) {
      timer.cancel(); // Stop the timer
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Congratulations!'),
            content: Text(
                'You won the game in $timeElapsed seconds with a score of $score!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  resetGame();
                },
                child: const Text('Play Again'),
              ),
            ],
          );
        },
      );
    }
  }

  void resetGame() {
    setState(() {
      initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Card Game'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Time: $timeElapsed s',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => flipCard(index),
                  child: Card(
                    color: Colors.lightGreenAccent,
                    child: Center(
                      child: Text(
                        cards[index].isFaceUp
                            ? cards[index].front
                            : cards[index].back,
                        style: const TextStyle(fontSize: 40.0),
                      ),
                    ),
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
