/// Small image widgets wrapping icon assets used across the UI.
import 'package:flutter/material.dart';

class KeyMovesIcon extends StatelessWidget {
  /// Optional size of the icon.
  final Size? size;

  const KeyMovesIcon({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/icons/key_move_icon.png',
      fit: size == null ? BoxFit.contain : BoxFit.fill,
      height: size?.height,
      width: size?.width,
    );
  }
}

class PunishIcon extends StatelessWidget {
  final Size? size;

  const PunishIcon({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/icons/punish_icon.png',
      fit: size == null ? BoxFit.contain : BoxFit.fill,
      height: size?.height,
      width: size?.width,
    );
  }
}

class ComboIcon extends StatelessWidget {
  final Size? size;

  const ComboIcon({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/icons/combo_icon.png',
      fit: size == null ? BoxFit.contain : BoxFit.fill,
      height: size?.height,
      width: size?.width,
    );
  }
}

class StanceIcon extends StatelessWidget {
  final Size? size;

  const StanceIcon({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/icons/stance_icon.png',
      fit: size == null ? BoxFit.contain : BoxFit.fill,
      height: size?.height,
      width: size?.width,
    );
  }
}

class FrameIcon extends StatelessWidget {
  final Size? size;

  const FrameIcon({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/icons/frame_icon.png',
      fit: size == null ? BoxFit.contain : BoxFit.fill,
      height: size?.height,
      width: size?.width,
    );
  }
}

class OnHitIcon extends StatelessWidget {
  final Size? size;

  const OnHitIcon({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/icons/on_hit_icon.png',
      fit: size == null ? BoxFit.contain : BoxFit.fill,
      height: size?.height,
      width: size?.width,
    );
  }
}

class OnBlockIcon extends StatelessWidget {
  final Size? size;

  const OnBlockIcon({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/icons/on_block_icon.png',
      fit: size == null ? BoxFit.contain : BoxFit.fill,
      height: size?.height,
      width: size?.width,
    );
  }
}

class LauncherIcon extends StatelessWidget {
  final Size? size;

  const LauncherIcon({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/icons/launcher_icon.png',
      fit: size == null ? BoxFit.contain : BoxFit.fill,
      height: size?.height,
      width: size?.width,
    );
  }
}
