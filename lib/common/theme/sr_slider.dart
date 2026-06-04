import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';

class SrSlider extends StatefulWidget {
  const SrSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.onChanged,
    this.trackHeight = 4.5,
    this.thumbShape,
  });

  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color color;
  final ValueChanged<double> onChanged;
  final double trackHeight;
  final SliderComponentShape? thumbShape;

  @override
  State<SrSlider> createState() => _SrSliderState();
}

class _SrSliderState extends State<SrSlider> {
  double? _lastValue;

  void _handleChange(double value) {
    if (_lastValue != value) {
      HapticFeedback.selectionClick();
      _lastValue = value;
    }
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: widget.trackHeight,
        activeTrackColor: widget.color,
        inactiveTrackColor: context.srTintSm,
        thumbColor: widget.color,
        thumbShape: widget.thumbShape,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        overlayColor: widget.color.withAlpha(31),
      ),
      child: SizedBox(
        height: 28,
        child: Slider(
          value: widget.value.clamp(widget.min, widget.max),
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          onChanged: _handleChange,
        ),
      ),
    );
  }
}
