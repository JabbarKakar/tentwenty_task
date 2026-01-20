import 'package:flutter/material.dart';

/// Elegant loading widget with smooth animations
class LoadingWidget extends StatefulWidget {
  final Color? color;
  final double? size;
  final String? message;
  final bool isFullScreen;

  const LoadingWidget({
    super.key,
    this.color,
    this.size,
    this.message,
    this.isFullScreen = false,
  });

  /// Full screen loading widget
  const LoadingWidget.fullScreen({
    super.key,
    this.color,
    this.message,
  })  : size = null,
        isFullScreen = true;

  /// Small inline loading widget
  const LoadingWidget.small({
    super.key,
    this.color,
  })  : size = 24,
        message = null,
        isFullScreen = false;

  /// Medium loading widget
  const LoadingWidget.medium({
    super.key,
    this.color,
    this.message,
  })  : size = 48,
        isFullScreen = false;

  /// Large loading widget
  const LoadingWidget.large({
    super.key,
    this.color,
    this.message,
  })  : size = 64,
        isFullScreen = false;

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? 48.0;
    final color = widget.color ?? Theme.of(context).primaryColor;

    final loadingIndicator = AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: _ElegantLoadingPainter(
            progress: _animation.value,
            color: color,
          ),
        );
      },
    );

    if (widget.isFullScreen) {
      return Container(
        color: const Color(0xFFF6F6FA).withOpacity(0.9),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              loadingIndicator,
              if (widget.message != null) ...[
                const SizedBox(height: 24),
                Text(
                  widget.message!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (widget.message != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          loadingIndicator,
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF000000),
            ),
          ),
        ],
      );
    }

    return loadingIndicator;
  }
}

/// Custom painter for elegant loading animation
class _ElegantLoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ElegantLoadingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw animated arcs
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // First arc (rotating)
    final startAngle1 = (progress * 2 * 3.14159) - 3.14159 / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle1,
      2.0,
      false,
      paint..color = color.withOpacity(0.8),
    );

    // Second arc (rotating with offset)
    final startAngle2 = (progress * 2 * 3.14159 + 1.0) - 3.14159 / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle2,
      1.5,
      false,
      paint..color = color.withOpacity(0.6),
    );

    // Third arc (rotating with more offset)
    final startAngle3 = (progress * 2 * 3.14159 + 2.0) - 3.14159 / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle3,
      1.0,
      false,
      paint..color = color.withOpacity(0.4),
    );
  }

  @override
  bool shouldRepaint(_ElegantLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Loading overlay widget for showing loading on top of content
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ??
                const Color(0xFFF6F6FA).withOpacity(0.9),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingWidget.medium(
                    color: Color(0xFF2E2739),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
