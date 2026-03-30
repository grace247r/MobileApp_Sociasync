import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class GeneratorLoadingWidget extends StatefulWidget {
  const GeneratorLoadingWidget({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<GeneratorLoadingWidget> createState() => _GeneratorLoadingWidgetState();
}

class _GeneratorLoadingWidgetState extends State<GeneratorLoadingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 16;
    const double barRadius = 16;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;
        final double safeWidth = maxWidth.isFinite ? maxWidth : 320;
        final double safeHeight = maxHeight.isFinite ? maxHeight : 360;
        final double barWidth = safeWidth * 0.72;

        return Stack(
          children: [
            const Center(child: CupertinoActivityIndicator(radius: 14)),
            Positioned(
              bottom: safeHeight * 0.18,
              left: (safeWidth - barWidth) / 2,
              child: SizedBox(
                width: barWidth,
                height: barHeight,
                child: Stack(
                  children: [
                    Container(
                      width: barWidth,
                      height: barHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(barRadius),
                        border: Border.all(
                          color: const Color(0xFF1A3EC8),
                          width: 1.5,
                        ),
                        color: Colors.white,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, _) {
                        return Container(
                          width: barWidth * _progressAnimation.value,
                          height: barHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(barRadius),
                            color: const Color(0xFF1A3EC8),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: (safeHeight * 0.18) - 28,
              left: (safeWidth - barWidth) / 2,
              child: SizedBox(
                width: barWidth,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, _) {
                      final int percent = (_progressAnimation.value * 100)
                          .clamp(0, 100)
                          .toInt();
                      return Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D5093),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
