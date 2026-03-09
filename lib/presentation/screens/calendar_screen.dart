// lib/presentation/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:abushakir/abushakir.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../providers/equb_provider.dart';
import '../providers/locale_provider.dart';
import '../../data/models/contribution_model.dart';
import '../../l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late EtDatetime _currentDate;
  late ETC _etc;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentDate = EtDatetime.fromMillisecondsSinceEpoch(
      now.millisecondsSinceEpoch,
    );
    _etc = ETC(year: _currentDate.year, month: _currentDate.month);
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
      _etc = ETC(year: _currentDate.year, month: _currentDate.month);
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
      _etc = ETC(year: _currentDate.year, month: _currentDate.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AbayLocalizations.of(context)!;
    final locale =
        Provider.of<LocaleProvider>(context).locale?.languageCode ?? 'en';
    final equbProvider = Provider.of<EqubProvider>(context);
    final contributions = _getContributionsForMonth(
      equbProvider.nextContribution,
    );

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMonthHeader(locale),
          _buildWeekdayLabels(locale),
          Expanded(child: _buildCalendarGrid(contributions)),
          _buildUpcomingSection(contributions, l10n),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(String locale) {
    final monthName = _getMonthName(_currentDate.month, locale);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _prevMonth,
            icon: const Icon(Icons.chevron_left, color: AppTheme.primaryColor),
          ),
          Column(
            children: [
              Text(
                monthName,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                "${_currentDate.year}",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
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
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
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

  Widget _buildCalendarGrid(List<ContributionModel> contributions) {
    // Use monthDays() which yields [year, month, day, weekdayIndex] entries
    // weekdayIndex: 0=Mon, 1=Tue, ..., 6=Sun (abushakir convention)
    final daysList = _etc.monthDays().toList();

    // The weekday of the 1st day gives us the column offset
    final startOffset = daysList.isNotEmpty ? (daysList.first[3] as int) : 0;

    // Build cells: leading nulls + day numbers
    final cells = <int?>[];
    for (int i = 0; i < startOffset; i++) {
      cells.add(null);
    }
    for (final entry in daysList) {
      cells.add(entry[2] as int);
    }
    // Pad to complete the last row
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 1,
      ),
      itemCount: cells.length,
      itemBuilder: (context, index) {
        final day = cells[index];
        if (day == null) return const SizedBox.shrink();

        final isToday = _isToday(day);
        final contribution = _getContributionForDay(day, contributions);

        return _buildDayCell(day, isToday, contribution);
      },
    );
  }

  Widget _buildDayCell(int day, bool isToday, ContributionModel? contribution) {
    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: AppTheme.primaryColor, width: 1)
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            "$day",
            style: GoogleFonts.outfit(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? AppTheme.primaryColor : Colors.black87,
              fontSize: 16,
            ),
          ),
          if (contribution != null)
            Positioned(
              bottom: 6,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection(
    List<ContributionModel> contributions,
    AbayLocalizations l10n,
  ) {
    if (contributions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 12),
            Text(
              "No contributions this month",
              style: GoogleFonts.outfit(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Contributions this month",
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 15),
            ...contributions.map((c) => _buildContributionItem(c)),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionItem(ContributionModel c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: AppTheme.accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.groupInfo?.name ?? "eQub Contribution",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Due on ${_formatDay(c.dueDate!)}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "${c.amount?.toStringAsFixed(0)} ETB",
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  List<ContributionModel> _getContributionsForMonth(ContributionModel? next) {
    if (next == null || next.dueDate == null) return [];

    final etDueDate = EtDatetime.fromMillisecondsSinceEpoch(
      next.dueDate!.millisecondsSinceEpoch,
    );
    if (etDueDate.year == _currentDate.year &&
        etDueDate.month == _currentDate.month) {
      return [next];
    }
    return [];
  }

  ContributionModel? _getContributionForDay(
    int day,
    List<ContributionModel> contributions,
  ) {
    for (var c in contributions) {
      if (c.dueDate == null) continue;
      final etDate = EtDatetime.fromMillisecondsSinceEpoch(
        c.dueDate!.millisecondsSinceEpoch,
      );
      if (etDate.day == day) return c;
    }
    return null;
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    final etNow = EtDatetime.fromMillisecondsSinceEpoch(
      now.millisecondsSinceEpoch,
    );
    return etNow.year == _currentDate.year &&
        etNow.month == _currentDate.month &&
        etNow.day == day;
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

  String _formatDay(DateTime date) {
    final etDate = EtDatetime.fromMillisecondsSinceEpoch(
      date.millisecondsSinceEpoch,
    );
    return "${etDate.day}/${etDate.month}/${etDate.year}";
  }
}
