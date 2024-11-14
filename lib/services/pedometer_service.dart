import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';

class PedometerService {
  StreamSubscription<StepCount>? _stepCountStream;
  final _stepController = StreamController<int>.broadcast();
  int _initialSteps = -1;
  bool _isInitialized = false;

  Stream<int> get stepStream => _stepController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _stepCountStream = Pedometer.stepCountStream.listen(
        (StepCount event) {
          debugPrint('Raw step count from pedometer: ${event.steps}');
          
          if (_initialSteps == -1) {
            _initialSteps = event.steps;
            debugPrint('Initial step count set to: $_initialSteps');
          }
          
          final currentSteps = event.steps - _initialSteps;
          debugPrint('Calculated steps: $currentSteps');
          _stepController.add(currentSteps);
        },
        onError: (error) {
          debugPrint('Pedometer error: $error');
          _stepController.addError(error);
        },
      );
      
      _isInitialized = true;
      debugPrint('Pedometer service initialized');
    } catch (e) {
      debugPrint('Failed to initialize pedometer: $e');
      _stepController.addError(e);
    }
  }

  void dispose() {
    _stepCountStream?.cancel();
    _stepController.close();
    _isInitialized = false;
  }
}