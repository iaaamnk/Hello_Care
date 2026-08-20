import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'api_service.dart';

enum VoiceState { idle, listening, processing, speaking }

class VoiceAssistantService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final ApiService _apiService = ApiService();

  VoiceState _state = VoiceState.idle;
  bool _isSpeechInitialized = false;
  String _lastRecognizedText = '';
  String _lastSpokenResponse = '';
  String _lastIntent = '';
  String? _errorMessage;

  VoiceState get state => _state;
  bool get isListening => _state == VoiceState.listening;
  bool get isProcessing => _state == VoiceState.processing;
  bool get isSpeaking => _state == VoiceState.speaking;
  String get lastRecognizedText => _lastRecognizedText;
  String get lastSpokenResponse => _lastSpokenResponse;
  String get lastIntent => _lastIntent;
  String? get errorMessage => _errorMessage;

  VoiceAssistantService() {
    _initTts();
  }

  void _initTts() {
    try {
      _flutterTts.setCompletionHandler(() {
        _setState(VoiceState.idle);
      });
      _flutterTts.setErrorHandler((msg) {
        debugPrint('[VoiceAssistantService] TTS Error: $msg');
        _setState(VoiceState.idle);
      });
    } catch (e) {
      debugPrint('[VoiceAssistantService] TTS Init Notice: $e');
    }
  }

  Future<bool> initializeSpeech() async {
    if (_isSpeechInitialized) return true;
    try {
      _isSpeechInitialized = await _speechToText.initialize(
        onError: (val) {
          debugPrint('[SpeechToText] Error: ${val.errorMsg}');
          if (_state == VoiceState.listening) {
            _setState(VoiceState.idle);
          }
        },
        onStatus: (status) {
          debugPrint('[SpeechToText] Status: $status');
          if (status == 'done' || status == 'notListening') {
            if (_state == VoiceState.listening && _lastRecognizedText.trim().isNotEmpty) {
              _processQuery();
            } else if (_state == VoiceState.listening) {
              _setState(VoiceState.idle);
            }
          }
        },
      );
    } catch (e) {
      debugPrint('[VoiceAssistantService] Speech Init Error: $e');
      _isSpeechInitialized = false;
    }
    notifyListeners();
    return _isSpeechInitialized;
  }

  Future<void> startListening({required String userId, required String portal}) async {
    if (_state != VoiceState.idle) {
      await stopAll();
    }

    final available = await initializeSpeech();
    if (!available) {
      _errorMessage = 'Microphone or Speech Recognition unavailable.';
      _setState(VoiceState.idle);
      return;
    }

    _errorMessage = null;
    _lastRecognizedText = '';
    _setState(VoiceState.listening);

    try {
      await _speechToText.listen(
        onResult: (result) {
          _lastRecognizedText = result.recognizedWords;
          notifyListeners();
          if (result.finalResult && _lastRecognizedText.trim().isNotEmpty) {
            _speechToText.stop();
            _processQuery(userId: userId, portal: portal);
          }
        },
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
          localeId: 'en_US',
        ),
      );
    } catch (e) {
      debugPrint('[VoiceAssistantService] Listen Error: $e');
      _setState(VoiceState.idle);
    }
  }

  Future<void> stopListeningAndProcess({required String userId, required String portal}) async {
    if (_state != VoiceState.listening) return;
    await _speechToText.stop();
    if (_lastRecognizedText.trim().isNotEmpty) {
      await _processQuery(userId: userId, portal: portal);
    } else {
      _setState(VoiceState.idle);
    }
  }

  Future<void> sendDirectTextQuery({required String query, required String userId, required String portal}) async {
    _lastRecognizedText = query;
    await _processQuery(userId: userId, portal: portal);
  }

  Future<void> _processQuery({String userId = 'p_sarah_101', String portal = 'patient'}) async {
    if (_lastRecognizedText.trim().isEmpty) {
      _setState(VoiceState.idle);
      return;
    }

    _setState(VoiceState.processing);

    try {
      final res = await _apiService.sendVoiceQuery(
        speechText: _lastRecognizedText.trim(),
        userId: userId,
        portal: portal,
      );

      _lastSpokenResponse = res['spokenResponse'] ?? 'I have processed your query.';
      _lastIntent = res['intent'] ?? 'general';

      _setState(VoiceState.speaking);
      await _flutterTts.stop();
      await _flutterTts.speak(_lastSpokenResponse);
    } catch (e) {
      debugPrint('[VoiceAssistantService] Query Error: $e');
      _lastSpokenResponse = 'Sorry, I encountered an issue processing your request. Please try again.';
      _setState(VoiceState.speaking);
      await _flutterTts.speak(_lastSpokenResponse);
    }
  }

  Future<void> stopAll() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
      await _flutterTts.stop();
    } catch (_) {}
    _setState(VoiceState.idle);
  }

  void _setState(VoiceState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }
}
