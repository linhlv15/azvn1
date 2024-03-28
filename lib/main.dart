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
  int _pomodoroDuration = 25; // Thay đổi giá trị mặc định cho pomodoro
  int _shortBreakDuration = 5; // Thay đổi giá trị mặc định cho short break
  int _longBreakDuration = 15; // Thay đổi giá trị mặc định cho long break
  int _pausedTime = 0;
  int _currentBreakDuration = 0;

  int _remainingTime = 0;
  bool _isWorking = true;
  int _completedCycles = 0;
  int _cyclesUntilLongBreak = 4;
  bool _isPomodoroSelected = true;
  bool _isShortBreakSelected = false;
  bool _isLongBreakSelected = false;
  bool _isTimerRunning = false;

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
    _remainingTime =
        _isWorking ? _pomodoroDuration * 60 : _currentBreakDuration;

    _isTimerRunning = true;

    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime <= 0 || !_isTimerRunning) {
          timer.cancel();
          if (_isTimerRunning) {
            _handleIntervalCompletion();
          } // Handle interval completion when Pomodoro time is up
        } else {
          _remainingTime--;
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isTimerRunning = false;
      _pausedTime = _remainingTime; // Cập nhật giá trị _pausedTime
    });
  }

  void _resumeTimer() {
    setState(() {
      _isTimerRunning = true;
      _startCountdown();
    });
  }

  void _startCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime <= 0 || !_isTimerRunning) {
          timer.cancel();
          if (_isTimerRunning) {
            _handleIntervalCompletion();
          }
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
        _currentBreakDuration = _longBreakDuration * 60;
      } else {
        _isWorking = false;
        _currentBreakDuration = _shortBreakDuration * 60;
      }
    } else {
      _isWorking = true;
      _remainingTime = _pomodoroDuration * 60;
    }

    _startTimer();

    // Cập nhật trạng thái của các nút
    setState(() {
      _isPomodoroSelected = _isWorking;
      _isShortBreakSelected =
          !_isWorking && _completedCycles < _cyclesUntilLongBreak;
      _isLongBreakSelected =
          !_isWorking && _completedCycles >= _cyclesUntilLongBreak;
    });
  }

  // Các phương thức và thuộc tính khác không thay đổi

  void _resetTimer() {
    setState(() {
      // Kiểm tra nếu thời gian đang chạy ở pomodoro
      if (_isWorking) {
        _remainingTime =
            _pomodoroDuration * 60; // Reset lại thời gian của pomodoro
      }
      // Kiểm tra nếu thời gian đang chạy ở short break
      else if (_isShortBreakSelected) {
        _remainingTime =
            _shortBreakDuration * 60; // Reset lại thời gian của short break
      }
      // Kiểm tra nếu thời gian đang chạy ở long break
      else if (_isLongBreakSelected) {
        _remainingTime =
            _longBreakDuration * 60; // Reset lại thời gian của long break
      }

      // Kiểm tra xem nếu thời gian đang chạy
      if (_isTimerRunning) {
        _isTimerRunning = false; // Dừng thời gian
      }
    });
  }

  void _showConfigurationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Configure Durations'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Pomodoro Duration (minutes)'),
                keyboardType: TextInputType.number,
                initialValue: _pomodoroDuration.toString(),
                onChanged: (value) {
                  setState(() {
                    _pomodoroDuration =
                        int.tryParse(value) ?? _pomodoroDuration;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Short Break Duration (minutes)'),
                keyboardType: TextInputType.number,
                initialValue: _shortBreakDuration.toString(),
                onChanged: (value) {
                  setState(() {
                    _shortBreakDuration =
                        int.tryParse(value) ?? _shortBreakDuration;
                  });
                },
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Long Break Duration (minutes)'),
                keyboardType: TextInputType.number,
                initialValue: _longBreakDuration.toString(),
                onChanged: (value) {
                  setState(() {
                    _longBreakDuration =
                        int.tryParse(value) ?? _longBreakDuration;
                  });
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _configureDurations() {
    _showConfigurationDialog(context);
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
                  _buildButton('Pomodoro', isSelected: _isPomodoroSelected),
                  SizedBox(width: 10),
                  _buildButton('Short Break',
                      isSelected: _isShortBreakSelected),
                  SizedBox(width: 10),
                  _buildButton('Long Break', isSelected: _isLongBreakSelected),
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
                onPressed: _isTimerRunning
                    ? _pauseTimer
                    : (_pausedTime > 0 ? _resumeTimer : _startTimer),
                child: Text(_isTimerRunning
                    ? 'Pause'
                    : (_pausedTime > 0 ? 'Start' : 'Start')),
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

  Widget _buildButton(String text, {required bool isSelected}) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (_isTimerRunning) {
            _pauseTimer();
          }
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
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
