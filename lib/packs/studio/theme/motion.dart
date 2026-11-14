import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Springs described the way Apple does: a damping ratio (1.0 = no overshoot)
/// and a response in seconds. Converted to Flutter's mass/stiffness/damping.
class AppSpring {
  static SpringDescription of({double response = 0.35, double damping = 1.0}) {
    const mass = 1.0;
    final stiffness = math.pow(2 * math.pi / response, 2).toDouble() * mass;
    final d = 4 * math.pi * damping * mass / response;
    return SpringDescription(mass: mass, stiffness: stiffness, damping: d);
  }

  /// Default UI motion: critically damped, settles without bounce.
  static final SpringDescription standard = of(response: 0.35, damping: 1.0);

  /// Press feedback: quick and firm.
  static final SpringDescription press = of(response: 0.18, damping: 1.0);

  /// Only after a gesture that carried momentum (a flick, a completed set).
  static final SpringDescription bouncy = of(response: 0.4, damping: 0.75);
}

/// True when the system asks for reduced motion.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Haptics only on meaningful moments: commit, completion, removal.
class Haptics {
  static void select() => HapticFeedback.selectionClick();
  static void commit() => HapticFeedback.lightImpact();
  static void success() => HapticFeedback.mediumImpact();
  static void warn() => HapticFeedback.heavyImpact();
}

/// Scales its child down the instant a pointer touches it (not on release),
/// then springs back from wherever it is, so rapid taps never jump.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final String? semanticLabel;
  final bool button;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.96,
    this.semanticLabel,
    this.button = true,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController.unbounded(vsync: this, value: 1.0);

  void _to(double target) {
    if (reduceMotion(context)) {
      _c.value = 1.0;
      return;
    }
    _c.animateWith(
      SpringSimulation(AppSpring.press, _c.value, target, _c.velocity),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    return Semantics(
      button: widget.button,
      enabled: enabled,
      label: widget.semanticLabel,
      child: Listener(
        onPointerDown: enabled ? (_) => _to(widget.pressedScale) : null,
        onPointerUp: enabled ? (_) => _to(1.0) : null,
        onPointerCancel: enabled ? (_) => _to(1.0) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, child) =>
                Transform.scale(scale: _c.value, child: child),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Animates a double toward [value] with a spring. When [value] changes
/// mid-flight, the new spring starts from the on-screen value and carries the
/// current velocity, so there is no jump and no "brick wall" on reversal.
class SpringValue extends StatefulWidget {
  final double value;
  final SpringDescription? spring;
  final Widget Function(BuildContext context, double value) builder;

  const SpringValue({
    super.key,
    required this.value,
    required this.builder,
    this.spring,
  });

  @override
  State<SpringValue> createState() => _SpringValueState();
}

class _SpringValueState extends State<SpringValue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController.unbounded(vsync: this, value: widget.value);

  @override
  void didUpdateWidget(covariant SpringValue old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      if (reduceMotion(context)) {
        _c.value = widget.value;
      } else {
        _c.animateWith(SpringSimulation(
          widget.spring ?? AppSpring.standard,
          _c.value,
          widget.value,
          _c.velocity,
        ));
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (ctx, _) => widget.builder(ctx, _c.value),
      );
}
