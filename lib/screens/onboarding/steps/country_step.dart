import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/data/countries.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/arena_button.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/onboarding_text.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/sr_selectable_card.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/sr_text_field.dart';
import 'package:sapiens_rank/screens/onboarding/widgets/step_shell.dart';

class CountryStep extends StatefulWidget {
  const CountryStep({
    super.key,
    required this.progress,
    required this.total,
    required this.initialValue,
    required this.onSubmit,
    required this.onBack,
  });

  final int progress;
  final int total;
  final String initialValue;
  final void Function(String code) onSubmit;
  final VoidCallback onBack;

  @override
  State<CountryStep> createState() => SrCountryStepState();
}

class SrCountryStepState extends State<CountryStep> {
  late String _selected;
  String _query = '';
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
    _searchCtrl = TextEditingController();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SrCountry> get _filtered {
    if (_query.isEmpty) return kCountries;
    final q = _query.toLowerCase();
    return kCountries.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  String get _selectedFlag =>
      kCountries.firstWhere((c) => c.code == _selected).flag;

  @override
  Widget build(BuildContext context) {
    return StepShell(
      progress: widget.progress,
      total: widget.total,
      footer: Column(
        children: [
          ArenaButton(
            label: 'Plant my flag $_selectedFlag →',
            onTap: () => widget.onSubmit(_selected),
          ),
          const SizedBox(height: 8),
          ArenaSecondaryButton(label: 'Back', onTap: widget.onBack),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingEyebrow('Where do you fight?'),
          const SizedBox(height: 14),
          Text(
            'Plant your flag.',
            style: Theme.of(
              context,
            ).textTheme.displayMedium!.copyWith(color: context.srText),
          ),
          const SizedBox(height: 10),
          const OnboardingLede(
            "You'll compete on both the global and country leaderboards. "
            "Pick wisely, you can only switch once a quarter.",
          ),
          const SizedBox(height: 24),
          _SearchInput(controller: _searchCtrl),
          const SizedBox(height: 14),
          SrCountryList(
            countries: _filtered,
            selected: _selected,
            onSelect: (code) => setState(() => _selected = code),
          ),
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SrTextField(
      controller: controller,
      hintText: 'Search country...',
      style: tt.bodyMedium,
      borderRadius: 14,
      borderColor: context.srLineStrong,
      focusedBorderColor: context.srLineStrong,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: const Padding(
        padding: EdgeInsets.only(left: 14, right: 8),
        child: Text('🔍', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

class SrCountryList extends StatelessWidget {
  const SrCountryList({
    required this.countries,
    required this.selected,
    required this.onSelect,
  });

  final List<SrCountry> countries;
  final String selected;
  final void Function(String code) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final c in countries)
          SrCountryRow(
            country: c,
            isSelected: c.code == selected,
            onTap: () => onSelect(c.code),
          ),
      ],
    );
  }
}

class SrCountryRow extends StatelessWidget {
  const SrCountryRow({
    required this.country,
    required this.isSelected,
    required this.onTap,
  });

  final SrCountry country;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SrSelectableCard(
      isSelected: isSelected,
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(country.flag, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country.name,
                  style: tt.labelLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.srText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${country.sapiens} sapiens',
                  style: tt.labelMedium!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: context.srTextDim,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.srLime,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 13,
                color: SrColors.textInk,
              ),
            ),
        ],
      ),
    );
  }
}

