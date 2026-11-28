import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notixa/app/theme/notixa_palette.dart';
import 'package:notixa/core/speech/speech_recognition_bridge.dart';
import 'package:notixa/features/calendar/domain/models/meeting.dart';
import 'package:notixa/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:notixa/features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../domain/usecases/extract_note_usecase.dart';
import 'note_review_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToMeetings;

  const HomeDashboardScreen({super.key, this.onNavigateToMeetings});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  List<Meeting> _upcomingMeetings = [];
  bool _isListening = false;
  String _recognizedText = '';
  String _selectedLanguage = 'Arabic';

  @override
  void initState() {
    super.initState();
    _loadUpcomingMeetings();
    context.read<WalletBloc>().add(const LoadTransactionsEvent());
  }

  Future<void> _loadUpcomingMeetings() async {
    final repo = context.read<CalendarRepository>();
    final result = await repo.getMeetings();
    if (result.isSuccess && mounted) {
      setState(() {
        _upcomingMeetings = result.dataOrNull ?? [];
      });
    }
  }

  void _toggleLiveRecording() {
    if (_isListening) {
      SpeechRecognitionBridge.stop();
      setState(() => _isListening = false);
      if (_recognizedText.trim().isNotEmpty) {
        _processSpokenText(_recognizedText.trim());
      }
    } else {
      setState(() {
        _isListening = true;
        _recognizedText = '';
      });
      SpeechRecognitionBridge.start((liveText) {
        if (mounted) {
          setState(() {
            _recognizedText = liveText;
          });
        }
      });
    }
  }

  Future<void> _processSpokenText(String text) async {
    final extractor = context.read<ExtractNoteUsecase>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: NotixaPalette.primary),
                SizedBox(height: 16),
                Text('AI is analyzing your note...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    final result = await extractor(rawText: text);
    if (mounted) {
      Navigator.of(context).pop(); // dismiss loading dialog
      if (result.isSuccess && result.dataOrNull != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NoteReviewScreen(note: result.dataOrNull!),
          ),
        );
      }
    }
  }

  void _openTextInputModal() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: isDark ? NotixaPalette.darkCard : NotixaPalette.lightCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Type your note',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? NotixaPalette.textPrimaryDark : NotixaPalette.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. Spent 50 on food, 20 on coffee...',
                  filled: true,
                  fillColor: isDark ? NotixaPalette.darkSurface : NotixaPalette.lightFieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final txt = controller.text.trim();
                    if (txt.isNotEmpty) {
                      Navigator.of(ctx).pop();
                      _processSpokenText(txt);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NotixaPalette.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Analyze Note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? NotixaPalette.darkBackground : NotixaPalette.lightBackground;
    final cardBg = isDark ? NotixaPalette.darkCard : NotixaPalette.lightCard;
    final textPrimary = isDark ? NotixaPalette.textPrimaryDark : NotixaPalette.textPrimaryLight;
    final textMuted = isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight;
    final borderColor = isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER (Logo + Notification Bell)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: NotixaPalette.purpleBadge,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.all_inclusive, color: NotixaPalette.primary, size: 22),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Notixa',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: NotixaPalette.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_none_outlined, color: textPrimary, size: 26),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 12,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF43F5E), // Pink/Red notification dot
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. MAIN "WHAT'S ON YOUR MIND?" CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: borderColor),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    // Info Icon Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.info_outline, color: textMuted, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Title
                    Text(
                      "What's on your\nmind?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Controls Row (Pencil | Big Mic | Camera)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left: Pencil Edit Button
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: textMuted, size: 24),
                          onPressed: _openTextInputModal,
                        ),
                        const SizedBox(width: 24),

                        // Center: Animated Glowing Microphone
                        GestureDetector(
                          onTap: _toggleLiveRecording,
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isListening
                                  ? NotixaPalette.spentBackground
                                  : NotixaPalette.purpleBadge,
                              border: Border.all(
                                color: _isListening ? NotixaPalette.spent : NotixaPalette.secondary.withOpacity(0.4),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: _isListening
                                        ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                                        : [NotixaPalette.primary, const Color(0xFF8B5CF6)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isListening ? NotixaPalette.spent : NotixaPalette.primary).withOpacity(0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isListening ? Icons.stop : Icons.mic,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Right: Camera Scan Button
                        IconButton(
                          icon: Icon(Icons.camera_alt_outlined, color: textMuted, size: 24),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Camera & Receipt scan feature ready')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Language Selector
                    InkWell(
                      onTap: () {
                        setState(() {
                          _selectedLanguage = _selectedLanguage == 'Arabic' ? 'English' : 'Arabic';
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.settings_outlined, color: textMuted, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _selectedLanguage,
                            style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Live Speech Preview if listening
                    if (_isListening) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: NotixaPalette.spentBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _recognizedText.isEmpty ? 'Listening... Speak now' : _recognizedText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: NotixaPalette.spent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Subtitle
                    Text(
                      'Capture anything.\nWe Organize everything.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 3. UPCOMING SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upcoming',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your next 48 hours',
                        style: TextStyle(
                          fontSize: 13,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToMeetings,
                    child: const Text(
                      'VIEW MEETINGS',
                      style: TextStyle(
                        color: NotixaPalette.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Meetings List or Clean Empty Card
              if (_upcomingMeetings.isNotEmpty) ...[
                ..._upcomingMeetings.take(3).map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: NotixaPalette.purpleBadge,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.event, color: NotixaPalette.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${m.startTime.hour}:${m.startTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 12, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: Text(
                      'No meetings scheduled in the next 48 hours.',
                      style: TextStyle(color: textMuted, fontSize: 13),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
