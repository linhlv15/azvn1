  import 'dart:async';
  import 'package:audioplayers/audioplayers.dart';

  import 'package:flutter/material.dart';

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
  bool _isSoundEnabled = true;
    int _remainingTime = 0;
    bool _isWorking = true;
    int _completedCycles = 0;
    int _cyclesUntilLongBreak = 4;
    bool _isPomodoroSelected = true;
    bool _isShortBreakSelected = false;
    bool _isLongBreakSelected = false;
    bool _isTimerRunning = false;
  late AudioPlayer _audioPlayer;


    @override
    void initState() {
      super.initState();
      _initializeNotifications();
      _audioPlayer = AudioPlayer();
    }

    void _initializeNotifications() {
      // Initialize notifications here if needed
    }
    //List<String> _soundFilesMap = [
    //'Tieng-chim-hot-buoi-sang-www_tiengdong_com.mp3',
   //'tieng-chuong-het-gio-het-thoi-gian-trong-powerpoint-www_tiengdong_com.mp3'
  //];
  Map<String, String> _soundFilesMap = {
  'Birds': 'Tieng-chim-hot-buoi-sang-www_tiengdong_com.mp3',
  'Bell': 'tieng-chuong-het-gio-het-thoi-gian-trong-powerpoint-www_tiengdong_com.mp3',
};

  String _selectedSoundFile = 'Birds';
  

    void _startTimer() {
        if (_isPomodoroSelected) {
      _remainingTime = _pomodoroDuration * 60;
      _isWorking = true;
    } else if (_isShortBreakSelected) {
      _remainingTime = _shortBreakDuration * 60;
      _isWorking = false;
    } else if (_isLongBreakSelected) {
      _remainingTime = _longBreakDuration * 60;
      _isWorking = false;
    }
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
    _playNotificationSound();
    if (_cyclesUntilLongBreak == 4) {
      // Nếu vòng lặp được bật
      if (_isWorking) {
        _completedCycles++;
        if (_completedCycles >= _cyclesUntilLongBreak) {
          _isWorking = false;
          _currentBreakDuration = _longBreakDuration * 60;
          _completedCycles = 0;
        } else {
          _isWorking = false;
          _currentBreakDuration = _shortBreakDuration * 60;
        }
      } else {
        _isWorking = true;
        _remainingTime = _pomodoroDuration * 60;
      }
      _startTimer();
    } else {
      // Nếu vòng lặp được tắt
      _isTimerRunning = false;
      _resetTimer();
      
      // Cập nhật trạng thái của các nút
      setState(() {
        if (_isPomodoroSelected) {
          _isPomodoroSelected = true;
          _isShortBreakSelected = false;
          _isLongBreakSelected = false;
        } else if (_isShortBreakSelected) {
          _isPomodoroSelected = false;
          _isShortBreakSelected = true;
          _isLongBreakSelected = false;
        } else if (_isLongBreakSelected) {
          _isPomodoroSelected = false;
          _isShortBreakSelected = false;
          _isLongBreakSelected = true;
        }
      });
      }
    
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

      void _showConfigurationDialog(BuildContext context, bool isSoundEnabled) {
    bool _isLoopingEnabled = _cyclesUntilLongBreak == 4;
    int _newPomodoroDuration = _pomodoroDuration;
    int _newShortBreakDuration = _shortBreakDuration;
    int _newLongBreakDuration = _longBreakDuration;
    bool _newIsSoundEnabled = _isSoundEnabled;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DefaultTabController(
              length: 2,
              child: AlertDialog(
                title: Text('Settings'),
                content: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Timers'),
                          Tab(text: 'Sounds'),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 100,
                        child: TabBarView(
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextFormField(
                                    decoration: InputDecoration(labelText: 'Pomodoro (minutes)'),
                                    keyboardType: TextInputType.number,
                                    initialValue: _newPomodoroDuration.toString(),
                                    onChanged: (value) {
                                      setState(() {
                                        _newPomodoroDuration = int.tryParse(value) ?? _newPomodoroDuration;
                                      });
                                    },
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(labelText: 'Short Break (minutes)'),
                                    keyboardType: TextInputType.number,
                                    initialValue: _newShortBreakDuration.toString(),
                                    onChanged: (value) {
                                      setState(() {
                                        _newShortBreakDuration = int.tryParse(value) ?? _newShortBreakDuration;
                                      });
                                    },
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(labelText: 'Long Break (minutes)'),
                                    keyboardType: TextInputType.number,
                                    initialValue: _newLongBreakDuration.toString(),
                                    onChanged: (value) {
                                      setState(() {
                                        _newLongBreakDuration = int.tryParse(value) ?? _newLongBreakDuration;
                                      });
                                    },
                                  ),
                                  SwitchListTile(
                                    title: Text('Loop'),
                                    value: _isLoopingEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _isLoopingEnabled = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Material(
                                    child: DropdownButton<String>(
                                      value: _selectedSoundFile,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedSoundFile = value!;
                                        });
                                      },
                                      items: _soundFilesMap.keys.map((displayName) {
                                        return DropdownMenuItem<String>(
                                          value: displayName,
                                          child: Text(displayName),
                                        );
                                      }).toList(),
                                    ),
                                    ),
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    title: Text('Enable Sound'),
                                    value: _newIsSoundEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _newIsSoundEnabled = value;
                                      });
                                    },
                                    ),
                                    
                                  // Thêm các tùy chọn âm thanh khác tại đây
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      this.setState(() {
                        _pomodoroDuration = _newPomodoroDuration;
                        _shortBreakDuration = _newShortBreakDuration;
                        _longBreakDuration = _newLongBreakDuration;
                        _cyclesUntilLongBreak = _isLoopingEnabled ? 4 : 1;
                        // Cập nhật trạng thái âm thanh tại đây
                        _isSoundEnabled = _newIsSoundEnabled;
                      });
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

    void _configureDurations() {
      _showConfigurationDialog(context, _isSoundEnabled);
      // Implement dialog to configure durations if needed
    }

  void _playNotificationSound() async {
    if (_isSoundEnabled) {  
    String soundFile = _soundFilesMap[_selectedSoundFile]!;
      await _audioPlayer.play(AssetSource(soundFile));
    }
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
            _remainingTime = _pomodoroDuration * 60;

            } else if (text == 'Short Break') {
              _isWorking = false;
              _isPomodoroSelected = false;
              _isShortBreakSelected = true;
              _isLongBreakSelected = false;
            _remainingTime = _shortBreakDuration * 60;

            } else if (text == 'Long Break') {
              _isWorking = false;
              _isPomodoroSelected = false;
              _isShortBreakSelected = false;
              _isLongBreakSelected = true;
              _remainingTime = _longBreakDuration * 60;
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
