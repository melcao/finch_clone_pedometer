import 'package:flutter/foundation.dart';

class FinchModel extends ChangeNotifier {
  String _name = 'Salt';
  int _coins = 100;
  int _happiness = 80;
  int _health = 90;
  int _energy = 0;
  int _cleaningSkills = 0;
  final List<String> _inventory = [];
  final List<String> _completedGoals = [];
  final List<Goal> _dailyGoals = [
    Goal('Write a reflection', 5, 'write'),
    Goal('Cook breakfast', 5, 'cook'),
    Goal('Take a walk', 5, 'walk'),
    Goal('Read a book', 5, 'book'),
  ];

  // Getters
  String get name => _name;
  int get coins => _coins;
  int get happiness => _happiness;
  int get health => _health;
  int get energy => _energy;
  int get cleaningSkills => _cleaningSkills;
  List<String> get inventory => List.unmodifiable(_inventory);
  List<String> get completedGoals => List.unmodifiable(_completedGoals);
  List<Goal> get dailyGoals => List.unmodifiable(_dailyGoals);

  void completeGoal(Goal goal) {
    if (!_completedGoals.contains(goal.title)) {
      _completedGoals.add(goal.title);
      _coins += goal.reward;
      _happiness += 5;
      notifyListeners();
    }
  }

  void increaseEnergy(int amount) {
    _energy += amount;
    notifyListeners();
  }

  void increaseCleaningSkills(int amount) {
    _cleaningSkills += amount;
    notifyListeners();
  }
}

class Goal {
  final String title;
  final int reward;
  final String icon;

  const Goal(this.title, this.reward, this.icon);
}