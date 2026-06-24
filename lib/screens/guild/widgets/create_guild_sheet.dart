import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/sr_text_field.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/screens/guild/cubit/create_guild_cubit.dart';

const _colorPalette = [
  '#E74C3C',
  '#E67E22',
  '#F1C40F',
  '#2ECC71',
  '#1ABC9C',
  '#3498DB',
  '#9B59B6',
  '#E91E63',
  '#D35400',
  '#16A085',
  '#2980B9',
  '#8E44AD',
  '#C0392B',
  '#27AE60',
  '#00BCD4',
  '#795548',
  '#607D8B',
  '#FF6F91',
];

Color _parse(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

class CreateGuildSheet extends StatelessWidget {
  const CreateGuildSheet({
    super.key,
    required this.onCreated,
    this.takenColors = const {},
  });

  final VoidCallback onCreated;
  final Set<String> takenColors;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateGuildCubit(),
      child: _CreateGuildForm(onCreated: onCreated, takenColors: takenColors),
    );
  }
}

class _CreateGuildForm extends StatefulWidget {
  const _CreateGuildForm({required this.onCreated, required this.takenColors});

  final VoidCallback onCreated;
  final Set<String> takenColors;

  @override
  State<_CreateGuildForm> createState() => _CreateGuildFormState();
}

class _CreateGuildFormState extends State<_CreateGuildForm> {
  final _controller = TextEditingController();
  late String _color;

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

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    context.read<CreateGuildCubit>().create(name: name, color: _color);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateGuildCubit, DataState<GuildRow>>(
      listener: (context, state) {
        if (state.status == DataStatus.success) {
          Navigator.pop(context);
          widget.onCreated();
        } else if (state.status == DataStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not create guild. Try again.')),
          );
        }
      },
      child: Container(
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
              'Create a guild',
              style: TextStyle(
                color: context.srText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            SrTextField(
              controller: _controller,
              hintText: 'Guild name',
              autofocus: true,
              maxLength: 24,
            ),
            const SizedBox(height: 20),
            Text(
              'COLOR',
              style: TextStyle(
                color: context.srTextDim,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colorPalette
                  .where((hex) => !widget.takenColors.contains(hex))
                  .map(
                    (hex) => _ColorDot(
                      hex: hex,
                      selected: _color == hex,
                      onTap: () => setState(() => _color = hex),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 28),
            BlocBuilder<CreateGuildCubit, DataState<GuildRow>>(
              builder: (context, state) {
                final loading = state.status == DataStatus.loading;
                return SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.srLime,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'Create',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _parse(hex),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: _parse(hex).withAlpha(120), blurRadius: 8)]
              : null,
        ),
      ),
    );
  }
}
