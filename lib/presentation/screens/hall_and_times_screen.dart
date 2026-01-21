import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import 'seat_selection_screen.dart';

/// Dummy screening: time, cinema, hall, price, bonus.
/// miniMap: 10x28, same layout as seat_selection_screen. 0=blue, 1=VIP, 2=booked, 3=teal, 4=pink, null=empty.
class _Screening {
  final String time;
  final String cinema;
  final String hall;
  final int price;
  final int bonus;
  final List<List<int?>> miniMap;

  _Screening({
    required this.time,
    required this.cinema,
    required this.hall,
    required this.price,
    required this.bonus,
    required this.miniMap,
  });
}

/// 10x28 layout matching seat_selection_screen. Values: 0=avail, 1=unavail, 2=selected, 3=VIP, null=empty.
List<List<int?>> _fullSeatLayout() {
  final g = List.generate(10, (_) => List<int?>.filled(28, 0));
  g[0][0] = null; g[0][1] = null; g[0][2] = 1; g[0][3] = 1; g[0][4] = 1;
  for (int i = 0; i < 4; i++) g[0][5 + i] = 1;
  for (int i = 0; i < 2; i++) g[0][9 + i] = 0;
  for (int i = 0; i < 12; i++) g[0][11 + i] = 1;
  g[0][23] = 1; g[0][24] = 1; g[0][25] = null; g[0][26] = null; g[0][27] = null;
  for (int i = 0; i < 5; i++) g[1][i] = 0;
  for (int i = 0; i < 4; i++) g[1][5 + i] = 1;
  for (int i = 0; i < 4; i++) g[1][9 + i] = 0;
  for (int i = 0; i < 4; i++) g[1][13 + i] = 1;
  for (int i = 0; i < 4; i++) g[1][17 + i] = 0;
  for (int i = 0; i < 2; i++) g[1][21 + i] = 1;
  for (int i = 0; i < 4; i++) g[1][23 + i] = 0;
  g[1][27] = null;
  for (int i = 0; i < 5; i++) g[2][i] = 0;
  for (int i = 0; i < 4; i++) g[2][5 + i] = 1;
  g[2][9] = 2; g[2][10] = 1;
  for (int i = 0; i < 4; i++) g[2][11 + i] = 0;
  for (int i = 0; i < 2; i++) g[2][15 + i] = 1;
  for (int i = 0; i < 4; i++) g[2][17 + i] = 0;
  for (int i = 0; i < 2; i++) g[2][21 + i] = 1;
  g[2][23] = 0; g[2][24] = 0; g[2][25] = 1; g[2][26] = 1; g[2][27] = 0;
  for (int i = 0; i < 5; i++) g[3][i] = 1;
  for (int i = 0; i < 4; i++) { g[3][5 + i] = 0; g[3][9 + i] = 1; g[3][13 + i] = 0; g[3][17 + i] = 1; }
  for (int i = 0; i < 2; i++) g[3][21 + i] = 0;
  for (int i = 0; i < 5; i++) g[3][23 + i] = 1;
  for (int i = 0; i < 5; i++) g[4][i] = 0;
  for (int i = 0; i < 4; i++) { g[4][5 + i] = 1; g[4][9 + i] = 0; g[4][13 + i] = 1; g[4][17 + i] = 0; }
  for (int i = 0; i < 2; i++) g[4][21 + i] = 1;
  for (int i = 0; i < 4; i++) g[4][23 + i] = 0;
  g[4][27] = 1;
  for (int i = 0; i < 5; i++) g[5][i] = 1;
  for (int i = 0; i < 4; i++) { g[5][5 + i] = 0; g[5][9 + i] = 1; g[5][13 + i] = 0; g[5][17 + i] = 1; }
  for (int i = 0; i < 2; i++) g[5][21 + i] = 0;
  for (int i = 0; i < 5; i++) g[5][23 + i] = 1;
  for (int i = 0; i < 5; i++) g[6][i] = 0;
  for (int i = 0; i < 4; i++) { g[6][5 + i] = 1; g[6][9 + i] = 0; g[6][13 + i] = 1; g[6][17 + i] = 0; }
  for (int i = 0; i < 2; i++) g[6][21 + i] = 1;
  for (int i = 0; i < 4; i++) g[6][23 + i] = 0;
  g[6][27] = 1;
  for (int i = 0; i < 5; i++) g[7][i] = 1;
  for (int i = 0; i < 4; i++) { g[7][5 + i] = 0; g[7][9 + i] = 1; g[7][13 + i] = 0; g[7][17 + i] = 1; }
  for (int i = 0; i < 2; i++) g[7][21 + i] = 0;
  for (int i = 0; i < 5; i++) g[7][23 + i] = 1;
  for (int i = 0; i < 5; i++) g[8][i] = 0;
  for (int i = 0; i < 4; i++) { g[8][5 + i] = 1; g[8][9 + i] = 0; g[8][13 + i] = 1; g[8][17 + i] = 0; }
  for (int i = 0; i < 2; i++) g[8][21 + i] = 1;
  for (int i = 0; i < 4; i++) g[8][23 + i] = 0;
  g[8][27] = 1;
  for (int c = 0; c < 28; c++) g[9][c] = 3;
  return g;
}

