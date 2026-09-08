import 'package:flutter/material.dart';

class PulsingPlaceholder extends StatefulWidget {
  const PulsingPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.shape = BoxShape.rectangle,
  });

  final double width;
  final double height;
  final BoxShape shape;

  @override
  State<PulsingPlaceholder> createState() => _PulsingPlaceholderState();
}

class _PulsingPlaceholderState extends State<PulsingPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(Tween(begin: 0.4, end: 1.0)),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.rectangle
              ? BorderRadius.circular(4)
              : null,
        ),
      ),
    );
  }
}
