import 'package:flutter/material.dart';

class RecordingIndicator extends StatefulWidget {
  final bool isRecording;

  const RecordingIndicator({
    Key? key,
    required this.isRecording,
  }) : super(key: key);

  @override
  State<RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Create 3 waves with different delays
    for (int i = 0; i < 3; i++) {
      _animations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(i * 0.2, 1.0, curve: Curves.easeOut),
          ),
        ),
      );
    }
  }

  @override
  void didUpdateWidget(RecordingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRecording) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_none, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Press and hold to record'),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ..._animations.map((animation) {
                return CustomPaint(
                  painter: WavePainter(
                    animation.value,
                    color: Colors.red.withOpacity(0.5),
                  ),
                  child: const SizedBox(
                    width: 100,
                    height: 100,
                  ),
                );
              }).toList(),
              const Icon(
                Icons.mic,
                color: Colors.red,
                size: 32,
              ),
            ],
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  WavePainter(this.progress, {required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * progress;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}