import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/notixa_palette.dart';
import '../../../../core/design_system/notixa_app_bar.dart';
import '../../../../core/design_system/notixa_button.dart';
import '../../../../core/design_system/notixa_text_field.dart';
import '../../domain/models/meeting.dart';
import '../../domain/repositories/calendar_repository.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Meeting> _allMeetings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    setState(() => _isLoading = true);
    final repo = context.read<CalendarRepository>();
    final result = await repo.getMeetings();
    if (result.isSuccess && mounted) {
      setState(() {
        _allMeetings = result.dataOrNull ?? [];
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Meeting> _getMeetingsForDay(DateTime day) {
    return _allMeetings.where((m) {
      return isSameDay(m.startTime, day);
    }).toList();
  }

  void _showAddMeetingDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Schedule Meeting', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    NotixaTextField(
                      controller: titleController,
                      hintText: 'Meeting title or subject',
                      labelText: 'Title',
                    ),
                    const SizedBox(height: 14),
                    NotixaTextField(
                      controller: descController,
                      hintText: 'Notes, link, or location',
                      labelText: 'Description (Optional)',
                    ),
                    const SizedBox(height: 14),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time, color: NotixaPalette.primary),
                      title: const Text('Start Time'),
                      trailing: Text(
                        startTime.format(ctx),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(context: ctx, initialTime: startTime);
                        if (picked != null) {
                          setSheetState(() => startTime = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    NotixaButton(
                      label: 'Save Meeting',
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;
                        final startDateTime = DateTime(
                          _selectedDay.year,
                          _selectedDay.month,
                          _selectedDay.day,
                          startTime.hour,
                          startTime.minute,
                        );

                        final newMeeting = Meeting(
                          id: '',
                          title: titleController.text.trim(),
                          description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                          startTime: startDateTime,
                          endTime: startDateTime.add(const Duration(hours: 1)),
                        );

                        final repo = context.read<CalendarRepository>();
                        await repo.createMeeting(newMeeting);
                        Navigator.of(ctx).pop();
                        _loadMeetings();
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
    final dayMeetings = _getMeetingsForDay(_selectedDay);

    return Scaffold(
      appBar: NotixaAppBar(
        title: 'Calendar & Schedule',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: NotixaPalette.primary),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Table Calendar
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: NotixaPalette.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: NotixaPalette.primary,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(
                      color: isDark ? Colors.redAccent.shade100 : Colors.redAccent,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(),

                // Day Meetings Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d').format(_selectedDay),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${dayMeetings.length} meetings',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),

                // Meetings List
                Expanded(
                  child: dayMeetings.isEmpty
                      ? Center(
                          child: Text(
                            'No meetings for this day',
                            style: TextStyle(
                              color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: dayMeetings.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final m = dayMeetings[index];
                            return Container(
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
                                    child: const Icon(Icons.event_available, color: NotixaPalette.tertiary, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        if (m.description != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            m.description!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? NotixaPalette.textMutedDark : NotixaPalette.textMutedLight,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Text(
                                          '${DateFormat('hh:mm a').format(m.startTime)} - ${DateFormat('hh:mm a').format(m.endTime)}',
                                          style: const TextStyle(fontSize: 11, color: NotixaPalette.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: NotixaPalette.primary,
        onPressed: _showAddMeetingDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
