// lib/presentation/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:abushakir/abushakir.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/equb_provider.dart';
import '../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

enum EventType { contribution, groupStart, other }

class AppEvent {
  final DateTime date;
  final String title;
  final String subtitle;
  final String amount;
  final EventType type;

  AppEvent({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
  });
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late EtDatetime _currentDate;
  late ETC _etc;
  int? _selectedDay;
  List<AppEvent> _monthEvents = [];
  List<int?> _calendarCells = [];
  Map<int, List<AppEvent>> _eventsByDay = {};
  int? _todayDay; // Cache for the current day number if month matches

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentDate = EtDatetime.fromMillisecondsSinceEpoch(
      now.millisecondsSinceEpoch,
    );
    _updateCalendarState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final equbProvider = Provider.of<EqubProvider>(context, listen: false);
      if (equbProvider.myGroups.isEmpty) {
        equbProvider.fetchUserEqubData();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final equbProvider = Provider.of<EqubProvider>(context);
    _updateEvents(equbProvider);
  }

  void _updateCalendarState() {
    _etc = ETC(year: _currentDate.year, month: _currentDate.month);

    // Pre-calculate calendar cells
    final daysList = _etc.monthDays().toList();
    final startOffset = daysList.isNotEmpty ? (daysList.first[3] as int) : 0;

    _calendarCells = <int?>[];
    for (int i = 0; i < startOffset; i++) {
      _calendarCells.add(null);
    }
    for (final entry in daysList) {
      _calendarCells.add(entry[2] as int);
    }
    while (_calendarCells.length % 7 != 0) {
      _calendarCells.add(null);
    }

    // Cache if today is in this month
    final now = DateTime.now();
    final etNow = EtDatetime.fromMillisecondsSinceEpoch(
      now.millisecondsSinceEpoch,
    );
    if (etNow.year == _currentDate.year && etNow.month == _currentDate.month) {
      _todayDay = etNow.day;
    } else {
      _todayDay = null;
    }
  }

  void _updateEvents(EqubProvider provider) {
    if (!mounted) return;
    final all = _extractEvents(provider);
    final month = _getEventsForCurrentMonth(all);

    // Efficiency: Pass through events once and map them by day
    final map = <int, List<AppEvent>>{};
    for (var e in month) {
      try {
        final etDate = EtDatetime.fromMillisecondsSinceEpoch(
          e.date.millisecondsSinceEpoch,
        );
        map.putIfAbsent(etDate.day, () => []).add(e);
      } catch (_) {}
    }

    setState(() {
      _monthEvents = month;
      _eventsByDay = map;
    });
  }

  void _nextMonth() {
    setState(() {
      int nextMonth = _currentDate.month + 1;
      int nextYear = _currentDate.year;
      if (nextMonth > 13) {
        nextMonth = 1;
        nextYear++;
      }
      _currentDate = EtDatetime(year: nextYear, month: nextMonth, day: 1);
      _updateCalendarState();
      _selectedDay = null;
      // Immediate sync for navigation responsiveness
      _updateEvents(Provider.of<EqubProvider>(context, listen: false));
    });
  }

  void _prevMonth() {
    setState(() {
      int prevMonth = _currentDate.month - 1;
      int prevYear = _currentDate.year;
      if (prevMonth < 1) {
        prevMonth = 13;
        prevYear--;
      }
      _currentDate = EtDatetime(year: prevYear, month: prevMonth, day: 1);
      _updateCalendarState();
      _selectedDay = null;
      // Immediate sync for navigation responsiveness
      _updateEvents(Provider.of<EqubProvider>(context, listen: false));
    });
  }

  List<AppEvent> _extractEvents(EqubProvider provider) {
    List<AppEvent> events = [];
    if (provider.nextContribution?.dueDate != null) {
      events.add(
        AppEvent(
          date: provider.nextContribution!.dueDate!,
          title:
              provider.nextContribution!.groupInfo?.name ?? "eQub Contribution",
          subtitle: "Contribution Due",
          amount:
              "${provider.nextContribution!.amount?.toStringAsFixed(0)} ETB",
          type: EventType.contribution,
        ),
      );
    }
    for (var group in provider.myGroups) {
      if (group.startDate != null) {
        events.add(
          AppEvent(
            date: group.startDate!,
            title: group.name ?? "Savings Group",
            subtitle: "eQub Started",
            amount: "Active",
            type: EventType.groupStart,
          ),
        );
      }
    }
    return events;
  }

