import 'package:dio/dio.dart';
import 'dart:typed_data';
import '../models/models.dart';
import '../models/analysis_result.dart' show FeedbackMessages;
import 'mdns_service.dart';

class ApiService {
  static const String cloudUrl = 'https://jay162005-salitako2-0.hf.space';

  late final Dio _dio;
  final MdnsService _mdnsService = MdnsService();
  String? _currentSessionId;
  String _baseUrl = cloudUrl;
  bool _isConnected = false;

  ApiService({bool isDebug = true}) {
    // Always start with cloud server (ignore isDebug)
    _baseUrl = cloudUrl;
    
    _dio = Dio(BaseOptions(
      baseUrl: cloudUrl,  // Explicitly use cloudUrl
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    
    // Disable mDNS auto-switch for now - only use cloud
    // _mdnsService.onServerFound = (host, port) {
    //   final newUrl = 'http://$host:$port';
    //   print('🌐 Local server found, switching to: $newUrl');
    //   _baseUrl = newUrl;
    //   _dio.options.baseUrl = newUrl;
    // };
  }
  
  /// Initialize connection to the server
  /// First tries cloud, then optionally discovers local server
  Future<bool> connect() async {
    print('🔌 Connecting to SalitaKo server...');
    
    // Try cloud server first
    _isConnected = await healthCheck();
    
    if (_isConnected) {
      print('✅ Connected to cloud server: $cloudUrl');
    } else {
      print('⚠️ Cloud server unreachable');
    }
    
    // Also start mDNS discovery in background (will auto-switch if local found)
    _mdnsService.startDiscovery();
    
    return _isConnected;
  }
  
  /// Check if connected to any server
  bool get isConnected => _isConnected;
  
  /// Get the current server URL
  String get serverUrl => _baseUrl;

  /// Health check endpoint
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get app configuration
  Future<Map<String, dynamic>> getConfig() async {
    try {
      final response = await _dio.get('/config');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  /// Create a new recording session
  Future<String?> createSession({
    required Language language,
    required PracticeMode mode,
  }) async {
    try {
      final response = await _dio.post('/sessions');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _currentSessionId = response.data['session_id'] as String?;
        return _currentSessionId;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Send audio chunk for real-time transcription (lightweight)
  Future<TranscriptionResult?> transcribeQuick({
    required String sessionId,
    required Uint8List audioData,
    String? previousTranscript,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          audioData,
          filename: 'chunk.webm',
        ),
        if (previousTranscript != null && previousTranscript.isNotEmpty)
          'prompt': previousTranscript,
      });

      final response = await _dio.post(
        '/sessions/$sessionId/transcribe',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        return TranscriptionResult.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      print('❌ Quick transcribe error: $e');
      return null;
    }
  }

  /// Send full audio for complete analysis (use when recording stops)
  Future<AnalysisResponse?> analyzeAudio({
    required String sessionId,
    required Uint8List audioData,
    required double duration,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          audioData,
          filename: 'recording.webm',
        ),
      });

      final response = await _dio.post(
        '/sessions/$sessionId/audio-chunk',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        return AnalysisResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      print('❌ Analyze audio error: $e');
      return null;
    }
  }

  /// Log session results (for research/thesis data collection)
  Future<void> logSessionResults({
    required String studentName,
    required double wpm,
    required double fluencyScore,
    required int fillerCount,
    required int durationSeconds,
  }) async {
    try {
      await _dio.post('/log-session', data: {
        'student_name': studentName,
        'wpm': wpm,
        'fluency_score': fluencyScore,
        'filler_count': fillerCount,
        'duration_seconds': durationSeconds,
      });
      print('📝 Session logged successfully');
    } catch (e) {
      print('⚠️ Failed to log session: $e');
    }
  }

  String? get currentSessionId => _currentSessionId;

  void dispose() {
    _mdnsService.dispose();
    _dio.close();
  }
}

/// Quick transcription result
class TranscriptionResult {
  final String transcript;
  final double? wpm;
  final int? fillerCount;
  final List<String>? fillersDetected;

  TranscriptionResult({
    required this.transcript,
    this.wpm,
    this.fillerCount,
    this.fillersDetected,
  });

  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      transcript: json['transcript'] as String? ?? '',
      wpm: (json['wpm'] as num?)?.toDouble(),
      fillerCount: json['filler_count'] as int?,
      fillersDetected: (json['fillers_detected'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

/// Full analysis response from backend
class AnalysisResponse {
  final String transcript;
  final double? wpm;
  final int? fillerCount;
  final FillerInfo? fillers;
  final PaceInfo? pacing;
  final ProsodyInfo? prosody;
  final double? coherenceScore;
  final Feedback? feedback;
  final String? message;

  AnalysisResponse({
    required this.transcript,
    this.wpm,
    this.fillerCount,
    this.fillers,
    this.pacing,
    this.prosody,
    this.coherenceScore,
    this.feedback,
    this.message,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      transcript: json['transcript'] as String? ?? '',
      wpm: (json['wpm'] as num?)?.toDouble(),
      fillerCount: json['filler_count'] as int?,
      fillers: json['fillers'] != null
          ? FillerInfo.fromJson(json['fillers'] as Map<String, dynamic>)
          : null,
      pacing: json['pacing'] != null
          ? PaceInfo.fromJson(json['pacing'] as Map<String, dynamic>)
          : null,
      prosody: json['prosody'] != null
          ? ProsodyInfo.fromJson(json['prosody'] as Map<String, dynamic>)
          : null,
      coherenceScore: (json['coherence_score'] as num?)?.toDouble(),
      feedback: json['feedback'] != null
          ? Feedback.fromJson(json['feedback'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }

  AnalysisResult toAnalysisResult() {
    return AnalysisResult(
      transcript: transcript,
      overallScore: _calculateOverallScore(),
      fluencyScore: (100 - (fillerCount ?? 0) * 5).clamp(0, 100).toDouble(),
      clarityScore: prosody?.clarity ?? 75.0,
      vocabularyScore: 75.0,
      grammarScore: 75.0,
      coherenceScore: (coherenceScore ?? 5.0) * 10, // Convert 1-10 to 0-100
      paceStatus: pacing?.status ?? 'Normal',
      silenceRatio: prosody?.silenceRatio,
      suggestions: feedback != null
          ? [
              if (feedback!.pacing.isNotEmpty) feedback!.pacing,
              if (feedback!.fillers.isNotEmpty) feedback!.fillers,
              if (feedback!.coherence.isNotEmpty) feedback!.coherence,
            ]
          : [],
      strengths: [],
      wordCount: transcript.split(' ').length,
      wordsPerMinute: wpm ?? 0,
      detectedLanguage: 'tl', // Filipino/Tagalog
      fillerWords: fillers?.toMap() ?? {},
      feedback: feedback != null
          ? FeedbackMessages(
              general: feedback!.general,
              pacing: feedback!.pacing,
              fillers: feedback!.fillers,
              coherence: feedback!.coherence,
            )
          : null,
    );
  }

  double _calculateOverallScore() {
    double score = 75.0;
    if (coherenceScore != null) score = (score + coherenceScore!) / 2;
    if (wpm != null) {
      if (wpm! >= 120 && wpm! <= 150) {
        score += 10;
      } else if (wpm! < 100 || wpm! > 170) {
        score -= 10;
      }
    }
    if (fillerCount != null) {
      score -= fillerCount! * 2;
    }
    return score.clamp(0, 100);
  }
}

class FillerInfo {
  final int count;
  final List<String> fillersDetected;

  FillerInfo({required this.count, required this.fillersDetected});

  factory FillerInfo.fromJson(Map<String, dynamic> json) {
    return FillerInfo(
      count: json['count'] as int? ?? 0,
      fillersDetected: (json['fillers_detected'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, int> toMap() {
    final map = <String, int>{};
    for (final filler in fillersDetected) {
      map[filler] = (map[filler] ?? 0) + 1;
    }
    return map;
  }
}

class PaceInfo {
  final double wpm;
  final String status;

  PaceInfo({required this.wpm, required this.status});

  factory PaceInfo.fromJson(Map<String, dynamic> json) {
    return PaceInfo(
      wpm: (json['wpm'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'Normal',
    );
  }
}

class ProsodyInfo {
  final double? volumeDb;
  final double? silenceRatio;

  ProsodyInfo({this.volumeDb, this.silenceRatio});

  factory ProsodyInfo.fromJson(Map<String, dynamic> json) {
    return ProsodyInfo(
      volumeDb: (json['volume_db'] as num?)?.toDouble(),
      silenceRatio: (json['silence_ratio'] as num?)?.toDouble(),
    );
  }
  
  /// Get clarity estimate based on silence ratio (less silence = clearer)
  double get clarity => silenceRatio != null 
      ? ((1.0 - silenceRatio!) * 100).clamp(0, 100)
      : 75.0;
}

class Feedback {
  final String general;
  final String pacing;
  final String fillers;
  final String coherence;

  Feedback({
    required this.general,
    required this.pacing,
    required this.fillers,
    required this.coherence,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      general: json['general'] as String? ?? '',
      pacing: json['pacing'] as String? ?? '',
      fillers: json['fillers'] as String? ?? '',
      coherence: json['coherence'] as String? ?? '',
    );
  }
}