/// Maps full layout (0,1,2,3,null) to mini: 0=blue, 1=VIP, 2=booked, 3=teal, 4=pink, null=empty.
List<List<int?>> _toMiniGrid(List<List<int?>> full) {
  final m = List.generate(10, (r) => List<int?>.generate(28, (c) {
    final v = full[r][c];
    if (v == null) return null;
    if (v == 3) return 1; // VIP (purple)
    if (v == 1 || v == 2) return 2; // booked (light gray)
    // available: mix of blue, teal, pink per screenshot
    final k = (r * 28 + c) % 5;
    return k == 0 ? 3 : (k == 1 ? 4 : 0);
  }));
  return m;
}

List<List<int?>> _getMiniLayout() => _toMiniGrid(_fullSeatLayout());

/// Dummy data: dates and per-date screenings.
void _fillDummy(Map<int, List<_Screening>> m) {
  final mini = _getMiniLayout();
  m[0] = [
    _Screening(time: '12:30', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: mini),
    _Screening(time: '13:30', cinema: 'Cinetech', hall: 'Hall 2', price: 75, bonus: 3000, miniMap: mini),
    _Screening(time: '15:00', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: mini),
    _Screening(time: '18:00', cinema: 'Cinetech', hall: 'Hall 3', price: 60, bonus: 2800, miniMap: mini),
  ];
  m[1] = [
    _Screening(time: '10:00', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: mini),
    _Screening(time: '14:00', cinema: 'Cinetech', hall: 'Hall 3', price: 60, bonus: 2800, miniMap: mini),
    _Screening(time: '17:30', cinema: 'Cinetech', hall: 'Hall 2', price: 75, bonus: 3000, miniMap: mini),
  ];
  m[2] = [
    _Screening(time: '11:00', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: mini),
    _Screening(time: '14:30', cinema: 'Cinetech', hall: 'Hall 2', price: 75, bonus: 3000, miniMap: mini),
  ];
  m[3] = [
    _Screening(time: '12:00', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: mini),
    _Screening(time: '15:30', cinema: 'Cinetech', hall: 'Hall 3', price: 60, bonus: 2800, miniMap: mini),
    _Screening(time: '19:00', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: mini),
  ];
  m[4] = [
    _Screening(time: '13:00', cinema: 'Cinetech', hall: 'Hall 2', price: 75, bonus: 3000, miniMap: mini),
    _Screening(time: '16:00', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: mini),
  ];
  m[5] = [
    _Screening(time: '10:30', cinema: 'Cinetech', hall: 'Hall 1', price: 50, bonus: 2500, miniMap: mini),
    _Screening(time: '12:30', cinema: 'Cinetech', hall: 'Hall 3', price: 60, bonus: 2800, miniMap: mini),
    _Screening(time: '18:30', cinema: 'Cinetech', hall: 'Hall 2', price: 75, bonus: 3000, miniMap: mini),
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
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                color: AppColors.borderLight.withOpacity(0.3),
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildDateChips(),
                            const SizedBox(height: 24),
                            _buildHallTimeCards(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    _buildSelectSeatsButton(),
                  ],
                ),
              ),
            ),
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
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryDark, size: 20),
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
                    color: AppColors.primaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                const Text(
                  'In Theaters December 22, 2021',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.accentBlue,
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
      height: 38,
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentBlue : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.accentBlue : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _dates[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.primaryDark,
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
          child: Text('No screenings for this date', style: TextStyle(color: AppColors.primaryDark))),
        );
    }
    return SizedBox(
      height: 230,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: AppColors.primaryDark),
                      children: [
                        TextSpan(
                          text: '${s.time} ',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: '${s.cinema} + ${s.hall}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 250,
                    height: 172,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.accentBlue : AppColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: .center,
                      children: [
                        Expanded(
                          child: Center(child: Align(
                              alignment: .center,
                              child: _buildMiniSeatMap(s.miniMap))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w500),
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
          );
        },
      ),
    );
  }

  Widget _buildMiniSeatMap(List<List<int?>> grid) {
    const cRegular = AppColors.accentBlue;
    const cVip = AppColors.accentPurple;
    const cBooked = AppColors.borderLight;
    const int rows = 10;
    const int cols = 28;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 15,
              width: double.infinity,
              child: CustomPaint(painter: _MiniScreenArcPainter()),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final cellSize = (c.maxWidth / cols) < (c.maxHeight / rows)
                      ? c.maxWidth / cols
                      : c.maxHeight / rows;
                  final seatSize = cellSize * 0.88;
                  return Center(
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: .center,
                      children: List.generate(rows, (i) => Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: .center,
                        children: List.generate(cols, (j) {
                          final v = i < grid.length && j < grid[i].length ? grid[i][j] : null;
                          if (v == null) {
                            return SizedBox(width: cellSize, height: cellSize);
                          }
                          Color color;
                          switch (v) {
                            case 0: color = cRegular; break;
                            case 1: color = cVip; break;
                            case 2: color = cBooked; break;
                            case 3: color = AppColors.accentTeal; break;
                            case 4: color = AppColors.accentPink; break;
                            default: color = cBooked;
                          }
                          return SizedBox(
                            width: cellSize,
                            height: cellSize,
                            child: Center(
                              child: AppAssets.svgWithColor(
                                AppAssets.iconsSeat,
                                color: color,
                                width: seatSize,
                                height: seatSize,
                              ),
                            ),
                          );
                        }),
                      )),
                    ),
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
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _currentScreenings.isEmpty ? null : _onSelectSeats,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
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
    const cRegular = AppColors.accentBlue;
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

