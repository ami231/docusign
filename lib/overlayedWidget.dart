import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class OverlayedWidget extends StatelessWidget {
  final Widget child;

  const OverlayedWidget({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    return StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return MatrixGestureDetector(
            onMatrixUpdate: (m, tm, sm, rm) {
              notifier.value = m;
            },
            child: AnimatedBuilder(
              animation: notifier,
              builder: (ctx, childWidget) {
                return Transform(
                  transform: notifier.value,
                  child: Align(
                    alignment: Alignment.center,
                    child: child,
                  ),
                );
              },
            ),
        );
      }
    );
  }
}