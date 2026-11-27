import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:notixa/app/theme/notixa_palette.dart';
import 'package:notixa/core/design_system/notixa_button.dart';
import 'package:notixa/core/speech/speech_recognition_bridge.dart';
import 'package:notixa/features/calendar/domain/models/meeting.dart';
import 'package:notixa/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:notixa/features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../domain/usecases/extract_note_usecase.dart';
import 'note_review_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  List<Meeting> _upcomingMeetings = [];

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

  void _openVoiceRecordingModal(BuildContext context) {
    // Empty by default as requested by user
    final textController = TextEditingController(text: '');
    bool isListening = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            void toggleListening() {
              if (isListening) {
                SpeechRecognitionBridge.stop();
                setSheetState(() => isListening = false);
              } else {
                setSheetState(() => isListening = true);
                SpeechRecognitionBridge.start((liveText) {
                  setSheetState(() {
                    textController.text = liveText;
                  });
                });
              }
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 24,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? NotixaPalette.darkSurface : NotixaPalette.lightSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'المساعد الصوتي الذكي',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'تكلم بطبيعتك، أو اكتب الملاحظة، وسيقوم الذكاء الاصطناعي بتفصيل المصروفات والمواعيد تلقائياً.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? NotixaPalette.textSecondaryDark : NotixaPalette.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Big Animated Microphone
                    GestureDetector(
                      onTap: toggleListening,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isListening ? 90 : 80,
                        height: isListening ? 90 : 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isListening
                                ? [NotixaPalette.error, const Color(0xFFDC2626)]
                                : [NotixaPalette.primary, NotixaPalette.secondary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isListening ? NotixaPalette.error : NotixaPalette.primary).withOpacity(0.4),
                              blurRadius: isListening ? 24 : 16,
                              spreadRadius: isListening ? 4 : 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          isListening ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isListening ? 'جاري الاستماع... تكلم الآن' : 'اضغط على المايك للتحدث',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isListening ? NotixaPalette.error : NotixaPalette.primary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Live Speech / Text Field
                    TextField(
                      controller: textController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'النص المسجل / المكتوب',
                        hintText: 'تكلم وسيظهر كلامك هنا فوراً، أو اكتب مباشرة...',
                        filled: true,
                        fillColor: isDark ? NotixaPalette.darkCard : NotixaPalette.lightCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Process Button (Immediately stops mic if running and processes)
                    NotixaButton(
                      label: 'تحليل وتفصيل البنود',
                      onPressed: () async {
                        // Stop listening immediately if still active
                        if (isListening) {
                          SpeechRecognitionBridge.stop();
                          isListening = false;
                        }

                        final spokenText = textController.text.trim();
                        if (spokenText.isEmpty) return;

                        Navigator.of(ctx).pop();

                        final extractor = context.read<ExtractNoteUsecase>();
                        final extractResult = await extractor(rawText: spokenText);

                        if (extractResult.isSuccess && mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NoteReviewScreen(note: extractResult.dataOrNull!),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayStr = DateFormat('EEEE, d MMMM', 'ar').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header without emojis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todayStr,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'أهلاً بك',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: NotixaPalette.primary.withOpacity(0.2),
                    child: const Icon(Icons.person, color: NotixaPalette.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Featured Card: AI Voice Note
              _buildFeaturedCard(isDark),
              const SizedBox(height: 24),

              // Main Voice Action Button
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _openVoiceRecordingModal(context),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [NotixaPalette.primary, NotixaPalette.secondary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: NotixaPalette.primary.withOpacity(0.4),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mic, color: Colors.white, size: 36),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'اضغط للتسجيل الصوتي أو كتابة الملاحظة',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NotixaPalette.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Upcoming Meetings Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'اجتماعات ومواعيد اليوم',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_upcomingMeetings.isEmpty)
                _buildEmptyMeetings(isDark)
              else
                ..._upcomingMeetings.take(3).map((m) => _buildMeetingTile(m, isDark)),

              const SizedBox(height: 24),

              // Wallet Overview Card
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  if (state is WalletLoaded) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? NotixaPalette.darkCard : NotixaPalette.lightCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'رصيد المحفظة الحالي',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${NumberFormat('#,##0.00').format(state.balance)} ${state.selectedCurrency}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: NotixaPalette.primary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: NotixaPalette.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.account_balance_wallet, color: NotixaPalette.primary),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'محرك الذكاء الاصطناعي',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'تحدث بطبيعتك عن يومك ومصروفاتك.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'يقوم التطبيق بتفصيل كل العمليات والمواعيد تلقائياً وحساب المتبقي.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingTile(Meeting m, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? NotixaPalette.darkSurface : NotixaPalette.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NotixaPalette.tertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.event, color: NotixaPalette.tertiary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('hh:mm a').format(m.startTime)} - ${DateFormat('hh:mm a').format(m.endTime)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMeetings(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? NotixaPalette.darkSurface : NotixaPalette.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? NotixaPalette.darkBorder : NotixaPalette.lightBorder),
      ),
      child: Center(
        child: Text(
          'لا توجد اجتماعات مسجلة لليوم',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
          ),
        ),
      ),
    );
  }
}
