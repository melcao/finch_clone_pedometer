import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../models/finch_model.dart';
import '../services/pedometer_service.dart';
import 'package:device_info_plus/device_info_plus.dart';

class WalkingScreen extends StatefulWidget {
  const WalkingScreen({super.key});

  @override
  State<WalkingScreen> createState() => _WalkingScreenState();
}

class _WalkingScreenState extends State<WalkingScreen> with TickerProviderStateMixin {
  final _pedometerService = PedometerService();
  StreamSubscription<int>? _stepSubscription;
  int _steps = 0;
  bool _isWalking = false;
  Timer? _walkingTimer;
  late final AnimationController _idleController;
  late final AnimationController _walkingController;
  bool _isSimulator = false;
  final FocusNode _focusNode = FocusNode();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _walkingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _checkSimulator().then((_) {
      if (_isSimulator) {
        _setupSimulatorControls();
      } else {
        _initPedometer();
      }
    });
  }

  Future<void> _checkSimulator() async {
    if (Platform.isIOS) {
      final deviceInfo = await DeviceInfoPlugin().iosInfo;
      setState(() {
        _isSimulator = deviceInfo.model.toLowerCase().contains('simulator');
      });
    } else if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      setState(() {
        _isSimulator = !deviceInfo.isPhysicalDevice;
      });
    }
  }

  void _setupSimulatorControls() {
    _focusNode.requestFocus();
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        _simulateStep();
      }
    }
  }

  void _simulateStep() {
    setState(() {
      _steps++;
      _isWalking = true;
      _errorMessage = null;
    });
    
    _updateWalkingState();
  }

  Future<void> _initPedometer() async {
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.request();
      if (!status.isGranted) {
        _showPermissionDeniedDialog();
        return;
      }
    }

    try {
      await _pedometerService.initialize();
      
      _stepSubscription = _pedometerService.stepStream.listen(
        (steps) {
          if (mounted) {
            setState(() {
              _steps = steps;
              _isWalking = true;
              _errorMessage = null;
            });
            _updateWalkingState();
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Unable to track steps: $error';
            });
          }
        },
      );
      
      debugPrint('Pedometer initialized and listening');
    } catch (e) {
      debugPrint('Error initializing pedometer: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize step tracking: $e';
        });
      }
    }
  }

  void _updateWalkingState() {
    _walkingTimer?.cancel();
    _walkingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isWalking = false;
        });
      }
    });

    if (_isWalking) {
      _idleController.stop();
      _walkingController.repeat();
    } else {
      _walkingController.stop();
      _idleController.repeat();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text('This feature requires motion & fitness tracking permission to count steps.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _isSimulator ? _handleKeyPress : null,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF90EE90),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                
                Column(
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      'Salt will walk with you for\nas long as you\'d like',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isSimulator)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Simulator Mode: Press SPACE to simulate steps',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: Stack(
                        children: [
                          if (!_isWalking)
                            Lottie.asset(
                              'assets/animations/birb_winking.json',
                              controller: _idleController,
                            ),
                          if (_isWalking)
                            Lottie.asset(
                              'assets/animations/birb_sweeping_loop.json',
                              controller: _walkingController,
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_walk),
                          const SizedBox(width: 8),
                          Text(
                            '$_steps steps',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isSimulator)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: _simulateStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Simulate Step'),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () {
                          final finchModel = Provider.of<FinchModel>(context, listen: false);
                          finchModel.increaseEnergy(_steps ~/ 10);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _pedometerService.dispose();
    _walkingTimer?.cancel();
    _idleController.dispose();
    _walkingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}