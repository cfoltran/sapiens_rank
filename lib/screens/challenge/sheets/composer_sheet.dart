import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/l10n/app_localizations.dart';
import 'package:sapiens_rank/models/challenge_models.dart';
import 'package:sapiens_rank/screens/challenge/cubit/challenge_state.dart';
import 'package:sapiens_rank/screens/challenge/cubit/composer_cubit.dart';
import 'package:sapiens_rank/screens/challenge/cubit/composer_state.dart';
import 'package:sapiens_rank/screens/challenge/workout_format.dart';

class ComposerSheet extends StatelessWidget {
  const ComposerSheet({super.key, required this.onCreateChallenge});

  final Future<void> Function({
    required String opponentId,
    required int durationDays,
    required String stakeIcon,
    required String stakeLabel,
    required ChallengeType challengeType,
    String? workoutType,
    double? targetDistanceKm,
  })
  onCreateChallenge;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ComposerCubit()..load(),
    child: _ComposerView(onCreateChallenge: onCreateChallenge),
  );
}

class _ComposerView extends StatelessWidget {
  const _ComposerView({required this.onCreateChallenge});

  final Future<void> Function({
    required String opponentId,
    required int durationDays,
    required String stakeIcon,
    required String stakeLabel,
    required ChallengeType challengeType,
    String? workoutType,
    double? targetDistanceKm,
  })
  onCreateChallenge;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposerCubit, ComposerState>(
      listenWhen: (prev, curr) => !prev.sent && curr.sent,
      listener: (context, state) async {
        await Future.delayed(const Duration(milliseconds: 1400));
        if (context.mounted) Navigator.of(context).pop();
      },
      builder: (context, state) {
        final cubit = context.read<ComposerCubit>();
        final canAct = state.canContinue && !state.sending;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.srBgElev2,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: context.srLineStrong)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 14),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.srLineStrong,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 16),
              if (state.sent)
                _SentConfirmation(opponentName: state.opponent?.firstName ?? '')
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  child: _ComposerHeader(step: state.step),
                ),
                Flexible(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shrinkWrap: true,
                    children: [
                      if (state.step == 1)
                        _StepPickOpponent(
                          users: state.opponents,
                          loading: state.loadingOpponents,
                          selected: state.opponent,
                          onSelect: cubit.selectOpponent,
                        ),
                      if (state.step == 2)
                        _StepSetRules(
                          challengeType: state.challengeType,
                          workoutType: state.workoutType,
                          targetDistanceKm: state.targetDistanceKm,
                          duration: state.duration,
                          onChallengeType: cubit.setChallengeType,
                          onWorkoutType: cubit.setWorkoutType,
                          onTargetDistance: cubit.setTargetDistance,
                          onDuration: cubit.setDuration,
                        ),
                      if (state.step == 3)
                        _StepPickReward(
                          selected: state.reward,
                          onSelect: cubit.selectReward,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    16,
                    18,
                    MediaQuery.of(context).padding.bottom + 18,
                  ),
                  child: Row(
                    children: [
                      if (state.step > 1) ...[
                        GestureDetector(
                          onTap: cubit.back,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: context.srLineStrong),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              AppLocalizations.of(context).back,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.srText,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: GestureDetector(
                          onTap: canAct
                              ? () => state.step < 3
                                    ? cubit.next()
                                    : cubit.send(onCreateChallenge)
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: canAct ? context.srLime : context.srTintSm,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: canAct
                                  ? [
                                      BoxShadow(
                                        color: context.srLime.withAlpha(0x44),
                                        blurRadius: 20,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: state.sending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: SrColors.textInk,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      state.step < 3
                                          ? AppLocalizations.of(context).composer_continue
                                          : AppLocalizations.of(context).composer_send,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: canAct
                                            ? SrColors.textInk
                                            : context.srTextDim,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ComposerHeader extends StatelessWidget {
  const _ComposerHeader({required this.step});
  final int step;

  List<String> _titles(BuildContext context) {
    final l = AppLocalizations.of(context);
    return [
      l.composer_pick_opponent,
      l.composer_set_rules,
      l.composer_stake_reward,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final titles = _titles(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titles[step - 1],
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: context.srText,
            letterSpacing: -0.02 * 20,
          ),
        ),
        Row(
          children: List.generate(3, (i) {
            final active = i + 1 == step;
            final done = i + 1 < step;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 16 : 6,
              height: 6,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: (active || done) ? context.srLime : context.srTintMd,
                borderRadius: BorderRadius.circular(100),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StepPickOpponent extends StatelessWidget {
  const _StepPickOpponent({
    required this.users,
    required this.loading,
    required this.selected,
    required this.onSelect,
  });
  final List<ComposerUser> users;
  final bool loading;
  final ComposerUser? selected;
  final ValueChanged<ComposerUser> onSelect;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: context.srLime)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).composer_players(users.length),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: context.srTextDim,
            letterSpacing: 0.15 * 10,
          ),
        ),
        const SizedBox(height: 10),
        ...users.map((u) {
          final isSelected = selected?.userId == u.userId;
          return GestureDetector(
            onTap: () => onSelect(u),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.srLime.withAlpha(0x1A)
                    : context.srTintXs,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? context.srLime : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  _ComposerAvatar(user: u, size: 40, ring: isSelected),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.displayName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.srText,
                          ),
                        ),
                        Text(
                          '@${u.firstName.toLowerCase()}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: context.srTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppLocalizations.of(context).composer_score_label,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: context.srTextDim,
                          letterSpacing: 0.1 * 9,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        u.score.toStringAsFixed(0),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.srText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ComposerAvatar extends StatelessWidget {
  const _ComposerAvatar({
    required this.user,
    required this.size,
    required this.ring,
  });
  final ComposerUser user;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * 0.42;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: user.avatarColor.withAlpha(0x33),
              border: ring
                  ? Border.all(color: user.avatarColor, width: 2)
                  : Border.all(color: context.srLine, width: 1),
            ),
            child: Center(
              child: Text(
                user.initials,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.w700,
                  color: user.avatarColor,
                  height: 1,
                ),
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.srBgElev2,
              ),
              child: Center(
                child: Text(
                  user.flag,
                  style: TextStyle(fontSize: badgeSize * 0.56),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepSetRules extends StatefulWidget {
  const _StepSetRules({
    required this.challengeType,
    required this.workoutType,
    required this.targetDistanceKm,
    required this.duration,
    required this.onChallengeType,
    required this.onWorkoutType,
    required this.onTargetDistance,
    required this.onDuration,
  });
  final ChallengeType challengeType;
  final String? workoutType;
  final double? targetDistanceKm;
  final String duration;
  final ValueChanged<ChallengeType> onChallengeType;
  final ValueChanged<String> onWorkoutType;
  final ValueChanged<double?> onTargetDistance;
  final ValueChanged<String> onDuration;

  @override
  State<_StepSetRules> createState() => _StepSetRulesState();
}

class _StepSetRulesState extends State<_StepSetRules> {
  final _customController = TextEditingController();
  bool _customOpen = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(AppLocalizations.of(context).composer_challenge_type),
        const SizedBox(height: 10),
        Row(
          children:
              [
                (ChallengeType.score, AppLocalizations.of(context).composer_type_score, '📊'),
                (ChallengeType.workout, AppLocalizations.of(context).composer_type_workout, '🏃'),
              ].map((t) {
                final (id, label, icon) = t;
                final active = widget.challengeType == id;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onChallengeType(id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: active
                            ? context.srLime.withAlpha(0x1A)
                            : context.srTintXs,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: active ? context.srLime : context.srLine,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(icon, style: const TextStyle(fontSize: 15)),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: active
                                  ? context.srLimeText
                                  : context.srText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 18),
        if (widget.challengeType == ChallengeType.workout) ...[
          _SectionLabel(AppLocalizations.of(context).composer_sport),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.0,
            children: workoutSports.map((s) {
              final active = widget.workoutType == s.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _customOpen = false;
                    _customController.clear();
                  });
                  widget.onWorkoutType(s.id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: active
                        ? context.srLime.withAlpha(0x1A)
                        : context.srTintXs,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: active ? context.srLime : context.srLine,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(s.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Text(
                        s.label,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active ? context.srLimeText : context.srText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (widget.workoutType != null) ...[
            const SizedBox(height: 18),
            _SectionLabel(AppLocalizations.of(context).composer_distance),
            const SizedBox(height: 10),
            _DistancePicker(
              presets: sportById(widget.workoutType)!.presets,
              selected: widget.targetDistanceKm,
              customOpen: _customOpen,
              customController: _customController,
              onPreset: (km) {
                setState(() {
                  _customOpen = false;
                  _customController.clear();
                });
                widget.onTargetDistance(km);
              },
              onToggleCustom: () => setState(() {
                _customOpen = !_customOpen;
                if (_customOpen) {
                  widget.onTargetDistance(null);
                } else {
                  _customController.clear();
                }
              }),
              onCustomChanged: (v) {
                final km = double.tryParse(v.trim().replaceAll(',', '.'));
                widget.onTargetDistance(km != null && km > 0 ? km : null);
              },
            ),
          ],
          const SizedBox(height: 18),
        ],
        _SectionLabel(AppLocalizations.of(context).composer_duration),
        const SizedBox(height: 4),
        Text(
          widget.challengeType == ChallengeType.workout
              ? AppLocalizations.of(context).composer_duration_hint_workout
              : AppLocalizations.of(context).composer_duration_hint_score,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: context.srTextDim,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children:
              [
                ('1d', AppLocalizations.of(context).composer_24h),
                ('3d', AppLocalizations.of(context).composer_3d),
                ('7d', AppLocalizations.of(context).composer_1w),
                ('30d', AppLocalizations.of(context).composer_30d),
              ].map((d) {
                final (id, label) = d;
                final active = widget.duration == id;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onDuration(id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: active
                            ? context.srLime.withAlpha(0x1A)
                            : context.srTintXs,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: active ? context.srLime : context.srLine,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: active
                                ? context.srLimeText
                                : context.srTextMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.jetBrainsMono(
      fontSize: 10,
      color: context.srTextDim,
      letterSpacing: 0.15 * 10,
    ),
  );
}

class _DistancePicker extends StatelessWidget {
  const _DistancePicker({
    required this.presets,
    required this.selected,
    required this.customOpen,
    required this.customController,
    required this.onPreset,
    required this.onToggleCustom,
    required this.onCustomChanged,
  });
  final List<double> presets;
  final double? selected;
  final bool customOpen;
  final TextEditingController customController;
  final ValueChanged<double> onPreset;
  final VoidCallback onToggleCustom;
  final ValueChanged<String> onCustomChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...presets.map((km) {
              final active = !customOpen && selected == km;
              return _Chip(
                label: WorkoutFormat.distance(km),
                active: active,
                onTap: () => onPreset(km),
              );
            }),
            _Chip(label: AppLocalizations.of(context).composer_custom_distance, active: customOpen, onTap: onToggleCustom),
          ],
        ),
        if (customOpen) ...[
          const SizedBox(height: 10),
          TextField(
            controller: customController,
            autofocus: true,
            onChanged: onCustomChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: context.srText,
            ),
            decoration: InputDecoration(
              suffixText: 'km',
              suffixStyle: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.srLimeText,
              ),
              hintText: AppLocalizations.of(context).composer_distance_hint,
              hintStyle: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                color: context.srTextDim,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              fillColor: context.srTintXs,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.srLine),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.srLime),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.srLine),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? context.srLime.withAlpha(0x1A) : context.srTintXs,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: active ? context.srLime : context.srLine),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? context.srLimeText : context.srTextMuted,
          ),
        ),
      ),
    );
  }
}

class _StepPickReward extends StatefulWidget {
  const _StepPickReward({required this.selected, required this.onSelect});
  final Reward? selected;
  final ValueChanged<Reward?> onSelect;

  @override
  State<_StepPickReward> createState() => _StepPickRewardState();
}

class _StepPickRewardState extends State<_StepPickReward> {
  final _cashController = TextEditingController();
  final _customController = TextEditingController();
  String? _openFieldId;

  @override
  void dispose() {
    _cashController.dispose();
    _customController.dispose();
    super.dispose();
  }

  void _onCashChanged(String value) {
    final trimmed = value.trim();
    widget.onSelect(
      trimmed.isEmpty
          ? null
          : Reward(
              id: 'cash',
              icon: '💶',
              label: '€$trimmed',
              desc: 'Set amount',
            ),
    );
  }

  void _onCustomChanged(String value) {
    final trimmed = value.trim();
    widget.onSelect(
      trimmed.isEmpty
          ? null
          : Reward(id: 'custom', icon: '✏️', label: trimmed, desc: 'Free text'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: presetRewards.map((r) {
        final isCash = r.id == 'cash';
        final isCustom = r.id == 'custom';
        final isFieldType = isCash || isCustom;
        final fieldOpen = _openFieldId == r.id;
        final active = isFieldType ? fieldOpen : selected?.id == r.id;
        final showField = fieldOpen && isFieldType;

        String title() {
          final l = AppLocalizations.of(context);
          if (r.id == 'restaurant') return l.composer_stake_restaurant;
          if (r.id == 'cinema') return l.composer_stake_cinema;
          if (isCash) return l.composer_stake_money;
          return l.composer_stake_custom;
        }

        return GestureDetector(
          onTap: isFieldType
              ? () => setState(() {
                  _openFieldId = fieldOpen ? null : r.id;
                  widget.onSelect(null);
                })
              : () => widget.onSelect(r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: active ? context.srLime.withAlpha(0x1A) : context.srTintXs,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? context.srLime : context.srLine,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.srLime.withAlpha(0x1A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          r.icon,
                          style: TextStyle(
                            fontSize: 18,
                            color: context.srLimeText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.srText,
                            ),
                          ),
                          if (!showField)
                            Text(
                              isCash
                                  ? AppLocalizations.of(context).composer_stake_tap_amount
                                  : isCustom
                                  ? AppLocalizations.of(context).composer_stake_tap_write
                                  : r.desc,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: context.srTextDim,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (showField) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: isCash ? _cashController : _customController,
                    autofocus: true,
                    onChanged: isCash ? _onCashChanged : _onCustomChanged,
                    keyboardType: isCash
                        ? TextInputType.number
                        : TextInputType.text,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: context.srText,
                    ),
                    decoration: InputDecoration(
                      prefixText: isCash ? '€ ' : null,
                      prefixStyle: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.srLimeText,
                      ),
                      hintText: isCash ? '20' : AppLocalizations.of(context).composer_stake_hint_loser,
                      hintStyle: GoogleFonts.jetBrainsMono(
                        fontSize: 13,
                        color: context.srTextDim,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: context.srTintXs,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.srLine),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.srLime),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: context.srLine),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SentConfirmation extends StatelessWidget {
  const _SentConfirmation({required this.opponentName});
  final String opponentName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        children: [
          const Text('⚔️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).composer_sent_title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: context.srText,
              letterSpacing: -0.02 * 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context).composer_sent_subtitle(opponentName),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: context.srTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
