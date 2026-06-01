import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/screens/challenge/cubit/result_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResultSheet extends StatelessWidget {
  const ResultSheet({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResultCubit(challengeId)..load(),
      child: const _ResultView(),
    );
  }
}

class _ResultView extends StatefulWidget {
  const _ResultView();

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView>
    with TickerProviderStateMixin {
  late final AnimationController _entry;
  late final AnimationController _trophyCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _confettiCtrl;
  late final List<_Particle> _particles;
  bool _claimed = false;
  bool _confettiStarted = false;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _trophyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _particles = _buildParticles();

    _entry.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _trophyCtrl.forward();
    });
  }

  List<_Particle> _buildParticles() {
    final rng = math.Random(42);
    final colors = [
      SrColors.lime,
      SrColors.amber,
      SrColors.magenta,
      SrColors.cyan,
    ];
    return List.generate(
      64,
      (i) => _Particle(
        x: rng.nextDouble(),
        delay: rng.nextDouble() * 0.6,
        speed: 1.8 + rng.nextDouble() * 1.6,
        size: 5 + rng.nextDouble() * 7,
        color: colors[i % colors.length],
        drift: (rng.nextDouble() - 0.5) * 0.3,
        isRound: rng.nextBool(),
        rot: rng.nextDouble() * 2 * math.pi,
      ),
    );
  }

  @override
  void dispose() {
    _entry.dispose();
    _trophyCtrl.dispose();
    _glowCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  Animation<double> _rise(double start, double end) => CurvedAnimation(
    parent: _entry,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResultCubit, DataState<ResultData>>(
      builder: (context, state) {
        if (state.status == DataStatus.loading && state.data == null) {
          return _buildLoading(context);
        }
        if (state.status == DataStatus.error) {
          return _buildError(context);
        }

        final data = state.data!;
        final myId = Supabase.instance.client.auth.currentUser?.id;
        final challenge = data.challenge;
        final winnerId = challenge.winnerId;
        final isWin = winnerId != null && winnerId == myId;
        final isDraw = winnerId == null;

        if (isWin && !_confettiStarted) {
          _confettiStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _confettiCtrl.forward();
          });
        }

        final myStanding = data.standings
            .where((s) => s.userId == myId)
            .firstOrNull;
        final oppStanding = data.standings
            .where((s) => s.userId != myId)
            .firstOrNull;
        final oppParticipant = challenge.challengeParticipants
            .where((p) => p.userId != myId)
            .firstOrNull;

        final myScore = (myStanding?.score ?? 0).round();
        final oppScore = (oppStanding?.score ?? 0).round();
        final margin = myScore - oppScore;
        final oppName =
            oppParticipant?.profiles.name.split(' ').first ?? 'Opponent';
        final oppUserId = oppStanding?.userId ?? '';

        final accent = isDraw
            ? context.srAmber
            : isWin
            ? context.srLime
            : context.srRose;
        final accentText = isDraw
            ? context.srAmber
            : isWin
            ? context.srLimeText
            : context.srRose;

        final screenH = MediaQuery.of(context).size.height;
        final screenW = MediaQuery.of(context).size.width;

        return Material(
          color: Colors.transparent,
          child: Container(
            height: screenH,
            color: context.srBg,
            child: Stack(
              children: [
                Positioned(
                  top: -(screenH * 0.25),
                  left: -(screenW * 0.4),
                  right: -(screenW * 0.4),
                  height: screenH * 0.75,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [accent.withAlpha(0x22), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                if (isWin)
                  AnimatedBuilder(
                    animation: _confettiCtrl,
                    builder: (_, _) => CustomPaint(
                      painter: _ConfettiPainter(
                        _particles,
                        _confettiCtrl.value,
                        screenH,
                      ),
                      size: Size(screenW, screenH),
                    ),
                  ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: context.srTintSm,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: context.srLine),
                              ),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: context.srTextMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              _RiseSection(
                                animation: _rise(0, 0.5),
                                child: _TrophyHero(
                                  isWin: isWin,
                                  isDraw: isDraw,
                                  accent: accent,
                                  trophyScale:
                                      Tween<double>(
                                        begin: 0.4,
                                        end: 1.0,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: _trophyCtrl,
                                          curve: const ElasticOutCurve(0.75),
                                        ),
                                      ),
                                  glowCtrl: _glowCtrl,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _RiseSection(
                                animation: _rise(0.25, 0.6),
                                child: _TitleSection(
                                  isWin: isWin,
                                  isDraw: isDraw,
                                  oppName: oppName,
                                  margin: margin,
                                  accentText: accentText,
                                ),
                              ),
                              const SizedBox(height: 26),
                              _RiseSection(
                                animation: _rise(0.38, 0.72),
                                child: _ScoreFaceoff(
                                  isWin: isWin,
                                  isDraw: isDraw,
                                  myScore: myScore,
                                  oppScore: oppScore,
                                  oppName: oppName,
                                  oppUserId: oppUserId,
                                  accent: accent,
                                  accentText: accentText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _RiseSection(
                                animation: _rise(0.52, 0.83),
                                child: _StakeSection(
                                  icon: challenge.stakeIcon,
                                  label: challenge.stakeLabel,
                                  isWin: isWin,
                                  isDraw: isDraw,
                                  claimed: _claimed,
                                  onClaim: () =>
                                      setState(() => _claimed = true),
                                  accentText: accentText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _RiseSection(
                        animation: _rise(0.68, 1.0),
                        child: _Footer(
                          isWin: isWin,
                          accent: accent,
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) => Container(
    height: MediaQuery.of(context).size.height,
    color: context.srBg,
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _buildError(BuildContext context) => Container(
    height: MediaQuery.of(context).size.height,
    color: context.srBg,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Result not found',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: context.srTextDim,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.srTextMuted,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _RiseSection extends StatelessWidget {
  const _RiseSection({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class _TrophyHero extends StatelessWidget {
  const _TrophyHero({
    required this.isWin,
    required this.isDraw,
    required this.accent,
    required this.trophyScale,
    required this.glowCtrl,
  });

  final bool isWin;
  final bool isDraw;
  final Color accent;
  final Animation<double> trophyScale;
  final AnimationController glowCtrl;

  @override
  Widget build(BuildContext context) {
    final emoji = isWin
        ? '🏆'
        : isDraw
        ? '🤝'
        : '😤';
    final gradientColors = isWin
        ? [context.srLime, context.srAmber]
        : isDraw
        ? [context.srAmber, SrColors.bronze]
        : [context.srRose, context.srRose];

    return ScaleTransition(
      scale: trophyScale,
      child: AnimatedBuilder(
        animation: glowCtrl,
        builder: (_, _) {
          final glowScale = 0.88 + glowCtrl.value * 0.24;
          final glowOpacity = 0.65 + glowCtrl.value * 0.35;
          return SizedBox(
            width: 164,
            height: 164,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: glowScale,
                  child: Opacity(
                    opacity: glowOpacity,
                    child: Container(
                      width: 164,
                      height: 164,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [accent.withAlpha(0x66), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withAlpha(0x55),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 52)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection({
    required this.isWin,
    required this.isDraw,
    required this.oppName,
    required this.margin,
    required this.accentText,
  });

  final bool isWin;
  final bool isDraw;
  final String oppName;
  final int margin;
  final Color accentText;

  @override
  Widget build(BuildContext context) {
    final eyebrow = isWin
        ? 'CHALLENGE WON'
        : isDraw
        ? 'CHALLENGE ENDED'
        : 'CHALLENGE ENDED';
    final headline = isWin
        ? 'Victory.'
        : isDraw
        ? 'Draw.'
        : 'Defeated.';
    final sub = isWin
        ? 'You beat $oppName by '
        : isDraw
        ? 'You and $oppName are perfectly matched.'
        : '$oppName won by ';
    final showMargin = (isWin || (!isDraw)) && margin.abs() > 0;
    final marginLabel = '${margin.abs()} point${margin.abs() != 1 ? 's' : ''}';

    return Column(
      children: [
        Text(
          eyebrow,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.11 * 3,
            color: accentText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          headline,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 56,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            letterSpacing: 56 * -0.05,
            height: 1,
            color: context.srText,
          ),
        ),
        const SizedBox(height: 10),
        if (!isDraw)
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                color: context.srTextMuted,
              ),
              children: [
                TextSpan(text: sub),
                if (showMargin)
                  TextSpan(
                    text: marginLabel,
                    style: TextStyle(
                      color: accentText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (showMargin) const TextSpan(text: '.'),
              ],
            ),
          )
        else
          Text(
            sub,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: context.srTextMuted,
            ),
          ),
      ],
    );
  }
}

class _ScoreFaceoff extends StatelessWidget {
  const _ScoreFaceoff({
    required this.isWin,
    required this.isDraw,
    required this.myScore,
    required this.oppScore,
    required this.oppName,
    required this.oppUserId,
    required this.accent,
    required this.accentText,
  });

  final bool isWin;
  final bool isDraw;
  final int myScore;
  final int oppScore;
  final String oppName;
  final String oppUserId;
  final Color accent;
  final Color accentText;

  @override
  Widget build(BuildContext context) {
    final oppAvatarColor = _avatarColor(oppUserId);
    final oppInitials = _initials(oppName);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [context.srBgElev2, context.srBgElev],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.srLineStrong),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PlayerColumn(
              label: 'You',
              score: myScore,
              isWinner: isWin || isDraw,
              showCrown: isWin,
              accentText: accentText,
              avatarColor: context.srLime.withAlpha(0x44),
              avatarInitials: 'ME',
              opacity: 1.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'VS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: context.srTextDim,
              ),
            ),
          ),
          Expanded(
            child: _PlayerColumn(
              label: oppName,
              score: oppScore,
              isWinner: !isWin && !isDraw,
              showCrown: !isWin && !isDraw,
              accentText: accentText,
              avatarColor: oppAvatarColor,
              avatarInitials: oppInitials,
              opacity: isWin ? 0.65 : 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerColumn extends StatelessWidget {
  const _PlayerColumn({
    required this.label,
    required this.score,
    required this.isWinner,
    required this.showCrown,
    required this.accentText,
    required this.avatarColor,
    required this.avatarInitials,
    required this.opacity,
  });

  final String label;
  final int score;
  final bool isWinner;
  final bool showCrown;
  final Color accentText;
  final Color avatarColor;
  final String avatarInitials;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Column(
        children: [
          SizedBox(
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                    border: isWinner
                        ? Border.all(color: accentText, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      avatarInitials,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.srText,
                      ),
                    ),
                  ),
                ),
                if (showCrown)
                  Positioned(
                    top: 0,
                    child: Text('👑', style: const TextStyle(fontSize: 18)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.srTextMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              letterSpacing: 40 * -0.05,
              height: 1,
              color: isWinner ? accentText : context.srTextMuted,
            ),
          ),
          Text(
            'avg score',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              color: context.srTextDim,
              letterSpacing: 9 * 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StakeSection extends StatelessWidget {
  const _StakeSection({
    required this.icon,
    required this.label,
    required this.isWin,
    required this.isDraw,
    required this.claimed,
    required this.onClaim,
    required this.accentText,
  });

  final String icon;
  final String label;
  final bool isWin;
  final bool isDraw;
  final bool claimed;
  final VoidCallback onClaim;
  final Color accentText;

  @override
  Widget build(BuildContext context) {
    final statusLabel = isDraw
        ? 'SPLIT'
        : isWin
        ? 'YOU TAKE'
        : 'THEY TAKE';
    final borderColor = claimed
        ? context.srLime.withAlpha(0x66)
        : isWin
        ? context.srAmber.withAlpha(0x66)
        : context.srLine;
    final bgColor = claimed
        ? context.srLime.withAlpha(0x14)
        : isWin
        ? context.srAmber.withAlpha(0x1A)
        : context.srTintXs;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: context.srTintSm,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        claimed ? '✓ REWARD CLAIMED' : statusLabel,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 9 * 0.18,
                          color: claimed ? context.srLimeText : accentText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.01,
                          color: context.srText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.emoji_events_rounded,
                  size: 20,
                  color: claimed ? context.srLimeText : accentText,
                ),
              ],
            ),
          ),
          if (isWin && !claimed)
            GestureDetector(
              onTap: onClaim,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: context.srAmber,
                  border: Border(top: BorderSide(color: context.srLine)),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(22),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Claim reward →',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: SrColors.textInk,
                    ),
                  ),
                ),
              ),
            ),
          if (isWin && claimed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.srLine)),
              ),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: context.srTextMuted,
                      letterSpacing: 11 * 0.05,
                    ),
                    children: [
                      const TextSpan(text: 'Sent to your wallet · code '),
                      TextSpan(
                        text: 'SAP-9F2K',
                        style: TextStyle(color: context.srLimeText),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.isWin,
    required this.accent,
    required this.onClose,
  });

  final bool isWin;
  final Color accent;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        12,
        22,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: context.srBg,
        border: Border(top: BorderSide(color: context.srLine)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: context.srLineStrong),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Close',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.srText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withAlpha(0x44),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isWin
                        ? 'Rematch ⚔️'
                        : isDraw
                        ? 'Rematch ⚔️'
                        : 'OK',
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
    );
  }

  bool get isDraw => false;
}

class _Particle {
  const _Particle({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.color,
    required this.drift,
    required this.isRound,
    required this.rot,
  });

  final double x;
  final double delay;
  final double speed;
  final double size;
  final Color color;
  final double drift;
  final bool isRound;
  final double rot;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.progress, this.screenH);

  final List<_Particle> particles;
  final double progress;
  final double screenH;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const totalDur = 2.6;

    for (final p in particles) {
      final elapsed = progress * totalDur;
      if (elapsed < p.delay) continue;
      final local = ((elapsed - p.delay) / p.speed).clamp(0.0, 1.0);
      if (local >= 1.0) continue;

      final x = p.x * size.width + p.drift * local * size.width;
      final y = -20 + local * (screenH + 40);
      final alpha = (255 * (1 - local)).round().clamp(0, 255);

      paint.color = p.color.withAlpha(alpha);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rot + local * 4 * math.pi);

      if (p.isRound) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.5,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

String _initials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return name.substring(0, math.min(2, name.length)).toUpperCase();
}

Color _avatarColor(String userId) {
  final hash = userId.codeUnits.fold(0, (a, b) => a + b);
  return SrColors.avatarPalette[hash % SrColors.avatarPalette.length];
}
