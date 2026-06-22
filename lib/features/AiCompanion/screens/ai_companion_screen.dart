import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart'; // Added for TapGestureRecognizer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart'; // Added for video_player
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart'; // Added for AppToast
import '../../../data/models/note_model.dart';
import 'package:planly/features/notes/bloc/notes_bloc.dart';
import 'package:planly/features/notes/bloc/notes_event.dart';
import 'package:planly/features/navigation/screens/main_layout.dart';
import 'package:planly/features/AiCompanion/services/ai_companion_service.dart';

class AICompanionScreen extends StatefulWidget {
  const AICompanionScreen({super.key});

  @override
  State<AICompanionScreen> createState() => _AICompanionScreenState();
}

class _AICompanionScreenState extends State<AICompanionScreen> {
  final AICompanionService _aiService = AICompanionService();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isProcessingVideo = false;
  double _videoPlayProgress = 0.0;
  bool _isVideoPlaying = false;
  String _currentVideoName = "Pilih Rekaman Video Kuliah (MP4)";

  // Real video player variables
  VideoPlayerController? _videoPlayerController;
  bool _isVideoInitialized = false;

  // Timed transcripts
  final List<Map<String, dynamic>> _transcript = [
    {"time": "00:15", "seconds": 15, "text": "Selamat pagi rekan-rekan mahasiswa. Hari ini kita akan membahas tentang Kecerdasan Buatan."},
    {"time": "01:30", "seconds": 90, "text": "Secara mendasar, AI terbagi menjadi Narrow AI dan General AI. Contoh Narrow AI adalah filter spam dan face scanner."},
    {"time": "03:45", "seconds": 225, "text": "Mari kita bahas formula Euclidean Distance yang digunakan dalam matching descriptor: d(A,B) = sqrt(sum(A_i - B_i)^2)."},
    {"time": "05:10", "seconds": 310, "text": "Untuk tugas minggu ini, silakan buat implementasi graf DFS & BFS menggunakan bahasa Dart atau Python."},
  ];

