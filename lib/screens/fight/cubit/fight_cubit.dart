import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/models/challenge_models.dart';
import 'package:sapiens_rank/services/challenge_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fight_state.dart';

class FightCubit extends Cubit<DataState<FightData>> {
  FightCubit() : super(const DataState.loading());

  final _service = ChallengeService.instance;
  String get _myId => Supabase.instance.client.auth.currentUser!.id;

  Future<void> load() async {
    emit(const DataState.loading());
    try {
      final challenges = await _service.fetchMyChallenges();

      final standingsMap = <String, List<ChallengeStanding>>{};
      await Future.wait(
        challenges.where((c) => c.status == ChallengeStatus.live).map((c) async {
          standingsMap[c.id] = await _service.getStandings(c.id);
        }),
      );

      final live = <LiveFight>[];
      final pending = <PendingFight>[];
      final history = <HistoryFight>[];

      for (final c in challenges) {
        if (c.status == ChallengeStatus.cancelled) continue;

        switch (c.status) {
          case ChallengeStatus.live:
            final standings = standingsMap[c.id] ?? [];
            final participants = _mapParticipants(
              c.challengeParticipants,
              standings,
            );
            if (c.endsAt == null) break;
            live.add(
              LiveFight(
                id: c.id,
                stakeIcon: c.stakeIcon,
                stakeLabel: c.stakeLabel,
                endsAt: c.endsAt!,
                participants: participants,
              ),
            );

          case ChallengeStatus.pending:
            final myRow = c.challengeParticipants.firstWhere(
              (p) => p.userId == _myId,
            );
            final opponentRow = c.challengeParticipants.firstWhere(
              (p) => p.userId != _myId,
              orElse: () => c.challengeParticipants.first,
            );
            pending.add(
              PendingFight(
                id: c.id,
                stakeIcon: c.stakeIcon,
                stakeLabel: c.stakeLabel,
                opponent: _toParticipant(
                  opponentRow,
                  score: 0,
                  rank: 0,
                  isMe: false,
                ),
                iAmCreator: myRow.isCreator,
              ),
            );

          case 'done':
            final standings = await _service.getStandings(c.id);
            final participants = _mapParticipants(
              c.challengeParticipants,
              standings,
            );
            final me = participants.firstWhere(
              (p) => p.isMe,
              orElse: () => participants.first,
            );
            final opponent = participants.firstWhere(
              (p) => !p.isMe,
              orElse: () => participants.first,
            );
            final bool? won = c.winnerId == null ? null : c.winnerId == _myId;
            history.add(
              HistoryFight(
                id: c.id,
                stakeLabel: '${c.stakeIcon} ${c.stakeLabel}'.trim(),
                opponent: opponent,
                myScore: me.score,
                opponentScore: opponent.score,
                won: won,
                endedAt: c.endsAt!,
              ),
            );
        }
      }

      emit(
        DataState.success(
          FightData(live: live, pending: pending, history: history),
        ),
      );
    } catch (e, st) {
      emit(DataState.error('fetch_failed', error: e, stackTrace: st));
    }
  }

  Future<void> createChallenge({
    required String opponentId,
    required int durationDays,
    required String stakeIcon,
    required String stakeLabel,
  }) async {
    await _service.createChallenge(
      opponentId: opponentId,
      durationDays: durationDays,
      stakeIcon: stakeIcon,
      stakeLabel: stakeLabel,
    );
    load();
  }

  Future<void> respond(String challengeId, {required bool accept}) async {
    await _service.respondToChallenge(challengeId, accept: accept);
    load();
  }

  Future<void> cancel(String challengeId) async {
    await _service.cancelChallenge(challengeId);
    load();
  }

  List<FightParticipant> _mapParticipants(
    List<ChallengeParticipant> participants,
    List<ChallengeStanding> standings,
  ) {
    final scoreMap = {for (final s in standings) s.userId: s.score};
    final rankMap = {for (final s in standings) s.userId: s.rank};

    return participants.map((p) {
      return _toParticipant(
        p,
        score: scoreMap[p.userId] ?? 0,
        rank: rankMap[p.userId] ?? 0,
        isMe: p.userId == _myId,
      );
    }).toList()..sort((a, b) => a.rank.compareTo(b.rank));
  }

  FightParticipant _toParticipant(
    ChallengeParticipant p, {
    required double score,
    required int rank,
    required bool isMe,
  }) {
    final name = p.profiles.name;
    final country = p.profiles.country;
    return FightParticipant(
      userId: p.userId,
      displayName: name,
      initials: _initials(name),
      avatarColor: _avatarColor(p.userId),
      flag: country != null ? _countryFlag(country) : '🌍',
      score: score,
      rank: rank,
      isMe: isMe,
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, math.min(2, name.length)).toUpperCase();
  }

  static const _palette = [
    Color(0xFFFF6B7A),
    Color(0xFF7CB6FF),
    Color(0xFFF0A64A),
    Color(0xFFC5A3FF),
    Color(0xFF9BE7C4),
    Color(0xFFFFB84A),
    Color(0xFF7CE5FF),
    Color(0xFFFF9B7A),
    Color(0xFFD9FF3D),
    Color(0xFFB5A8FF),
    Color(0xFFF5D76E),
    Color(0xFFFF7AD9),
  ];

  static Color _avatarColor(String userId) {
    final hash = userId.codeUnits.fold(0, (a, b) => a + b);
    return _palette[hash % _palette.length];
  }

  static String _countryFlag(String code) => code
      .toUpperCase()
      .runes
      .map((r) => String.fromCharCode(r + 0x1F1E6 - 0x41))
      .join();
}
