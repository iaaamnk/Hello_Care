import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voice_assistant_service.dart';

class VoiceAssistantFAB extends StatelessWidget {
  final String userId;
  final String portal; // 'patient' or 'doctor'

  const VoiceAssistantFAB({
    super.key,
    required this.userId,
    required this.portal,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceAssistantService>(
      builder: (context, voiceService, _) {
        final isListening = voiceService.isListening;
        final isProcessing = voiceService.isProcessing;
        final isSpeaking = voiceService.isSpeaking;

        Color fabColor = Theme.of(context).primaryColor;
        IconData icon = Icons.mic_rounded;

        if (isListening) {
          fabColor = Colors.redAccent;
          icon = Icons.mic_rounded;
        } else if (isProcessing) {
          fabColor = Colors.orangeAccent;
          icon = Icons.hourglass_top_rounded;
        } else if (isSpeaking) {
          fabColor = Colors.green;
          icon = Icons.volume_up_rounded;
        }

        return FloatingActionButton.extended(
          heroTag: 'voice_fab_$portal',
          backgroundColor: fabColor,
          icon: Icon(icon, color: Colors.white),
          label: Text(
            isListening
                ? 'Listening...'
                : isProcessing
                    ? 'Processing...'
                    : isSpeaking
                        ? 'Speaking...'
                        : 'Voice Assistant',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (ctx) => VoiceAssistantModal(userId: userId, portal: portal),
            );
          },
        );
      },
    );
  }
}

class VoiceAssistantModal extends StatefulWidget {
  final String userId;
  final String portal;

  const VoiceAssistantModal({
    super.key,
    required this.userId,
    required this.portal,
  });

  @override
  State<VoiceAssistantModal> createState() => _VoiceAssistantModalState();
}

class _VoiceAssistantModalState extends State<VoiceAssistantModal> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Consumer<VoiceAssistantService>(
      builder: (context, voiceService, _) {
        final state = voiceService.state;

        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: mediaQuery.viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.portal == "doctor" ? "Doctor" : "Patient"} Voice Assistant',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      voiceService.stopAll();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // State visualizer
              _buildStateVisualizer(context, state),
              const SizedBox(height: 20),

              // Speech recognition output
              if (voiceService.lastRecognizedText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You said:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        voiceService.lastRecognizedText,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

              if (voiceService.lastRecognizedText.isNotEmpty) const SizedBox(height: 12),

              // Assistant Response
              if (voiceService.lastSpokenResponse.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.smart_toy_outlined, size: 16, color: Colors.indigo),
                          const SizedBox(width: 6),
                          Text(
                            'Assistant (${voiceService.lastIntent}):',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        voiceService.lastSpokenResponse,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Mic Button / Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state == VoiceState.listening)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        voiceService.stopListeningAndProcess(
                          userId: widget.userId,
                          portal: widget.portal,
                        );
                      },
                      icon: const Icon(Icons.stop_rounded),
                      label: const Text('Stop & Ask'),
                    )
                  else if (state == VoiceState.processing)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Analyzing query...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  else if (state == VoiceState.speaking)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        voiceService.stopAll();
                      },
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('Stop Speaking'),
                    )
                  else
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      ),
                      onPressed: () {
                        voiceService.startListening(
                          userId: widget.userId,
                          portal: widget.portal,
                        );
                      },
                      icon: const Icon(Icons.mic),
                      label: const Text('Tap to Speak'),
                    ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Or Type Query Text
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Or type query (e.g. "my lab results")',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      if (_textController.text.trim().isNotEmpty) {
                        final text = _textController.text.trim();
                        _textController.clear();
                        voiceService.sendDirectTextQuery(
                          query: text,
                          userId: widget.userId,
                          portal: widget.portal,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStateVisualizer(BuildContext context, VoiceState state) {
    switch (state) {
      case VoiceState.listening:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic, size: 44, color: Colors.redAccent),
            ),
            const SizedBox(height: 8),
            const Text('Listening... Speak your health question', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        );
      case VoiceState.processing:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_outlined, size: 44, color: Colors.orangeAccent),
            ),
            const SizedBox(height: 8),
            const Text('Processing intent & checking DB records...', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
          ],
        );
      case VoiceState.speaking:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.volume_up_rounded, size: 44, color: Colors.green),
            ),
            const SizedBox(height: 8),
            const Text('Speaking response...', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        );
      case VoiceState.idle:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mic_none_rounded, size: 44, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 8),
            const Text('Tap the mic to ask about appointments or reports', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        );
    }
  }
}