  final List<Map<String, dynamic>> _messages = [
    {
      "isMe": false,
      "text": "Halo! Saya Asisten Kuliah AI Anda. Silakan unggah rekaman video kuliah (MP4) Anda untuk diekstrak audionya menggunakan FFmpeg dan diringkas secara cerdas oleh Gemini 2.5 Flash."
    }
  ];

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    await _aiService.initialize();
    if (!_aiService.hasApiKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showApiKeyDialog();
      });
    }
  }

  void _showApiKeyDialog() {
    final TextEditingController keyController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Gemini API Key', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Silakan masukkan Gemini API Key Anda untuk melanjutkan pemrosesan AI (ekstraksi video & RAG).',
                style: TextStyle(fontSize: 14, color: AppColors.textLightSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keyController,
                decoration: InputDecoration(
                  hintText: 'AIzaSy...',
                  hintStyle: const TextStyle(color: AppColors.textLightSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outlineLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Nanti Saja', style: TextStyle(color: AppColors.secondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final key = keyController.text.trim();
                if (key.isNotEmpty) {
                  await _aiService.saveApiKey(key);
                  if (mounted) {
                    Navigator.pop(context);
                    AppToast.showSuccess(context, 'API Key berhasil disimpan!');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Widget _buildMessageText(String text, bool isMe) {
    // Regex to match timestamps like "MM:SS" or "HH:MM:SS" (e.g. "00:15", "1:30", "01:23:45")
    final regex = RegExp(r'\b(?:(\d{1,2}):)?(\d{1,2}):(\d{2})\b');
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: isMe ? Colors.white : AppColors.textLightPrimary,
          fontSize: 14,
          height: 1.4,
        ),
      );
    }

    final List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Add text before the match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(
            color: isMe ? Colors.white : AppColors.textLightPrimary,
            fontSize: 14,
            height: 1.4,
          ),
        ));
      }

      final timestampStr = match.group(0)!;
      final hourStr = match.group(1);
      final minStr = match.group(2)!;
      final secStr = match.group(3)!;

      final hours = hourStr != null ? int.parse(hourStr) : 0;
      final minutes = int.parse(minStr);
      final seconds = int.parse(secStr);
      final totalSeconds = hours * 3600 + minutes * 60 + seconds;

      // Add clickable timestamp
      spans.add(TextSpan(
        text: timestampStr,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.blue.shade700,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            if (_isVideoInitialized && _videoPlayerController != null) {
              _videoPlayerController!.seekTo(Duration(seconds: totalSeconds));
              _videoPlayerController!.play();
            } else {
              AppToast.showInfo(context, 'Pilih dan proses video terlebih dahulu untuk menggunakan timestamp');
            }
          },
      ));

      lastMatchEnd = match.end;
    }

    // Add remaining text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(
          color: isMe ? Colors.white : AppColors.textLightPrimary,
          fontSize: 14,
          height: 1.4,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _processVideo() async {
    if (!_aiService.hasApiKey) {
      _showApiKeyDialog();
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null && result.files.single.path != null) {
        final videoPath = result.files.single.path!;
        final videoName = result.files.single.name;

        setState(() {
          _isProcessingVideo = true;
          _currentVideoName = videoName;
          _isVideoInitialized = false;
          _videoPlayProgress = 0.0;
        });

        // Initialize video player
        try {
          if (_videoPlayerController != null) {
            await _videoPlayerController!.dispose();
          }
          _videoPlayerController = VideoPlayerController.file(File(videoPath));
          await _videoPlayerController!.initialize();
          _videoPlayerController!.addListener(() {
            if (mounted) {
              final duration = _videoPlayerController!.value.duration;
              final position = _videoPlayerController!.value.position;
              setState(() {
                _videoPlayProgress = duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0.0;
                _isVideoPlaying = _videoPlayerController!.value.isPlaying;
              });
            }
          });
          setState(() {
            _isVideoInitialized = true;
          });
        } catch (ve) {
          debugPrint('Error initializing video player: $ve');
        }

        // Use AICompanionService to process video -> audio -> Gemini
        final jsonResult = await _aiService.processLectureFile(videoPath);

        if (jsonResult != null) {
          final Map<String, dynamic> parsed = jsonDecode(jsonResult);
          
          final List<dynamic> chaptersJson = parsed['chapters'] ?? [];
          final List<Map<String, dynamic>> dynamicChapters = [];
          for (var item in chaptersJson) {
            final timestampStr = item['timestamp'] ?? '00:00:00';
            int secs = 0;
            try {
              final parts = timestampStr.split(':');
              if (parts.length == 3) {
                secs = int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60 + int.parse(parts[2]);
              } else if (parts.length == 2) {
                secs = int.parse(parts[0]) * 60 + int.parse(parts[1]);
              }
            } catch (ex) {
              debugPrint('Error parsing timestamp: $timestampStr, $ex');
            }

            String displayTime = timestampStr;
            if (timestampStr.length > 5 && timestampStr.startsWith('00:')) {
              displayTime = timestampStr.substring(3);
            }

            dynamicChapters.add({
              "time": displayTime,
              "seconds": secs,
              "text": item['title'] ?? item['summary'] ?? '',
            });
          }
          
          String summaryText = '### Transkrip Lengkap\n\n${parsed['transcript']}\n\n';
          summaryText += '### Takeaways\n\n';
          for (var item in (parsed['takeaways'] ?? [])) {
            summaryText += '- $item\n';
          }

          if (mounted) {
            setState(() {
              _isProcessingVideo = false;
              if (dynamicChapters.isNotEmpty) {
                _transcript.clear();
                _transcript.addAll(dynamicChapters);
              }
              _messages.add({
                "isMe": false,
                "text": "Ekstraksi audio MP4 -> WAV mono 16kHz berhasil!\nBerikut adalah transkrip bertimestamp dan ringkasan pengayaan materi kuliah Anda dari Gemini 2.5 Flash:"
              });
              _messages.add({
                "isMe": false,
                "text": summaryText,
                "isSummary": true,
              });
            });
            _scrollToBottom();
          }
        } else {
          throw Exception("Gagal mendapatkan respons dari Gemini API");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingVideo = false);
        AppToast.showError(context, 'Terjadi kesalahan pengolahan: $e');
      }
    }
  }

  void _sendChatMessage() async {
    if (!_aiService.hasApiKey) {
      _showApiKeyDialog();
      return;
    }

    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"isMe": true, "text": text});
      _chatController.clear();
    });
    _scrollToBottom();

    // Context-Aware RAG answer via AICompanionService
    final answer = await _aiService.chatWithLectureContext(text);

    if (mounted) {
      setState(() {
        _messages.add({
          "isMe": false,
          "text": answer
        });
      });
      _scrollToBottom();
    }
  }

  void _saveToNotes(String content) {
    context.read<NotesBloc>().add(AddNote(
      NoteModel(
        id: 0,
        user_id: 1,
        title: "Ringkasan Kuliah AI - ${_currentVideoName.split('.')[0]}",
        content: content,
      )
    ));

    AppToast.showSuccess(context, 'Ringkasan kuliah berhasil disimpan ke Catatan Belajar Anda!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Asisten Kuliah AI', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primary),
            onPressed: () => context.findAncestorStateOfType<MainLayoutState>()?.openDrawer(),
          ),
        ),
      ),
      body: Column(
        children: [
          // sepertiga atas (16:9) Video Player Panel
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isVideoInitialized && _videoPlayerController != null)
                    Center(
                      child: AspectRatio(
                        aspectRatio: _videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController!),
                      ),
                    )
                  else
                    // Video Background Info
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.movie_creation_outlined, color: Colors.white54, size: 48),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _currentVideoName,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Media Controller overlays
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black54,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_isVideoInitialized && _videoPlayerController != null) {
                                setState(() {
                                  if (_videoPlayerController!.value.isPlaying) {
                                    _videoPlayerController!.pause();
                                    _isVideoPlaying = false;
                                  } else {
                                    _videoPlayerController!.play();
                                    _isVideoPlaying = true;
                                  }
                                });
                              } else {
                                setState(() {
                                  _isVideoPlaying = !_isVideoPlaying;
                                });
                              }
                            },
                            child: Icon(
                              _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Slider(
                              value: _videoPlayProgress.clamp(0.0, 1.0),
                              activeColor: AppColors.primary,
                              inactiveColor: Colors.white24,
                              onChanged: (val) {
                                if (_isVideoInitialized && _videoPlayerController != null) {
                                  final duration = _videoPlayerController!.value.duration;
                                  final seekPosition = Duration(
                                    milliseconds: (val * duration.inMilliseconds).toInt(),
                                  );
                                  _videoPlayerController!.seekTo(seekPosition);
                                }
                                setState(() {
                                  _videoPlayProgress = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Chat & Transcription list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] ?? false;
                final isSummary = msg['isSummary'] ?? false;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        // Chat Bubble containing RAG logic
                        Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              bottomLeft: const Radius.circular(16),
                              topRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                              bottomRight: !isMe ? const Radius.circular(4) : const Radius.circular(16),
                            ),
                            border: isMe ? null : Border.all(color: AppColors.outlineLight),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMessageText(msg['text'] ?? '', isMe),
                              if (isSummary) ...[
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () => _saveToNotes(msg['text']),
                                  icon: const Icon(Icons.bookmark_add, size: 16),
                                  label: const Text('Simpan ke Catatan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                )
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Audio extractor indicator
          if (_isProcessingVideo)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primaryContainer.withOpacity(0.5),
              child: Row(
                children: const [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Mengekstrak audio WAV mono 16kHz & Memproses rangkuman Gemini...',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

          // Timestamps interactive timeline drawer (Horizontal list)
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.outlineLight.withOpacity(0.5))),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _transcript.length,
              itemBuilder: (context, index) {
                final item = _transcript[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    avatar: const Icon(Icons.play_circle_outline, size: 14, color: AppColors.primary),
                    label: Text(item['time'], style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      final seconds = item['seconds'] as int;
                      if (_isVideoInitialized && _videoPlayerController != null) {
                        _videoPlayerController!.seekTo(Duration(seconds: seconds));
                        _videoPlayerController!.play();
                        AppToast.showInfo(
                          context,
                          "Melompat ke transkrip ${item['time']}: \"${item['text']}\"",
                          title: "Seek Video",
                        );
                      } else {
                        setState(() {
                          _videoPlayProgress = seconds / 350.0;
                        });
                        AppToast.showInfo(
                          context,
                          "Melompat ke transkrip ${item['time']}: \"${item['text']}\" (Simulasi)",
                          title: "Seek Video",
                        );
                      }
                    },
                    backgroundColor: AppColors.primaryContainer.withOpacity(0.3),
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.outlineLight)),
            ),
            child: Row(
              children: [
                // Reset Chat
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.secondary),
                  onPressed: () {
                    setState(() {
                      _messages.clear();
                      _messages.add({
                        "isMe": false,
                        "text": "Riwayat obrolan AI telah direset. Silakan ajukan pertanyaan atau unggah video kuliah baru."
                      });
                    });
                  },
                ),
                
                // Upload MP4
                IconButton(
                  icon: const Icon(Icons.video_library, color: AppColors.primary),
                  onPressed: _processVideo,
                ),
                
                // Text input
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _chatController,
                      decoration: const InputDecoration(
                        hintText: 'Tanyakan sesuatu...',
                        hintStyle: TextStyle(fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Send
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _sendChatMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
