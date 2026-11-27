import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/notixa_palette.dart';
import '../../../../core/speech/deepgram_speech_service.dart';
import '../../../calendar/domain/models/meeting.dart';
import '../../../calendar/domain/repositories/calendar_repository.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../../domain/usecases/extract_note_usecase.dart';
import 'note_review_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final DeepgramSpeechService _speechService = DeepgramSpeechService();
  bool _isRecording = false;
  bool _isProcessing = false;
  List<Meeting> _upcomingMeetings = [];

  @override
  void initState() {
    super.initState();
    _loadUpcomingMeetings();
    context.read<WalletBloc>().add(const LoadTransactionsEvent());
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
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

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      final stopResult = await _speechService.stopRecording();
      final audioPath = stopResult.dataOrNull;

      // Extract note
      final extractor = context.read<ExtractNoteUsecase>();
      final extractResult = await extractor(
        rawText: 'اشتريت قهوة وغداء ب 120 جنية وعندي اجتماع مع الفريق الساعة 4 العصر',
        audioPath: audioPath,
      );

      setState(() => _isProcessing = false);

      if (extractResult.isSuccess && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NoteReviewScreen(note: extractResult.dataOrNull!),
          ),
        );
      }
    } else {
      final startResult = await _speechService.startRecording();
      if (startResult.isSuccess) {
        setState(() => _isRecording = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayStr = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                        'Hello, Friend 👋',
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

              // Voice Action Button
              _buildVoiceRecordButton(isDark),
              const SizedBox(height: 28),

              // Upcoming Meetings Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Meetings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
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
                                'Wallet Balance',
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
                'Notixa AI Engine',
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
            'Speak naturally about your day.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Notixa extracts tasks, appointments, expenses, and notes automatically.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceRecordButton(bool isDark) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggleRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isRecording ? 84 : 76,
              height: _isRecording ? 84 : 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isRecording
                      ? [NotixaPalette.error, const Color(0xFFDC2626)]
                      : [NotixaPalette.primary, NotixaPalette.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? NotixaPalette.error : NotixaPalette.primary).withOpacity(0.4),
                    blurRadius: _isRecording ? 24 : 16,
                    spreadRadius: _isRecording ? 4 : 0,
                  ),
                ],
              ),
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 34,
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isRecording
                ? 'Recording... Tap to stop'
                : (_isProcessing ? 'AI is extracting notes...' : 'Tap to speak voice note'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _isRecording
                  ? NotixaPalette.error
                  : (isDark ? NotixaPalette.textSecondaryDark : NotixaPalette.textSecondaryLight),
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
          'No upcoming meetings today',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
          ),
        ),
      ),
    );
  }
}
