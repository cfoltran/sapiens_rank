import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/l10n/app_localizations.dart';

const _colorPalette = [
  '#E74C3C',
  '#E67E22',
  '#F1C40F',
  '#2ECC71',
  '#1ABC9C',
  '#3498DB',
  '#9B59B6',
  '#E91E63',
];

Color _parse(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

class CreateGuildSheet extends StatefulWidget {
  const CreateGuildSheet({
    super.key,
    required this.onCreate,
    this.takenColors = const {},
  });

  final void Function(String name, String color) onCreate;
  final Set<String> takenColors;

  @override
  State<CreateGuildSheet> createState() => _CreateGuildSheetState();
}

class _CreateGuildSheetState extends State<CreateGuildSheet> {
  final _controller = TextEditingController();
  late String _color;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _color = _colorPalette.firstWhere(
      (c) => !widget.takenColors.contains(c),
      orElse: () => _colorPalette.first,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    setState(() => _loading = true);
    try {
      Navigator.pop(context);
      widget.onCreate(name, _color);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.srBgElev,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.srLine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context).create_guild_title,
            style: TextStyle(
              color: context.srText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 24,
            style: TextStyle(color: context.srText),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).create_guild_name_hint,
              hintStyle: TextStyle(color: context.srTextDim),
              filled: true,
              fillColor: context.srBgElev2,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.srLine),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.srLine),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.srLime),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context).create_guild_color,
            style: TextStyle(
              color: context.srTextDim,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _colorPalette.map((hex) {
              final selected = _color == hex;
              final taken = widget.takenColors.contains(hex);
              return GestureDetector(
                onTap: taken ? null : () => setState(() => _color = hex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 10),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _parse(hex).withAlpha(taken ? 60 : 255),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _parse(hex).withAlpha(120),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: taken
                      ? Icon(
                          Icons.close,
                          size: 14,
                          color: _parse(hex).withAlpha(160),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: context.srLime,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context).create_guild_btn,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
