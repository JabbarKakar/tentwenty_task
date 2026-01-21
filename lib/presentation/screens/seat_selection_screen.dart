import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

// --- Pixel-perfect dimensions from spec ---
const double _shortW = 14;
const double _normalW = 20;
const double _seatH = 16;
const double _gapH = 8;
const double _gapV = 14;
const double _aisleW = 24;

// --- Colors (from AppColors) ---
const Color _cAvail = AppColors.accentBlue;
const Color _cUnavail = AppColors.borderLight;
const Color _cSelected = AppColors.accentGold;
const Color _cPremium = AppColors.accentPurple;

// --- State: 0=available, 1=unavailable, 2=selected, 3=premium, null=empty slot ---

/// 10 rows x 28 columns. Cols 0-4=Block1(5 short), 5-22=Block2(18), 23-27=Block3(5).
List<List<int?>> _initialSeatLayout() {
  final g = List.generate(10, (_) => List<int?>.filled(28, 0));

  // Row 1 — left 5, center 18, right 5
  g[0][0] = null;
  g[0][1] = null;
  g[0][2] = 1;
  g[0][3] = 1;
  g[0][4] = 1;
  for (int i = 0; i < 4; i++) { g[0][5 + i] = 1; }
  for (int i = 0; i < 2; i++) { g[0][9 + i] = 0; }
  for (int i = 0; i < 12; i++) { g[0][11 + i] = 1; }
  g[0][23] = 1;
  g[0][24] = 1;
  g[0][25] = null;
  g[0][26] = null;
  g[0][27] = null;

  // Row 2
  for (int i = 0; i < 5; i++) { g[1][i] = 0; }
  for (int i = 0; i < 4; i++) { g[1][5 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[1][9 + i] = 0; }
  for (int i = 0; i < 4; i++) { g[1][13 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[1][17 + i] = 0; }
  for (int i = 0; i < 2; i++) { g[1][21 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[1][23 + i] = 0; }
  g[1][27] = null;

  // Row 3 (one selected at B2 5th = index 9)
  for (int i = 0; i < 5; i++) { g[2][i] = 0; }
  for (int i = 0; i < 4; i++) { g[2][5 + i] = 1; }
  g[2][9] = 2;
  g[2][10] = 1;
  for (int i = 0; i < 4; i++) { g[2][11 + i] = 0; }
  for (int i = 0; i < 2; i++) { g[2][15 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[2][17 + i] = 0; }
  for (int i = 0; i < 2; i++) { g[2][21 + i] = 1; }
  g[2][23] = 0;
  g[2][24] = 0;
  g[2][25] = 1;
  g[2][26] = 1;
  g[2][27] = 0;

  // Row 4
  for (int i = 0; i < 5; i++) { g[3][i] = 1; }
  for (int i = 0; i < 4; i++) { g[3][5 + i] = 0; }
  for (int i = 0; i < 4; i++) { g[3][9 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[3][13 + i] = 0; }
  for (int i = 0; i < 4; i++) { g[3][17 + i] = 1; }
  for (int i = 0; i < 2; i++) { g[3][21 + i] = 0; }
  for (int i = 0; i < 5; i++) { g[3][23 + i] = 1; }

  // Row 5
  for (int i = 0; i < 5; i++) { g[4][i] = 0; }
  for (int i = 0; i < 4; i++) { g[4][5 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[4][9 + i] = 0; }
  for (int i = 0; i < 4; i++) { g[4][13 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[4][17 + i] = 0; }
  for (int i = 0; i < 2; i++) { g[4][21 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[4][23 + i] = 0; }
  g[4][27] = 1;

  // Row 6
  for (int i = 0; i < 5; i++) { g[5][i] = 1; }
  for (int i = 0; i < 4; i++) { g[5][5 + i] = 0; }
  for (int i = 0; i < 4; i++) { g[5][9 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[5][13 + i] = 0; }
  for (int i = 0; i < 4; i++) { g[5][17 + i] = 1; }
  for (int i = 0; i < 2; i++) { g[5][21 + i] = 0; }
  for (int i = 0; i < 5; i++) { g[5][23 + i] = 1; }

  // Row 7
  for (int i = 0; i < 5; i++) { g[6][i] = 0; }
  for (int i = 0; i < 4; i++) { g[6][5 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[6][9 + i] = 0; }
  for (int i = 0; i < 4; i++) { g[6][13 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[6][17 + i] = 0; }
  for (int i = 0; i < 2; i++) { g[6][21 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[6][23 + i] = 0; }
  g[6][27] = 1;

  // Row 8
  for (int i = 0; i < 5; i++) { g[7][i] = 1; }
  for (int i = 0; i < 4; i++) { g[7][5 + i] = 0; }
  for (int i = 0; i < 4; i++) { g[7][9 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[7][13 + i] = 0; }
  for (int i = 0; i < 4; i++) { g[7][17 + i] = 1; }
  for (int i = 0; i < 2; i++) { g[7][21 + i] = 0; }
  for (int i = 0; i < 5; i++) { g[7][23 + i] = 1; }

  // Row 9
  for (int i = 0; i < 5; i++) { g[8][i] = 0; }
  for (int i = 0; i < 4; i++) { g[8][5 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[8][9 + i] = 0; }
  for (int i = 0; i < 4; i++) { g[8][13 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[8][17 + i] = 0; }
  for (int i = 0; i < 2; i++) { g[8][21 + i] = 1; }
  for (int i = 0; i < 4; i++) { g[8][23 + i] = 0; }
  g[8][27] = 1;

  // Row 10: all premium
  for (int c = 0; c < 28; c++) { g[9][c] = 3; }

  return g;
}

const double _rowHeight = _seatH + _gapV;

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
  late List<List<int?>> _grid;
  final TransformationController _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _grid = _initialSeatLayout();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final m = _transformController.value;
    final s = m.getMaxScaleOnAxis();
    final newS = (s * 1.25).clamp(0.5, 3.0);
    if ((newS - s).abs() < 0.01) return;
    final f = newS / s;
    _transformController.value = m.clone()..scaleByDouble(f, f, 1, 1);
  }

  void _zoomOut() {
    final m = _transformController.value;
    final s = m.getMaxScaleOnAxis();
    final newS = (s / 1.25).clamp(0.5, 3.0);
    if ((newS - s).abs() < 0.01) return;
    final f = newS / s;
    _transformController.value = m.clone()..scaleByDouble(f, f, 1, 1);
  }

  String get _subtitle => '${widget.dateSubtitle} | ${widget.time} ${widget.hall}';

  List<({int r, int c})> get _selectedSeats {
    final l = <({int r, int c})>[];
    for (var r = 0; r < 10; r++) {
      for (var c = 0; c < 28; c++) {
        if (_grid[r][c] == 2) l.add((r: r, c: c));
      }
    }
    return l;
  }

  int get _totalPrice {
    var t = 0;
    for (final s in _selectedSeats) {
      t += s.r == 9 ? widget.priceVip : widget.priceRegular;
    }
    return t;
  }

  void _toggle(int r, int c) {
    final v = _grid[r][c];
    if (v == 1) return;
    setState(() {
      _grid[r][c] = (v == 2) ? (r == 9 ? 3 : 0) : 2;
    });
  }

  void _removeSeat(int r, int c) {
    if (_grid[r][c] != 2) return;
    setState(() => _grid[r][c] = r == 9 ? 3 : 0);
  }

  Color _color(int? v) {
    switch (v) {
      case 0:
        return _cAvail;
      case 1:
        return _cUnavail;
      case 2:
        return _cSelected;
      case 3:
        return _cPremium;
      default:
        return _cUnavail;
    }
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.borderLight.withOpacity(.3),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildScreenCurve(),
                          const SizedBox(height: 8),
                          _buildSeatMap(),
                        ],
                      ),
                    ),
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
                Text(
                  _subtitle,
                  style: const TextStyle(fontSize: 14, color: AppColors.accentBlue),
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
          padding: EdgeInsets.only(bottom: 20, top: 30),
          child: Text(
            'SCREEN',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatMap() {
    return SizedBox(
      height: 320,
      child: Column(
        children: [
          Expanded(
            child: ClipRect(
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 0.5,
                maxScale: 3.0,
                clipBehavior: Clip.hardEdge,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRowLabels(),
                      _buildSeatGrid(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: _buildZoomButtons()),
        ],
      ),
    );
  }

  Widget _buildZoomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _zoomBtn(Icons.add, onTap: _zoomIn),
        const SizedBox(width: 8),
        _zoomBtn(Icons.remove, onTap: _zoomOut),
      ],
    );
  }

  Widget _zoomBtn(IconData icon, {VoidCallback? onTap}) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight), shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: AppColors.primaryDark),
        ),
      ),
    );
  }

  Widget _buildRowLabels() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(10, (i) => _buildRowLabel(i + 1)),
      ),
    );
  }

  Widget _buildRowLabel(int n) {
    // Rows 1–9: seat (16) + gap (14) = 30; row 10: seat only (16)
    final h = n == 10 ? _seatH : _rowHeight;
    return SizedBox(
      height: h,
      width: 24,
      child: Center(
        child: Text(
          '$n',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }

  Widget _buildSeatGrid() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(10, (r) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _seatH,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBlock(r, 0, 5, _shortW),
                  SizedBox(width: _aisleW, height: _seatH),
                  _buildBlock(r, 5, 18, _normalW),
                  SizedBox(width: _aisleW, height: _seatH),
                  _buildBlock(r, 23, 5, _normalW),
                ],
              ),
            ),
            if (r < 9) SizedBox(height: _gapV),
          ],
        );
      }),
    );
  }

  Widget _buildBlock(int r, int start, int count, double w) {
    final children = <Widget>[];
    for (int i = 0; i < count; i++) {
      final c = start + i;
      children.add(_buildSeat(r, c, w));
      if (i < count - 1) children.add(SizedBox(width: _gapH, height: _seatH));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildSeat(int r, int c, double w) {
    final v = _grid[r][c];
    if (v == null) {
      return SizedBox(width: w, height: _seatH);
    }
    return GestureDetector(
      onTap: () => _toggle(r, c),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: w,
        height: _seatH,
        child: Center(
          child: AppAssets.svgWithColor(
            AppAssets.iconsSeat,
            color: _color(v),
            width: w,
            height: _seatH,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _legendItem(_cSelected, 'Selected'),
          _legendItem(_cPremium, 'VIP (${widget.priceVip}\$)'),
          _legendItem(_cUnavail, 'Not available'),
          _legendItem(_cAvail, 'Regular (${widget.priceRegular} \$)'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppAssets.svgWithColor(
          AppAssets.iconsSeat,
          color: color,
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
        ),
      ],
    );
  }

  Widget _buildSelectedChips() {
    final list = _selectedSeats;
    if (list.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 2,
        children: list.map((s) {
          return Chip(
            label: Text(
              '${s.c + 1} / ${s.r + 1} row',
              style: const TextStyle(fontSize: 10),
            ),
            deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.primaryDark),
            onDeleted: () => _removeSeat(s.r, s.c),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
            backgroundColor: AppColors.borderLight,
            side: const BorderSide(color: AppColors.borderLight),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 105,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Total Price',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.primaryDark),
                ),
                Text(
                  '\$ $_totalPrice',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
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
                          const SnackBar(
                            content: Text('Proceed to pay — booking is static/dummy'),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Proceed to pay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
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
        ..color = AppColors.accentBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
