import 'package:audioplayers/audioplayers.dart';

abstract class AudioService {
  Future<void> playSound(String soundPath);
  Future<void> stopSound();
  Future<void> dispose();
  Future<void> reset();
}

class AudioServiceImpl extends AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> playSound(String soundPath) async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource(soundPath));
  }

  @override
  Future<void> stopSound() async {
    await _audioPlayer.stop();
  }

  @override
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }

  @override
  Future<void> reset() async {
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero);
  }
}