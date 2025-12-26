class Habit {
  final String id;
  final String name;
  final int dailyTarget;
  int currentStreak;
  bool completedToday;

  Habit({
    required this.id,
    required this.name,
    required this.dailyTarget,
    this.currentStreak = 0,
    this.completedToday = false,
  });

  void markCompleted() {
    completedToday = true;
    currentStreak++;
  }

  void resetDay() {
    completedToday = false;
  }
}