  List<AppEvent> _getEventsForCurrentMonth(List<AppEvent> allEvents) {
    return allEvents.where((e) {
      try {
        final etDate = EtDatetime.fromMillisecondsSinceEpoch(
          e.date.millisecondsSinceEpoch,
        );
        return etDate.year == _currentDate.year &&
            etDate.month == _currentDate.month;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  List<AppEvent> _getEventsForDay(int day) {
    return _eventsByDay[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AbayLocalizations.of(context)!;
    final locale =
        Provider.of<LocaleProvider>(context).locale?.languageCode ?? 'en';
    final theme = Theme.of(context);

    // Use the pre-calculated _monthEvents
    final monthEvents = _monthEvents;

    // If a day is selected, show events for that day, else show all for month
    final displayEvents = _selectedDay != null
        ? _getEventsForDay(_selectedDay!)
        : monthEvents;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Calendar & Events',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: _buildMonthHeader(locale)),
          SliverToBoxAdapter(child: _buildWeekdayLabels(locale)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _buildCalendarGrid(monthEvents),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: true,
            child: _buildUpcomingSection(displayEvents, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(String locale) {
    final monthName = _getMonthName(_currentDate.month, locale);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _prevMonth,
              icon: Icon(Icons.chevron_left, color: theme.primaryColor),
            ),
          ),
          Column(
            children: [
              Text(
                monthName,
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: theme.primaryColor,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "${_currentDate.year}",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _nextMonth,
              icon: Icon(Icons.chevron_right, color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels(String locale) {
    final labels = locale == 'am'
        ? ['ሰኞ', 'ማክ', 'ረቡ', 'ሐሙ', 'አር', 'ቅዳ', 'እሁ']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: labels
            .map(
              (label) => Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(List<AppEvent> monthEvents) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // no scroll for calendar
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _calendarCells.length,
      itemBuilder: (context, index) {
        final day = _calendarCells[index];
        if (day == null) return const SizedBox.shrink();

        final isToday = _isToday(day);
        final isSelected = _selectedDay == day;
        final dayEvents = _getEventsForDay(day);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedDay == day) {
                _selectedDay = null; // deselect
              } else {
                _selectedDay = day;
              }
            });
          },
          child: _buildDayCell(day, isToday, isSelected, dayEvents),
        );
      },
    );
  }

  Widget _buildDayCell(
    int day,
    bool isToday,
    bool isSelected,
    List<AppEvent> dayEvents,
  ) {
    final theme = Theme.of(context);

    // UI states
    final hasEvents = dayEvents.isNotEmpty;
    final hasContribution = dayEvents.any(
      (e) => e.type == EventType.contribution,
    );
    final hasStart = dayEvents.any((e) => e.type == EventType.groupStart);

    // Background colors
    Color bgColor = Colors.transparent;
    if (isSelected) {
      bgColor = theme.primaryColor;
    } else if (isToday) {
      bgColor = theme.primaryColor.withValues(alpha: 0.1);
    }

    // Text colors
    Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    if (isSelected) {
      textColor = Colors.white;
    } else if (isToday) {
      textColor = theme.primaryColor;
    } else if (hasEvents) {
      textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: isToday && !isSelected
            ? Border.all(color: theme.primaryColor, width: 2)
            : Border.all(
                color: theme.dividerColor.withValues(alpha: 0.1),
                width: 1,
              ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            "$day",
            style: GoogleFonts.outfit(
              fontWeight: isSelected || isToday || hasEvents
                  ? FontWeight.w900
                  : FontWeight.w500,
              color: textColor,
              fontSize: 18,
            ),
          ),

          // Event Indicator Dots at bottom
          if (hasEvents)
            Positioned(
              bottom: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasContribution)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.secondary, // Gold
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (hasStart)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white70
                            : const Color(0xFF10B981), // Green
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection(List<AppEvent> events, AbayLocalizations l10n) {
    final theme = Theme.of(context);

    if (events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        constraints: const BoxConstraints(minHeight: 300),
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 56,
              color: theme.hintColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedDay != null
                  ? "No events on this day"
                  : "No events this month",
              style: GoogleFonts.outfit(
                color: theme.hintColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return FadeInUp(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(minHeight: 300),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDay != null
                      ? "Events for ${_getMonthName(_currentDate.month, 'en')} $_selectedDay"
                      : "Events this month",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: theme.primaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${events.length}",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(events.length, (index) {
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: _buildEventItem(events[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(AppEvent event) {
    final theme = Theme.of(context);

    // Determine visuals based on type
    Color iconBgColor;
    Color iconColor;
    IconData iconData;

    if (event.type == EventType.contribution) {
      iconBgColor = theme.colorScheme.secondary.withValues(alpha: 0.15); // Gold
      iconColor = theme.colorScheme.secondary;
      iconData = Icons.payments_rounded;
    } else {
      iconBgColor = const Color(0xFF10B981).withValues(alpha: 0.15); // Green
      iconColor = const Color(0xFF10B981);
      iconData = Icons.flag_circle_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon block
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Info block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  event.subtitle,
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Amount & Date block
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                event.amount,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w900,
                  color: theme.primaryColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateOnly(event.date),
                style: GoogleFonts.outfit(
                  color: theme.hintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isToday(int day) {
    return _todayDay == day;
  }

  String _getMonthName(int month, String locale) {
    final amharicMonths = [
      'መስከረም',
      'ጥቅምት',
      'ህዳር',
      'ታህሳስ',
      'ጥር',
      'የካቲት',
      'መጋቢት',
      'ሚያዝያ',
      'ግንቦት',
      'ሰኔ',
      'ሐምሌ',
      'ነሐሴ',
      'ጳጉሜ',
    ];
    final englishMonths = [
      "Meskerem",
      "Tikimt",
      "Hidar",
      "Tahsas",
      "Tir",
      "Yekatit",
      "Megabit",
      "Miyaziya",
      "Ginbot",
      "Sene",
      "Hamle",
      "Nehase",
      "Pagume",
    ];

    if (locale == 'am') return amharicMonths[month - 1];
    return englishMonths[month - 1];
  }

  String _formatDateOnly(DateTime date) {
    final etDate = EtDatetime.fromMillisecondsSinceEpoch(
      date.millisecondsSinceEpoch,
    );
    return "${etDate.day} ${_getMonthName(etDate.month, 'en').substring(0, 3)}";
  }
}
