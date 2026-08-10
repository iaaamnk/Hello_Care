import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class VoiceAssistantDialog extends StatefulWidget {
  const VoiceAssistantDialog({super.key});

  @override
  State<VoiceAssistantDialog> createState() => _VoiceAssistantDialogState();
}

class _VoiceAssistantDialogState extends State<VoiceAssistantDialog> {
  final ApiService _apiService = ApiService();
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'assistant',
      'text': 'Hello! I am your HelloCare AI Voice Assistant. How can I help you today? Ask about report summaries or book appointments.'
    }
  ];

  String? _sessionId;
  bool _isLoading = false;

  void _handleSend([String? presetText]) async {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _textController.clear();

    final response = await _apiService.sendVoiceTurn(_sessionId, text);

    if (mounted) {
      setState(() {
        _sessionId = response['sessionId'];
        _messages.add({
          'sender': 'assistant',
          'text': response['spokenResponse'] ?? 'I have processed your voice request.'
        });
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 480,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.mic, color: Colors.blueAccent, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'HelloCare Voice Assistant',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['sender'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue.shade600 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(),
              ),
            ],
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    label: const Text('Summarize blood report'),
                    onPressed: () => _handleSend('Summarize my latest blood report'),
                  ),
                  const SizedBox(width: 6),
                  ActionChip(
                    label: const Text('Check available slots'),
                    onPressed: () => _handleSend('When are doctor slots available?'),
                  ),
                  const SizedBox(width: 6),
                  ActionChip(
                    label: const Text('Book appointment'),
                    onPressed: () => _handleSend('Book appointment with Dr. House'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Speak or type your question...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed: _handleSend,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
