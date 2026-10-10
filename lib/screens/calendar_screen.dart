import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../models/match_ad.dart';
import '../models/application.dart';
import '../theme/app_theme.dart';
import '../core/utils/date_formatter.dart';
import 'match_details_screen.dart';
import 'create_ad_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  int _selectedFilterTab = 0; // 0: Seçilen Gün, 1: Oynayacağım Maçlar, 2: Başvurduğum Maçlar, 3: Tüm Yaklaşanlar, 4: Geçmiş Maçlar

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUser = appState.currentUser;
    final currentUserId = currentUser?.id;
    final now = DateTime.now();

    // User's applications
    final myApplications = currentUser != null
        ? appState.applications.where((app) => app.applicantId == currentUser.id).toList()
        : <Application>[];

    final myApplicationMap = {for (var a in myApplications) a.matchId: a};

    final myAcceptedMatchIds = myApplications
        .where((app) => app.status == ApplicationStatus.accepted)
        .map((app) => app.matchId)
        .toSet();

    final myAppliedMatchIds = myApplications.map((app) => app.matchId).toSet();

    // 1. Matches on selected date
    final matchesOnSelectedDate = appState.matches.where((m) {
      return m.dateTime.year == _selectedDate.year &&
          m.dateTime.month == _selectedDate.month &&
          m.dateTime.day == _selectedDate.day;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // 2. Onaylanmış & Oynayacağım Maçlar (Hosted or Accepted upcoming matches)
    final myConfirmedMatches = appState.matches.where((m) {
      final isHost = currentUserId != null && m.hostId == currentUserId;
      final isAccepted = myAcceptedMatchIds.contains(m.id);
      final isUpcoming = m.dateTime.isAfter(now.subtract(const Duration(hours: 3)));
      return (isHost || isAccepted) && isUpcoming;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // 3. Başvurduğum Maçlar (All matches where current user applied)
    final myAppliedMatches = appState.matches.where((m) {
      return myAppliedMatchIds.contains(m.id);
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // 4. Tüm Yaklaşanlar
    final allUpcomingMatches = appState.matches
        .where((m) => m.dateTime.isAfter(now.subtract(const Duration(hours: 3))))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // 5. Geçmiş Maçlar (Completed or date is in the past)
    final pastMatches = appState.matches
        .where((m) => m.dateTime.isBefore(now.subtract(const Duration(hours: 3))) || m.status == MatchStatus.completed)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    List<MatchAd> displayMatches;
    if (_selectedFilterTab == 0) {
      displayMatches = matchesOnSelectedDate;
    } else if (_selectedFilterTab == 1) {
      displayMatches = myConfirmedMatches;
    } else if (_selectedFilterTab == 2) {
      displayMatches = myAppliedMatches;
    } else if (_selectedFilterTab == 3) {
      displayMatches = allUpcomingMatches;
    } else {
      displayMatches = pastMatches;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calendar_month, color: AppTheme.primaryGreen),
            SizedBox(width: 8),
            Text(
              'Maç Takvimi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Month Navigation Header & Calendar Grid
          _buildMonthHeader(),
          _buildWeekdayHeader(),
          _buildCalendarGrid(appState, myAcceptedMatchIds),

          const SizedBox(height: 6),

          // 2. Horizontal Scrollable Filter Tabs (Seçilen Gün, Oynayacağım, Başvurduğum, Tüm Yaklaşanlar, Geçmiş)
          _buildFilterTabs(
            countDate: matchesOnSelectedDate.length,
            countConfirmed: myConfirmedMatches.length,
            countApplied: myAppliedMatches.length,
            countUpcoming: allUpcomingMatches.length,
            countPast: pastMatches.length,
          ),

          const Divider(height: 1, color: Colors.white10),

          // 3. Match List for Selected View
          Expanded(
            child: _buildMatchList(
              displayMatches,
              appState,
              myAcceptedMatchIds,
              myApplicationMap,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateAdScreen()),
          );
        },
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Maç Planla', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMonthHeader() {
    final monthName = DateFormat('MMMM yyyy', 'tr_TR').format(_focusedMonth);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppTheme.textLight),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
              });
            },
          ),
          Text(
            monthName.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryGreen, letterSpacing: 1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppTheme.textLight),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) {
          final isWeekend = day == 'Cmt' || day == 'Paz';
          return SizedBox(
            width: 38,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isWeekend ? AppTheme.primaryGreen : AppTheme.textMuted,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(AppState appState, Set<String> myAcceptedMatchIds) {
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday; // 1 = Monday
    final totalCells = ((firstWeekday - 1 + daysInMonth) / 7).ceil() * 7;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentUserId = appState.currentUser?.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalCells,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.25,
        ),
        itemBuilder: (context, index) {
          final dayOffset = index - (firstWeekday - 1);
          if (dayOffset < 0 || dayOffset >= daysInMonth) {
            return const SizedBox.shrink();
          }

          final dayNumber = dayOffset + 1;
          final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
          final isSelected = cellDate.year == _selectedDate.year &&
              cellDate.month == _selectedDate.month &&
              cellDate.day == _selectedDate.day;
          final isToday = cellDate.isAtSameMomentAs(today);

          // Find matches on this date
          final dayMatches = appState.matches.where((m) {
            return m.dateTime.year == cellDate.year &&
                m.dateTime.month == cellDate.month &&
                m.dateTime.day == cellDate.day;
          }).toList();

          final hasMyMatch = dayMatches.any((m) {
            final isHost = currentUserId != null && m.hostId == currentUserId;
            final isAccepted = myAcceptedMatchIds.contains(m.id);
            return isHost || isAccepted;
          });

          final hasMatches = dayMatches.isNotEmpty;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = cellDate;
                _selectedFilterTab = 0; // Auto-switch to selected day tab
              });
            },
            child: Container(
              margin: const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGreen
                    : (isToday ? AppTheme.primaryGreen.withOpacity(0.15) : AppTheme.cardDark.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : (isToday ? AppTheme.primaryGreen : Colors.white10),
                  width: isToday ? 1.5 : 0.8,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.black
                          : (isToday ? AppTheme.primaryGreen : Colors.white),
                    ),
                  ),
                  if (hasMatches) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 4.5,
                          height: 4.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.black
                                : (hasMyMatch ? Colors.amber : AppTheme.primaryGreen),
                          ),
                        ),
                        if (dayMatches.length > 1) ...[
                          const SizedBox(width: 2),
                          Container(
                            width: 4.5,
                            height: 4.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? Colors.black54 : Colors.lightBlueAccent,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterTabs({
    required int countDate,
    required int countConfirmed,
    required int countApplied,
    required int countUpcoming,
    required int countPast,
  }) {
    final selectedDateStr = DateFormat('d MMMM', 'tr_TR').format(_selectedDate);

    final tabs = [
      {'id': 0, 'label': '📅 $selectedDateStr ($countDate)'},
      {'id': 1, 'label': '✅ Oynayacağım Maçlar ($countConfirmed)'},
      {'id': 2, 'label': '📩 Başvurduğum Maçlar ($countApplied)'},
      {'id': 3, 'label': '⚽ Tüm Yaklaşanlar ($countUpcoming)'},
      {'id': 4, 'label': '📜 Geçmiş Maçlar ($countPast)'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Row(
        children: tabs.map((tab) {
          final tabId = tab['id'] as int;
          final isSelected = _selectedFilterTab == tabId;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(tab['label'] as String),
              selected: isSelected,
              selectedColor: AppTheme.primaryGreen,
              backgroundColor: AppTheme.cardDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryGreen : Colors.white12,
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : AppTheme.textLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
              onSelected: (_) => setState(() => _selectedFilterTab = tabId),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMatchList(
    List<MatchAd> matches,
    AppState appState,
    Set<String> myAcceptedMatchIds,
    Map<String, Application> myApplicationMap,
  ) {
    if (matches.isEmpty) {
      String emptyMessage;
      String actionLabel = 'İlan Oluştur';
      VoidCallback? onAction;

      switch (_selectedFilterTab) {
        case 0:
          emptyMessage = '${DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate)} tarihinde maç bulunamadı.';
          actionLabel = 'Bu Güne İlan Oluştur';
          onAction = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAdScreen()));
          break;
        case 1:
          emptyMessage = 'Onaylanmış kadroda yer aldığınız veya kaptanı olduğunuz yaklaşan maç yok.';
          actionLabel = 'Yeni Maçlara Göz At';
          onAction = () => setState(() => _selectedFilterTab = 3);
          break;
        case 2:
          emptyMessage = 'Henüz başvuru yaptığınız bir maç bulunmuyor.';
          actionLabel = 'Açık İlanları İncele';
          onAction = () => setState(() => _selectedFilterTab = 3);
          break;
        case 3:
          emptyMessage = 'Yaklaşan açık halısaha maçı bulunamadı.';
          actionLabel = 'İlk İlanı Sen Ver';
          onAction = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAdScreen()));
          break;
        case 4:
          emptyMessage = 'Henüz tamamlanmış geçmiş bir maç bulunmuyor.';
          actionLabel = '';
          onAction = null;
          break;
        default:
          emptyMessage = 'Listelenecek maç bulunamadı.';
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _selectedFilterTab == 4 ? Icons.history_toggle_off : Icons.event_busy,
                size: 50,
                color: AppTheme.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
              ),
              if (actionLabel.isNotEmpty && onAction != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.arrow_forward, color: AppTheme.primaryGreen, size: 16),
                  label: Text(actionLabel, style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final currentUserId = appState.currentUser?.id;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 80.0),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final isHost = currentUserId != null && match.hostId == currentUserId;
        final isAccepted = myAcceptedMatchIds.contains(match.id);
        final userApp = myApplicationMap[match.id];
        final isPast = match.dateTime.isBefore(DateTime.now().subtract(const Duration(hours: 3))) || match.status == MatchStatus.completed;

        final formattedDate = AppDateFormatter.formatDateWithDay(match.dateTime);
        final formattedTime = AppDateFormatter.formatTime(match.dateTime);

        // Time difference calculation
        final difference = match.dateTime.difference(DateTime.now());
        String countdownText = '';
        if (isPast) {
          countdownText = 'Tamamlandı 🏁';
        } else if (difference.inHours < 24) {
          countdownText = '${difference.inHours} sa ${difference.inMinutes % 60} dk kaldı';
        } else {
          countdownText = '${difference.inDays} gün kaldı';
        }

        // MVP name resolution if available
        String? mvpName;
        if (match.mvpUserId != null) {
          final mvpUser = appState.users.where((u) => u.id == match.mvpUserId).firstOrNull;
          mvpName = mvpUser?.name ?? 'Oyuncu';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MatchDetailsScreen(matchId: match.id)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Time, Weather & Custom Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPast
                                  ? Colors.white10
                                  : AppTheme.primaryGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isPast ? Colors.white24 : AppTheme.primaryGreen.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 13,
                                  color: isPast ? AppTheme.textMuted : AppTheme.primaryGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isPast ? AppTheme.textMuted : AppTheme.primaryGreen,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                            ),
                            child: Text(
                              match.weatherText,
                              style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),

                      // Contextual status pill
                      if (isHost)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: const Text('👑 Kaptansın', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11)),
                        )
                      else if (isAccepted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text('⚽ Kadrodasın', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                        )
                      else if (userApp != null && _selectedFilterTab == 2)
                        _buildApplicationStatusBadge(userApp.status)
                      else
                        Text(
                          match.isFree ? 'Ücretsiz' : '${match.price.toInt()} TL',
                          style: TextStyle(
                            color: match.isFree ? AppTheme.primaryGreen : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title & Location
                  Text(
                    match.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${match.district} - ${match.locationName}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),

                  // Past match score & MVP highlight
                  if (isPast && (match.finalScore != null || mvpName != null)) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (match.finalScore != null)
                            Row(
                              children: [
                                const Icon(Icons.sports_score, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  'Skor: ${match.finalScore}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 12),
                                ),
                              ],
                            ),
                          if (mvpName != null)
                            Row(
                              children: [
                                const Icon(Icons.emoji_events, size: 14, color: Colors.amberAccent),
                                const SizedBox(width: 4),
                                Text(
                                  'MVP: $mvpName',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent, fontSize: 11),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],

                  // Applied match info pill if viewing applications
                  if (_selectedFilterTab == 2 && userApp != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.send_outlined, size: 12, color: AppTheme.textMuted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Başvuru Notu: "${userApp.applicantBio}"',
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(height: 1, color: Colors.white10),
                  ),

                  // Footer: Countdown/Past & Quick Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPast ? Icons.check_circle_outline : Icons.hourglass_bottom,
                            size: 14,
                            color: isPast ? Colors.white38 : (difference.isNegative ? AppTheme.textMuted : Colors.amber),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            countdownText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isPast ? Colors.white38 : (difference.isNegative ? AppTheme.textMuted : Colors.amber),
                            ),
                          ),
                        ],
                      ),
                      if (!isPast)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            final reminderTimeStr = DateFormat('HH:mm').format(match.dateTime.subtract(const Duration(hours: 2)));
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: AppTheme.cardDark,
                                  title: const Row(
                                    children: [
                                      Icon(Icons.event_available, color: AppTheme.primaryGreen),
                                      SizedBox(width: 8),
                                      Text('Takvime Eklendi! 📅', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                  content: Text(
                                    '${match.title} maçı cihazınızın takvimine kaydedildi.\n\n🔔 Maç saatinden 2 saat önce ($reminderTimeStr) otomatik hatırlatma bildirimi gönderilecek.',
                                    style: const TextStyle(height: 1.4),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Tamam'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.edit_calendar, size: 14, color: AppTheme.primaryGreen),
                          label: const Text(
                            'Takvime Ekle',
                            style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MatchDetailsScreen(matchId: match.id)),
                            );
                          },
                          icon: const Icon(Icons.visibility, size: 14, color: AppTheme.primaryGreen),
                          label: const Text(
                            'Detayları Gör',
                            style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplicationStatusBadge(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber),
          ),
          child: const Text(
            '⏳ Onay Bekliyor',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        );
      case ApplicationStatus.accepted:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.greenAccent),
          ),
          child: const Text(
            '✅ Kadroya Alındın',
            style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        );
      case ApplicationStatus.rejected:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.redAccent),
          ),
          child: const Text(
            '❌ Onaylanmadı',
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        );
    }
  }
}
