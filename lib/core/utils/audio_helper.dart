import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class AudioHelper {
  static final AudioHelper instance = AudioHelper._();
  AudioPlayer? _effectPlayer;
  AudioPlayer? _bgmPlayer;
  bool _soundEnabled = true;
  bool _bgmEnabled = true;

  AudioHelper._();

  static AudioHelper get instance => instance;

  Future<void> init() async {
    _effectPlayer = AudioPlayer();
    _bgmPlayer = AudioPlayer();
    await _effectPlayer!.setReleaseMode(ReleaseMode.stop);
    await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playCorrect() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer?.stop();
      await _effectPlayer?.play(AssetSource('sounds/correct.mp3'));
    } catch (e) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> playWrong() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer?.stop();
      await _effectPlayer?.play(AssetSource('sounds/wrong.mp3'));
    } catch (e) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> playClick() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer?.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      HapticFeedback.selectionClick();
    }
  }

  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer?.stop();
      await _effectPlayer?.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> playBgm() async {
    if (!_bgmEnabled) return;
    try {
      await _bgmPlayer?.play(AssetSource('sounds/bgm.mp3'));
    } catch (e) {
      // BGM not available
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer?.stop();
  }

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setBgmEnabled(bool enabled) {
    _bgmEnabled = enabled;
    if (!enabled) {
      stopBgm();
    }
  }

  void dispose() async {
    await _effectPlayer?.dispose();
    await _bgmPlayer?.dispose();
  }
}