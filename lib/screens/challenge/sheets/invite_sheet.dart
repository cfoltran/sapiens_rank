import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/common/widgets/sr_bottom_sheet.dart';
import 'package:sapiens_rank/models/challenge_models.dart';
import 'package:sapiens_rank/screens/challenge/cubit/invite_cubit.dart';

class InviteSheet extends StatelessWidget {
  const InviteSheet({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InviteCubit(challengeId)..load(),
      child: BlocListener<InviteCubit, DataState<ChallengeRow>>(
        listener: (context, state) {
          if (state.status == DataStatus.initial) {
            Navigator.of(context).pop(true);
          }
        },
        child: const _InviteSheetView(),
      ),
    );
  }
}

class _InviteSheetView extends StatelessWidget {
  const _InviteSheetView();

  @override
  Widget build(BuildContext context) {
    return SrBottomSheet(
      title: 'Challenge Invite',
      child: BlocBuilder<InviteCubit, DataState<ChallengeRow>>(
        builder: (context, state) {
          if (state.status == DataStatus.error) {
            return SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  'Challenge not found',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: context.srTextDim,
                  ),
                ),
              ),
            );
          }
          final challenge = state.data;
          if (challenge == null) {
            return const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _InviteContent(
            challenge: challenge,
            responding: state.status == DataStatus.loading,
          );
        },
      ),
    );
  }
}

class _InviteContent extends StatelessWidget {
  const _InviteContent({required this.challenge, required this.responding});

  final ChallengeRow challenge;
  final bool responding;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InviteCubit>();
    final creator = challenge.challengeParticipants.firstWhere(
      (p) => p.isCreator,
      orElse: () => challenge.challengeParticipants.first,
    );
    final creatorName = creator.profiles.name;
    final firstName = creatorName.split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.srTintXs,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.srLine),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SrColors.amber.withAlpha(0x33),
                  border: Border.all(color: SrColors.amber.withAlpha(0x66)),
                ),
                child: Center(
                  child: Text(
                    _initials(creatorName),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: SrColors.amber,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$firstName challenged you!',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.srText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_durationLabel(challenge.durationDays)} · ${challenge.stakeIcon} ${challenge.stakeLabel}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: context.srTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: SrColors.amber.withAlpha(0x14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SrColors.amber.withAlpha(0x44)),
          ),
          child: Row(
            children: [
              Text(challenge.stakeIcon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IF YOU ACCEPT AND WIN',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: context.srTextDim,
                        letterSpacing: 0.15 * 9,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      challenge.stakeLabel,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.srText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: responding ? null : () => cubit.respond(accept: false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.srLineStrong),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'Decline',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.srTextMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: responding ? null : () => cubit.respond(accept: true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: context.srLime,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: context.srLime.withAlpha(0x44),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Center(
                    child: responding
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: SrColors.textInk,
                            ),
                          )
                        : Text(
                            'Accept challenge ⚔️',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: SrColors.textInk,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  static String _durationLabel(int days) {
    if (days == 1) return '1 day';
    if (days == 7) return '1 week';
    if (days == 30) return '1 month';
    return '$days days';
  }
}
