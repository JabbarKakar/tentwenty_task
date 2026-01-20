import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';

/// Seat state: 0=regular available, 1=VIP available, 2=booked, 3=selected.
const int _regular = 0;
const int _vip = 1;
const int _booked = 2;
const int _selected = 3;

/// Dummy 10x14 layout. Rows 8,9 (0-based) are VIP. Some pre-booked.
List<List<int>> _initialSeatLayout() {
  const vipRow = 8; // rows 8 and 9 are VIP
  final rows = 10;
  final cols = 14;
  final grid = List.generate(rows, (i) {
    return List.generate(cols, (j) {
      if (i >= vipRow) return _vip;
      return _regular;
    });
  });
  // Pre-book some seats
  final booked = [
    [0, 2], [0, 5], [1, 1], [1, 6], [2, 3], [2, 10], [3, 0], [3, 7], [3, 13],
    [4, 4], [4, 9], [5, 2], [5, 11], [6, 6], [6, 8], [7, 1], [7, 12],
    [8, 5], [8, 9], [9, 3], [9, 10],
  ];
  for (final p in booked) {
    grid[p[0]][p[1]] = _booked;
  }
  return grid;
}

class SeatSelectionScreen extends StatefulWidget {
  final String movieTitle;
  final String dateSubtitle;
  final String time;
  final String hall;
  final int priceRegular;
  final int priceVip;

  const SeatSelectionScreen({
    super.key,
    required this.movieTitle,
    required this.dateSubtitle,
    required this.time,
    required this.hall,
    this.priceRegular = 50,
    this.priceVip = 150,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  late List<List<int>> _grid;
  static const _cRegular = Color(0xFF60C2FF);
  static const _cVip = Color(0xFF564CA3);
  static const _cBooked = Color(0xFFDBDBDF);
  static const _cSelected = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _grid = _initialSeatLayout();
  }

  String get _subtitle => '${widget.dateSubtitle} | ${widget.time} ${widget.hall}';

  List<({int r, int c})> get _selectedSeats {
    final l = <({int r, int c})>[];
    for (var i = 0; i < _grid.length; i++) {
      for (var j = 0; j < _grid[i].length; j++) {
        if (_grid[i][j] == _selected) l.add((r: i + 1, c: j + 1));
      }
    }
    return l;
  }

  int get _totalPrice {
    var t = 0;
    for (var i = 0; i < _grid.length; i++) {
      for (var j = 0; j < _grid[i].length; j++) {
        if (_grid[i][j] == _selected) {
          t += i >= 8 ? widget.priceVip : widget.priceRegular;
        }
      }
    }
    return t;
  }

  void _toggleSeat(int r, int c) {
    final v = _grid[r][c];
    if (v == _booked) return;
    setState(() {
      if (v == _selected) {
        _grid[r][c] = r >= 8 ? _vip : _regular;
      } else {
        _grid[r][c] = _selected;
      }
    });
  }

  void _removeSeat(int row, int col) {
    setState(() {
      final r = row - 1;
      final c = col - 1;
      if (r >= 0 && r < _grid.length && c >= 0 && c < _grid[r].length && _grid[r][c] == _selected) {
        _grid[r][c] = r >= 8 ? _vip : _regular;
      }
    });
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScreenCurve(),
                    const SizedBox(height: 8),
                    _buildSeatMap(),
                    const SizedBox(height: 16),
                    _buildLegend(),
                    const SizedBox(height: 12),
                    _buildSelectedChips(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
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
                Text(
                  _subtitle,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF60C2FF)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildScreenCurve() {
    return CustomPaint(
      size: const Size(double.infinity, 24),
      painter: _ScreenCurvePainter(),
      child: const Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              'SCREEN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E2739),
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildSeatMap() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRowLabels(),
        Expanded(
          child: InteractiveViewer(
            minScale: 0.7,
            maxScale: 2.0,
            child: _buildSeatGrid(),
          ),
        ),
        _buildZoomButtons(),
      ],
    );
  }

  Widget _buildRowLabels() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(10, (i) => _buildRowLabel(i + 1)),
      ),
    );
  }

  Widget _buildRowLabel(int n) {
    return SizedBox(
      height: 24,
      width: 24,
      child: Center(
        child: Text(
          '$n',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2E2739),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatGrid() {
    final rows = _grid.length;
    final cols = rows > 0 ? _grid[0].length : 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rows, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(cols, (j) {
              return _buildSeat(i, j);
            }),
          ),
        );
      }),
    );
  }

  Widget _buildSeat(int r, int c) {
    final v = _grid[r][c];
    Color color;
    switch (v) {
      case _regular:
        color = _cRegular;
        break;
      case _vip:
        color = _cVip;
        break;
      case _booked:
        color = _cBooked;
        break;
      default:
        color = _cSelected;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: () => _toggleSeat(r, c),
        child: AppAssets.svgWithColor(
          AppAssets.iconsSeat,
          color: color,
          width: 20,
          height: 20,
        ),
      ),
    );
  }

  Widget _buildZoomButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _zoomBtn(Icons.add),
          const SizedBox(height: 4),
          _zoomBtn(Icons.remove),
        ],
      ),
    );
  }

  Widget _zoomBtn(IconData icon) {
    return Material(
      color: const Color(0xFFDBDBDF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(width: 36, height: 36, child: Icon(icon, size: 20, color: const Color(0xFF2E2739))),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem(_cSelected, 'Selected'),
        _legendItem(_cBooked, 'Not available'),
        _legendItem(_cVip, 'VIP (${widget.priceVip}\$)'),
        _legendItem(_cRegular, 'Regular (${widget.priceRegular}\$)'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppAssets.svgWithColor(AppAssets.iconsSeat, color: color, width: 16, height: 16),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF2E2739))),
      ],
    );
  }

  Widget _buildSelectedChips() {
    final list = _selectedSeats;
    if (list.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: list.map((s) {
        return Chip(
          label: Text('${s.c} / ${s.r} row', style: const TextStyle(fontSize: 12)),
          deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xFF2E2739)),
          onDeleted: () => _removeSeat(s.r, s.c),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFDBDBDF)),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(fontSize: 14, color: Color(0xFF2E2739)),
              ),
              Text(
                '\$ $_totalPrice',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E2739),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedSeats.isEmpty
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Proceed to pay — booking is static/dummy')),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF60C2FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Proceed to pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width / 2, 0, size.width, size.height * 0.6);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF60C2FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
