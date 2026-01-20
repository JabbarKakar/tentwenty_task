import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import 'seat_selection_screen.dart';

/// Dummy screening: time, cinema, hall, price, bonus.
/// miniMap: 0=regular, 1=VIP, 2=booked (for small preview)
class _Screening {
  final String time;
  final String cinema;
  final String hall;
  final int price;
  final int bonus;
  final List<List<int>> miniMap;

  _Screening({
    required this.time,
    required this.cinema,
    required this.hall,
    required this.price,
    required this.bonus,
    required this.miniMap,
  });
}

/// Dummy data: dates and per-date screenings.
void _fillDummy(Map<int, List<_Screening>> m) {
  const miniRegular = [
    [0, 0, 1, 2, 0, 2, 0, 0],
    [0, 2, 0, 0, 2, 0, 1, 0],
    [2, 0, 0, 1, 0, 0, 2, 0],
    [0, 0, 2, 0, 0, 1, 0, 0],
  ];
  const miniAlt = [
    [0, 2, 0, 1, 0, 0, 2, 0],
    [1, 0, 0, 2, 0, 1, 0, 0],
    [0, 0, 1, 0, 2, 0, 0, 1],
    [2, 0, 0, 0, 1, 0, 2, 0],
  ];
  m[0] = [
    _Screening(time: '12:30', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: miniRegular),
    _Screening(time: '13:30', cinema: 'Cinetech', hall: 'Hall 2', price: 75, bonus: 3000, miniMap: miniAlt),
    _Screening(time: '15:00', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: miniRegular),
    _Screening(time: '18:00', cinema: 'Cinetech', hall: 'Hall 3', price: 60, bonus: 2800, miniMap: miniAlt),
  ];
  m[1] = [
    _Screening(time: '10:00', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: miniRegular),
    _Screening(time: '14:00', cinema: 'Cinetech', hall: 'Hall 3', price: 60, bonus: 2800, miniMap: miniAlt),
    _Screening(time: '17:30', cinema: 'Cinetech', hall: 'Hall 2', price: 75, bonus: 3000, miniMap: miniRegular),
  ];
  m[2] = [
    _Screening(time: '11:00', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: miniAlt),
    _Screening(time: '14:30', cinema: 'Cinetech', hall: 'Hall 2', price: 75, bonus: 3000, miniMap: miniRegular),
  ];
  m[3] = [
    _Screening(time: '12:00', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: miniRegular),
    _Screening(time: '15:30', cinema: 'Cinetech', hall: 'Hall 3', price: 60, bonus: 2800, miniMap: miniAlt),
    _Screening(time: '19:00', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: miniRegular),
  ];
  m[4] = [
    _Screening(time: '13:00', cinema: 'Cinetech', hall: 'Hall 2', price: 75, bonus: 3000, miniMap: miniAlt),
    _Screening(time: '16:00', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: miniRegular),
  ];
  m[5] = [
    _Screening(time: '10:30', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: miniRegular),
    _Screening(time: '12:30', cinema: 'Cinetech', hall: 'Hall 3', price: 60, bonus: 2800, miniMap: miniAlt),
    _Screening(time: '18:30', cinema: 'Cinetech', hall: 'Hall 2', price: 75, bonus: 3000, miniMap: miniRegular),
  ];
}

class HallAndTimesScreen extends StatefulWidget {
  final String movieTitle;

  const HallAndTimesScreen({
    super.key,
    required this.movieTitle,
  });

  @override
  State<HallAndTimesScreen> createState() => _HallAndTimesScreenState();
}

class _HallAndTimesScreenState extends State<HallAndTimesScreen> {
  static const _dates = ['5 Mar', '6 Mar', '7 Mar', '8 Mar', '9 Mar', '10 Mar'];
  static const _datesLong = ['March 5, 2021', 'March 6, 2021', 'March 7, 2021', 'March 8, 2021', 'March 9, 2021', 'March 10, 2021'];
  static final _screeningsByDate = <int, List<_Screening>>{};

  int _selectedDateIndex = 0;
  int _selectedScreeningIndex = 0;

  List<_Screening> get _currentScreenings =>
      _screeningsByDate[_selectedDateIndex] ?? [];

  @override
  void initState() {
    super.initState();
    _fillDummy(_screeningsByDate);
  }

  void _onSelectSeats() {
    final list = _currentScreenings;
    if (list.isEmpty) return;
    final s = list[_selectedScreeningIndex];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SeatSelectionScreen(
          movieTitle: widget.movieTitle,
          dateSubtitle: _datesLong[_selectedDateIndex],
          time: s.time,
          hall: s.hall,
          priceRegular: 50,
          priceVip: 150,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2E2739),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDateChips(),
                    const SizedBox(height: 24),
                    const Text(
                      'Hall & Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2E2739),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildHallTimeCards(),
                  ],
                ),
              ),
            ),
            _buildSelectSeatsButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2E2739), size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.movieTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2739),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                const Text(
                  'In Theaters December 22, 2021',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF60C2FF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildDateChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        itemBuilder: (context, i) {
          final isSelected = i == _selectedDateIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDateIndex = i;
                  final list = _screeningsByDate[i] ?? [];
                  _selectedScreeningIndex = list.isEmpty ? 0 : 0;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF60C2FF) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF60C2FF) : const Color(0xFFDBDBDF),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _dates[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF2E2739),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHallTimeCards() {
    final list = _currentScreenings;
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No screenings for this date', style: TextStyle(color: Color(0xFF2E2739))),
        ),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, i) {
          final s = list[i];
          final isSelected = i == _selectedScreeningIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => setState(() => _selectedScreeningIndex = i),
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF60C2FF) : const Color(0xFFDBDBDF),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${s.time} ${s.cinema} + ${s.hall}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E2739),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _buildMiniSeatMap(s.miniMap),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Color(0xFF2E2739), fontWeight: FontWeight.w500),
                        children: [
                          const TextSpan(text: 'From '),
                          TextSpan(text: '${s.price}\$', style: const TextStyle(fontWeight: FontWeight.w700)),
                          const TextSpan(text: ' or '),
                          TextSpan(text: '${s.bonus} bonus', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniSeatMap(List<List<int>> grid) {
    const cRegular = Color(0xFF60C2FF);
    const cVip = Color(0xFF564CA3);
    const cBooked = Color(0xFFDBDBDF);
    final rows = grid.length;
    final cols = rows > 0 ? grid[0].length : 0;
    if (rows == 0 || cols == 0) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: const Color(0xFFF6F6FA),
        child: Column(
          children: [
            SizedBox(
              height: 6,
              width: double.infinity,
              child: CustomPaint(painter: _MiniScreenArcPainter()),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final cellW = c.maxWidth / cols;
                  final cellH = c.maxHeight / rows;
                  final seatSize = (cellW < cellH ? cellW : cellH) * 0.85;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(rows, (i) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(cols, (j) {
                        Color color;
                        switch (grid[i][j]) {
                          case 0: color = cRegular; break;
                          case 1: color = cVip; break;
                          default: color = cBooked;
                        }
                        return Padding(
                          padding: const EdgeInsets.all(1),
                          child: AppAssets.svgWithColor(
                            AppAssets.iconsSeat,
                            color: color,
                            width: seatSize,
                            height: seatSize,
                          ),
                        );
                      }),
                    )),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectSeatsButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _currentScreenings.isEmpty ? null : _onSelectSeats,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF60C2FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('Select Seats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _MiniScreenArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cRegular = Color(0xFF60C2FF);
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width / 2, 0, size.width, size.height);
    canvas.drawPath(
      path,
      Paint()
        ..color = cRegular
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

