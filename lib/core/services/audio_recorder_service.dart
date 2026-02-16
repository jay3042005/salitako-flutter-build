import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderService {
  static const int sampleRate = 16000;
  static const int bitDepth = 16;
  static const int channels = 1;

  final AudioRecorder _recorder = AudioRecorder();

  StreamSubscription<Amplitude>? _amplitudeSubscription;

  bool _isRecording = false;
  String? _currentFilePath;
  DateTime? _recordingStartTime;

  bool get isRecording => _isRecording;
  String? get currentFilePath => _currentFilePath;

  Duration get recordingDuration {
    if (_recordingStartTime == null) return Duration.zero;
    return DateTime.now().difference(_recordingStartTime!);
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    return await Permission.microphone.isGranted;
  }

  /// Start recording audio
  Future<bool> startRecording() async {
    if (_isRecording) return false;

    final hasPermissionGranted = await hasPermission();
    if (!hasPermissionGranted) {
      final granted = await requestPermission();
      if (!granted) return false;
    }

    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentFilePath = '${directory.path}/recording_$timestamp.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: sampleRate,
          bitRate: sampleRate * bitDepth * channels,
          numChannels: channels,
        ),
        path: _currentFilePath!,
      );

      _isRecording = true;
      _recordingStartTime = DateTime.now();

      return true;
    } catch (e) {
      _isRecording = false;
      _currentFilePath = null;
      _recordingStartTime = null;
      return false;
    }
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await _recorder.stop();
      _isRecording = false;
      _recordingStartTime = null;
      return path;
    } catch (e) {
      _isRecording = false;
      _recordingStartTime = null;
      return null;
    }
  }

  /// Get amplitude stream for visualizer
  Stream<double> getAmplitudeStream() {
    return Stream.periodic(
      const Duration(milliseconds: 100),
      (_) async {
        if (!_isRecording) return 0.0;
        try {
          final amplitude = await _recorder.getAmplitude();
          // Convert dB to normalized value (0.0 to 1.0)
          // Typical range is -60 dB (silent) to 0 dB (max)
          final normalized = ((amplitude.current + 60) / 60).clamp(0.0, 1.0);
          return normalized;
        } catch (e) {
          return 0.0;
        }
      },
    ).asyncMap((future) => future);
  }

  /// Read recording as bytes
  Future<Uint8List?> getRecordingBytes() async {
    if (_currentFilePath == null) return null;

    try {
      final file = File(_currentFilePath!);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete the current recording file
  Future<void> deleteRecording() async {
    if (_currentFilePath == null) return;

    try {
      final file = File(_currentFilePath!);
      if (await file.exists()) {
        await file.delete();
      }
      _currentFilePath = null;
    } catch (e) {
      // Ignore deletion errors
    }
  }

  /// Cancel ongoing recording
  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _recorder.stop();
      _isRecording = false;
      _recordingStartTime = null;
    }
    await deleteRecording();
  }

  /// Check if recording is supported
  Future<bool> isRecordingSupported() async {
    return await _recorder.isEncoderSupported(AudioEncoder.wav);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _amplitudeSubscription?.cancel();
    if (_isRecording) {
      await _recorder.stop();
    }
    _recorder.dispose();
  }
}
