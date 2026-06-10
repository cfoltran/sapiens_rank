import 'package:sapiens_rank/screens/challenge/cubit/challenge_state.dart';

class Reward {
  const Reward({
    required this.id,
    required this.icon,
    required this.label,
    required this.desc,
  });
  final String id;
  final String icon;
  final String label;
  final String desc;
}

const presetRewards = [
  Reward(
    id: 'restaurant',
    icon: '🍽️',
    label: 'Restaurant',
    desc: 'I invite you',
  ),
  Reward(id: 'cinema', icon: '🎬', label: 'Cinema', desc: 'On me'),
  Reward(id: 'cash', icon: '💶', label: '', desc: 'Set amount'),
  Reward(id: 'custom', icon: '✏️', label: '', desc: 'Free text'),
];

class ComposerState {
  const ComposerState({
    this.opponents = const [],
    this.loadingOpponents = true,
    this.step = 1,
    this.opponent,
    this.metric = 'total',
    this.duration = '1d',
    this.goalValue,
    this.reward,
    this.sending = false,
    this.sent = false,
  });

  final List<ComposerUser> opponents;
  final bool loadingOpponents;
  final int step;
  final ComposerUser? opponent;
  final String metric;
  final String duration;
  final double? goalValue;
  final Reward? reward;
  final bool sending;
  final bool sent;

  bool get isWorkout => metric == 'running' || metric == 'cycling';

  bool get canContinue {
    if (step == 1) return opponent != null;
    if (step == 2) {
      if (isWorkout && (goalValue == null || goalValue! <= 0)) return false;
      return duration.isNotEmpty;
    }
    if (step == 3) return reward != null && reward!.label.isNotEmpty;
    return false;
  }

  ComposerState copyWith({
    List<ComposerUser>? opponents,
    bool? loadingOpponents,
    int? step,
    ComposerUser? opponent,
    String? metric,
    String? duration,
    double? Function()? goalValue,
    Reward? Function()? reward,
    bool? sending,
    bool? sent,
  }) => ComposerState(
    opponents: opponents ?? this.opponents,
    loadingOpponents: loadingOpponents ?? this.loadingOpponents,
    step: step ?? this.step,
    opponent: opponent ?? this.opponent,
    metric: metric ?? this.metric,
    duration: duration ?? this.duration,
    goalValue: goalValue != null ? goalValue() : this.goalValue,
    reward: reward != null ? reward() : this.reward,
    sending: sending ?? this.sending,
    sent: sent ?? this.sent,
  );
}
