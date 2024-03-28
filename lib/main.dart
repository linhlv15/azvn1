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
  int _pomodoroDuration = 3;
  int _shortBreakDuration = 1;
  int _longBreakDuration = 2;

  int _remainingTime = 0;
  bool _isWorking = true;
  int _completedCycles = 0;
  int _cyclesUntilLongBreak = 4;
  bool _isPomodoroSelected = true;
  bool _isShortBreakSelected = false;
  bool _isLongBreakSelected = false;

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
    if (_isWorking) {
      _remainingTime = _pomodoroDuration * 60;
      _shortBreakDuration * 60;
    }
    // Set the initial remaining time to Pomodoro duration

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

        _remainingTime = _longBreakDuration *
            60; // Set remaining time to Long Break duration
      } else {
        _isWorking = false;
        _remainingTime = _shortBreakDuration *
            60; // Set remaining time to Short Break duration
      }
    } else {
      _isWorking = true;
      _remainingTime =
          _pomodoroDuration * 60; // Set remaining time to Pomodoro duration
    }

    _startTimer(); // Start the next interval
  }

  void _resetTimer() {
    setState(() {
      _completedCycles = 0;
      if (_isWorking) {
        _remainingTime = _pomodoroDuration * 60;
      } else {
        if (_completedCycles >= _cyclesUntilLongBreak) {
          _remainingTime = _longBreakDuration * 60;
        } else {
          _remainingTime = _shortBreakDuration * 60;
        }
      }
      // Cập nhật trạng thái của các nút chuyển đổi
      _isPomodoroSelected = _isWorking;
      _isShortBreakSelected =
          !_isWorking && _completedCycles < _cyclesUntilLongBreak;
      _isLongBreakSelected =
          !_isWorking && _completedCycles >= _cyclesUntilLongBreak;
    });

    _handleIntervalCompletion();
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
                  _buildButton('Short Break',
                      isSelected: !_isWorking &&
                          _completedCycles < _cyclesUntilLongBreak),
                  SizedBox(width: 10),
                  _buildButton('Long Break',
                      isSelected: !_isWorking &&
                          _completedCycles >= _cyclesUntilLongBreak),
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
    bool isPomodoro = text == 'Pomodoro';
    bool isShortBreak = text == 'Short Break';
    bool isLongBreak = text == 'Long Break';
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (text == 'Pomodoro') {
            _isWorking = true;
            _isPomodoroSelected = true;
            _isShortBreakSelected = false;
            _isLongBreakSelected = false;
          } else if (text == 'Short Break') {
            _isWorking = false;
            _isPomodoroSelected = false;
            _isShortBreakSelected = true;
            _isLongBreakSelected = false;
          } else if (text == 'Long Break') {
            _isWorking = false;
            _isPomodoroSelected = false;
            _isShortBreakSelected = false;
            _isLongBreakSelected = true;
          }
          _resetTimer();
        });
      },
      child: Text(
        text,
        style: TextStyle(
          color: isPomodoro
              ? _isPomodoroSelected
                  ? Colors.white
                  : Colors.black
              : isShortBreak
                  ? _isShortBreakSelected
                      ? Colors.white
                      : Colors.black
                  : _isLongBreakSelected
                      ? Colors.white
                      : Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPomodoro
            ? _isPomodoroSelected
                ? Colors.red
                : Colors.white
            : isShortBreak
                ? _isShortBreakSelected
                    ? Colors.green
                    : Colors.white
                : _isLongBreakSelected
                    ? Colors.blue
                    : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
