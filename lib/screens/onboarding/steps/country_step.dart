import 'package:flutter/material.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
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
  State<CountryStep> createState() => _CountryStepState();
}

class _CountryStepState extends State<CountryStep> {
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

  List<_Country> get _filtered {
    if (_query.isEmpty) return _kCountries;
    final q = _query.toLowerCase();
    return _kCountries.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  String get _selectedFlag =>
      _kCountries.firstWhere((c) => c.code == _selected).flag;

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
            ).textTheme.displayMedium!.copyWith(color: SrColors.text),
          ),
          const SizedBox(height: 10),
          const OnboardingLede(
            "You'll compete on both the global and country leaderboards. "
            "Pick wisely, you can only switch once a quarter.",
          ),
          const SizedBox(height: 24),
          _SearchInput(controller: _searchCtrl),
          const SizedBox(height: 14),
          _CountryList(
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
      borderColor: SrColors.lineStrong,
      focusedBorderColor: SrColors.lineStrong,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: const Padding(
        padding: EdgeInsets.only(left: 14, right: 8),
        child: Text('🔍', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _CountryList extends StatelessWidget {
  const _CountryList({
    required this.countries,
    required this.selected,
    required this.onSelect,
  });

  final List<_Country> countries;
  final String selected;
  final void Function(String code) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final c in countries)
          _CountryRow(
            country: c,
            isSelected: c.code == selected,
            onTap: () => onSelect(c.code),
          ),
      ],
    );
  }
}

class _CountryRow extends StatelessWidget {
  const _CountryRow({
    required this.country,
    required this.isSelected,
    required this.onTap,
  });

  final _Country country;
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
                    color: SrColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${country.sapiens} sapiens',
                  style: tt.labelMedium!.copyWith(
                    fontWeight: FontWeight.normal,
                    color: SrColors.textDim,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: SrColors.lime,
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

class _Country {
  const _Country({
    required this.code,
    required this.flag,
    required this.name,
    required this.sapiens,
  });

  final String code;
  final String flag;
  final String name;
  final String sapiens;
}

const _kCountries = [
  _Country(code: 'FR', flag: '🇫🇷', name: 'France', sapiens: '184K'),
  _Country(code: 'US', flag: '🇺🇸', name: 'United States', sapiens: '512K'),
  _Country(code: 'GB', flag: '🇬🇧', name: 'United Kingdom', sapiens: '143K'),
  _Country(code: 'DE', flag: '🇩🇪', name: 'Germany', sapiens: '167K'),
  _Country(code: 'JP', flag: '🇯🇵', name: 'Japan', sapiens: '224K'),
  _Country(code: 'KR', flag: '🇰🇷', name: 'South Korea', sapiens: '98K'),
  _Country(code: 'IN', flag: '🇮🇳', name: 'India', sapiens: '301K'),
  _Country(code: 'BR', flag: '🇧🇷', name: 'Brazil', sapiens: '88K'),
  _Country(code: 'CA', flag: '🇨🇦', name: 'Canada', sapiens: '76K'),
  _Country(code: 'AU', flag: '🇦🇺', name: 'Australia', sapiens: '64K'),
  _Country(code: 'ES', flag: '🇪🇸', name: 'Spain', sapiens: '92K'),
  _Country(code: 'IT', flag: '🇮🇹', name: 'Italy', sapiens: '102K'),
  _Country(code: 'NL', flag: '🇳🇱', name: 'Netherlands', sapiens: '52K'),
  _Country(code: 'SE', flag: '🇸🇪', name: 'Sweden', sapiens: '38K'),
  _Country(code: 'NO', flag: '🇳🇴', name: 'Norway', sapiens: '22K'),
  _Country(code: 'CH', flag: '🇨🇭', name: 'Switzerland', sapiens: '31K'),
  _Country(code: 'BE', flag: '🇧🇪', name: 'Belgium', sapiens: '28K'),
  _Country(code: 'PT', flag: '🇵🇹', name: 'Portugal', sapiens: '24K'),
  _Country(code: 'AE', flag: '🇦🇪', name: 'UAE', sapiens: '19K'),
  _Country(code: 'SG', flag: '🇸🇬', name: 'Singapore', sapiens: '21K'),
  _Country(code: 'MX', flag: '🇲🇽', name: 'Mexico', sapiens: '67K'),
  _Country(code: 'CN', flag: '🇨🇳', name: 'China', sapiens: '442K'),
];
