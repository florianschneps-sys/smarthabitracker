import 'package:flutter/material.dart';
import '../models/habit.dart';
import 'exercise_screen.dart';
import 'stats_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  Habit habit = Habit(
    id: '1',
    name: '10 Liegestütze',
    dailyTarget: 10,
  );

  void completeHabit() {
    setState(() {
      habit.markCompleted();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Habit Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text('Streak: ${habit.currentStreak} Tage'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: habit.completedToday ? null : completeHabit,
              child: const Text('Als erledigt markieren'),
            ),
            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseScreen(),
      ),
    );
  },
  child: const Text('Übung starten'),
),

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatsScreen(
          currentStreak: habit.currentStreak,
          totalRepetitions: habit.currentStreak * habit.dailyTarget,
        ),
      ),
    );
  },
  child: const Text('Statistik anzeigen'),
),

          ],
        ),
      ),
    );
  }

  
}
