import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class FullScreenToggleButton extends StatefulWidget {
  const FullScreenToggleButton({super.key});

  @override
  State<FullScreenToggleButton> createState() => _FullScreenToggleButtonState();
}

class _FullScreenToggleButtonState extends State<FullScreenToggleButton> {
  bool _isFullScreen = false;
  Future<void> _toggleFullScreen() async {
    try {
      _isFullScreen = await windowManager.isFullScreen();
      if (_isFullScreen) {
        await windowManager.setFullScreen(false);
      } else {
        await windowManager.unmaximize();
        await windowManager.setFullScreen(true);
      }
      setState(() {
        _isFullScreen = !_isFullScreen;
      });
    } catch (e) {
      debugPrint('Error toggling full screen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
      onPressed: _toggleFullScreen,
      tooltip: _isFullScreen ? 'Exit Full Screen' : 'Enter Full Screen',
    );
  }
}
