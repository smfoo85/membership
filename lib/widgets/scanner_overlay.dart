import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A corner-bracket viewfinder frame drawn over the live camera preview,
/// styled after the design system's "Optical Targeting Reticle".
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 280,
          height: 176,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              _corner(alignment: Alignment.topLeft),
              _corner(alignment: Alignment.topRight),
              _corner(alignment: Alignment.bottomLeft),
              _corner(alignment: Alignment.bottomRight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _corner({required Alignment alignment}) {
    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: 28,
          height: 28,
          child: CustomPaint(
            painter: _CornerBracketPainter(isTop: isTop, isLeft: isLeft),
          ),
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  _CornerBracketPainter({required this.isTop, required this.isLeft});

  final bool isTop;
  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final y = isTop ? 0.0 : size.height;
    final x = isLeft ? 0.0 : size.width;

    canvas.drawLine(Offset(x, y), Offset(isLeft ? size.width : 0, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, isTop ? size.height : 0), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) => false;
}
