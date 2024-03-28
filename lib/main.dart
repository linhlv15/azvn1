import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PomodoroScreen(),
    );
  }
}

class PomodoroScreen extends StatefulWidget {
  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int _pomodoroDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 10;

  int _remainingTime = 0;
  bool _isWorking = true;
  int _completedCycles = 0;
  int _cyclesUntilLongBreak = 4;

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    // Initialize notifications here if needed
  }

  void _startTimer() {
  _remainingTime = _pomodoroDuration * 60; // Set the initial remaining time to Pomodoro duration

  Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      if (_remainingTime <= 0) {
        timer.cancel();
        _handleIntervalCompletion(); // Handle interval completion when Pomodoro time is up
      } else {
        _remainingTime--;
      }
    });
  });
}

void _handleIntervalCompletion() {
  _showNotification(
    _isWorking ? 'Pomodoro Finished' : 'Break Finished',
    _isWorking ? 'Time for a short break!' : 'Time to get back to work!',
  );

  if (_isWorking) {
    _completedCycles++;
    if (_completedCycles >= _cyclesUntilLongBreak) {
      _isWorking = false;
      _completedCycles = 0;
      _remainingTime = _longBreakDuration * 60; // Set remaining time to Long Break duration
    } else {
      _isWorking = false;
      _remainingTime = _shortBreakDuration * 60; // Set remaining time to Short Break duration
    }
  } else {
    _isWorking = true;
    _remainingTime = _pomodoroDuration * 60; // Set remaining time to Pomodoro duration
  }

  _startTimer(); // Start the next interval
}

  void _resetTimer() {
  setState(() {
    _isWorking = true; // Đảm bảo rằng khi reset, chương trình bắt đầu với Pomodoro
    _completedCycles = 0;
    _remainingTime = _isWorking ? _pomodoroDuration * 60 : _shortBreakDuration * 60; // Sử dụng _shortBreakDuration nếu đang trong thời gian Short Break
  });
}

  void _configureDurations() {
    // Implement dialog to configure durations if needed
  }

  void _showNotification(String title, String body) {
    // Implement notification logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pomodoro Timer'),
      ),
      body: Container(
        color: Colors.blue.shade200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton('Pomodoro', isSelected: _isWorking),
                  SizedBox(width: 10),
                  _buildButton('Short Break', isSelected: !_isWorking),
                  SizedBox(width: 10),
                  _buildButton('Long Break'),
                ],
              ),
              SizedBox(height: 20),
              Text(
                '${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 80,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startTimer,
                child: Text('Start'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _resetTimer,
                    icon: Icon(Icons.refresh),
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: _configureDurations,
                    icon: Icon(Icons.settings),
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, {bool isSelected = false}) {
  return ElevatedButton(
    onPressed: () {
      setState(() {
        if (text == 'Pomodoro') {
          _isWorking = true;
        } else if (text == 'Short Break') {
          _isWorking = false;
        }
        _resetTimer(); // Thiết lập lại timer khi chuyển sang Pomodoro hoặc Short Break mới
      });
    },
    child: Text(
      text,
      style: TextStyle(color: isSelected ? Colors.white : Colors.black),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: isSelected ? Colors.red : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}


}