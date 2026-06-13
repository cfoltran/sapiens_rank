import 'package:flutter/material.dart';

class GuildAvatar extends StatelessWidget {
  const GuildAvatar({
    super.key,
    required this.color,
    required this.initials,
    this.size = 44,
  });

  final Color color;
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        shape: BoxShape.circle,
        border: Border.all(color: color.withAlpha(150), width: 2),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: size * 0.34,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
