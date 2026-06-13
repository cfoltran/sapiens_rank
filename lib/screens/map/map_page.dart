import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:sapiens_rank/common/helpers/guild_visuals.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/screens/map/cubit/map_cubit.dart';
import 'package:sapiens_rank/screens/map/cubit/map_state.dart';
import 'package:sapiens_rank/screens/map/widgets/attack_sheet.dart';
import 'package:sapiens_rank/screens/map/widgets/battle_sheet.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/screens/guild/guild_page.dart';
import 'package:sapiens_rank/screens/map/widgets/hex_grid_painter.dart';
import 'package:sapiens_rank/screens/map/widgets/rules_sheet.dart';
import 'package:sapiens_rank/screens/map/widgets/territory_info_sheet.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapCubit()..load(),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _entranceController;
  late final AnimationController _bounceController;
  late final AnimationController _cameraController;
  late final TransformationController _transformController;
  late final double _fitScale;
  Animation<Matrix4>? _cameraAnimation;
  Size _viewport = Size.zero;
  Offset? _doubleTapPos;
  (int, int)? _bounceHex;
  bool _introPlayed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _cameraController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        )..addListener(() {
          final anim = _cameraAnimation;
          if (anim != null) _transformController.value = anim.value;
        });

    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    _fitScale =
        math.min(size.width / canvasWidth, size.height / canvasHeight) * 0.92;
    _transformController = TransformationController(
      Matrix4.diagonal3Values(_fitScale, _fitScale, 1),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    _bounceController.dispose();
    _cameraController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  Matrix4 _matrixFor(Offset sceneCenter, double scale) {
    return Matrix4.identity()
      ..translateByDouble(
        _viewport.width / 2 - sceneCenter.dx * scale,
        _viewport.height / 2 - sceneCenter.dy * scale,
        0,
        1,
      )
      ..scaleByDouble(scale, scale, 1, 1);
  }

  void _animateCameraTo(
    Matrix4 target, {
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeInOutCubic,
  }) {
    _cameraAnimation = Matrix4Tween(
      begin: _transformController.value,
      end: target,
    ).animate(CurvedAnimation(parent: _cameraController, curve: curve));
    _cameraController
      ..duration = duration
      ..forward(from: 0);
  }

  void _maybePlayIntro() {
    if (_introPlayed) return;
    _introPlayed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entranceController.forward();
      final center = Offset(canvasWidth / 2, canvasHeight / 2);
      _transformController.value = _matrixFor(center, _fitScale * 1.4);
      _animateCameraTo(
        _matrixFor(center, _fitScale),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _handleDoubleTap() {
    final pos = _doubleTapPos;
    if (pos == null) return;
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    if (currentScale > _fitScale * 1.3) {
      _animateCameraTo(
        _matrixFor(Offset(canvasWidth / 2, canvasHeight / 2), _fitScale),
      );
    } else {
      final scene = _transformController.toScene(pos);
      _animateCameraTo(_matrixFor(scene, _fitScale * 1.7));
    }
  }

  void _recenter(MapData data) {
    HapticFeedback.lightImpact();
    final mine = data.ownTerritories;
    Offset target;
    double scale;
    if (mine.isEmpty) {
      target = Offset(canvasWidth / 2, canvasHeight / 2);
      scale = _fitScale;
    } else {
      var sum = Offset.zero;
      for (final t in mine) {
        sum += hexCenter(t.gridX, t.gridY);
      }
      target = sum / mine.length.toDouble();
      scale = _fitScale * 1.25;
    }
    _animateCameraTo(_matrixFor(target, scale));
  }

  void _onTap(BuildContext context, TapUpDetails details, MapData data) {
    final canvasPoint = _transformController.toScene(details.localPosition);
    final hex = canvasPointToHex(canvasPoint);
    if (hex == null) return;

    final (col, row) = hex;
    final territory = data.territoryAt(col, row);
    if (territory == null) return;

    HapticFeedback.lightImpact();
    setState(() => _bounceHex = (col, row));
    _bounceController.forward(from: 0);

    final isAttackable = data.attackableTerritoryIds.contains(territory.id);
    final activeAttack = data.activeAttackOn(territory.id);
    final isMine =
        territory.ownerGuildId == data.myGuildId && data.myGuildId != null;

    if (activeAttack != null) {
      BattleSheet.show(
        context,
        attack: activeAttack,
        territory: territory,
        territories: data.territories,
        myGuildId: data.myGuildId,
      );
      return;
    }

    if (isMine) return;

    if (!isAttackable) {
      if (!territory.isNeutral) {
        TerritoryInfoSheet.show(context, territory: territory);
      } else if (data.myGuildId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Join a guild to attack territories')),
        );
      }
      return;
    }

    HapticFeedback.mediumImpact();
    final cubit = context.read<MapCubit>();
    AttackSheet.show(
      context,
      territory: territory,
      onConfirm: ({required metric, required endsAt}) => cubit.launchAttack(
        territoryId: territory.id,
        defenderGuildId: territory.ownerGuildId,
        metric: metric,
        endsAt: endsAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.srBg,
      body: BlocBuilder<MapCubit, DataState<MapData>>(
        builder: (context, state) {
          return state.when(
            success: (data) => _MapCanvas(
              data: data,
              transformController: _transformController,
              pulseController: _pulseController,
              entranceController: _entranceController,
              bounceController: _bounceController,
              bounceHex: _bounceHex,
              minScale: math.min(_fitScale * 0.8, 1.0),
              maxScale: math.max(_fitScale * 2, 2.0),
              onLayout: _handleLayout,
              onTapUp: (details) => _onTap(context, details, data),
              onDoubleTapDown: (details) =>
                  _doubleTapPos = details.localPosition,
              onDoubleTap: _handleDoubleTap,
              onRecenter: () => _recenter(data),
              onOpenRules: () => _openRules(context),
              onOpenGuild: () => _openGuild(context),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load map',
                    style: TextStyle(color: context.srTextMuted),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.read<MapCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openRules(BuildContext context) {
    RulesSheet.show(context);
  }

  Future<void> _openGuild(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const GuildPage()),
    );
    if (context.mounted) context.read<MapCubit>().load();
  }

  void _handleLayout(Size size) {
    _viewport = size;
    _maybePlayIntro();
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({
    required this.data,
    required this.transformController,
    required this.pulseController,
    required this.entranceController,
    required this.bounceController,
    required this.bounceHex,
    required this.minScale,
    required this.maxScale,
    required this.onLayout,
    required this.onTapUp,
    required this.onDoubleTapDown,
    required this.onDoubleTap,
    required this.onRecenter,
    required this.onOpenRules,
    required this.onOpenGuild,
  });

  final MapData data;
  final TransformationController transformController;
  final AnimationController pulseController;
  final AnimationController entranceController;
  final AnimationController bounceController;
  final (int, int)? bounceHex;
  final double minScale;
  final double maxScale;
  final ValueChanged<Size> onLayout;
  final ValueChanged<TapUpDetails> onTapUp;
  final ValueChanged<TapDownDetails> onDoubleTapDown;
  final VoidCallback onDoubleTap;
  final VoidCallback onRecenter;
  final VoidCallback onOpenRules;
  final VoidCallback onOpenGuild;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        onLayout(constraints.biggest);
        return AnimatedBuilder(
          animation: Listenable.merge([
            pulseController,
            entranceController,
            bounceController,
          ]),
          builder: (context, _) {
            return Stack(
              children: [
                SizedBox.expand(
                  child: GestureDetector(
                    onTapUp: onTapUp,
                    onDoubleTapDown: onDoubleTapDown,
                    onDoubleTap: onDoubleTap,
                    child: InteractiveViewer(
                      transformationController: transformController,
                      constrained: false,
                      minScale: minScale,
                      maxScale: maxScale,
                      boundaryMargin: EdgeInsets.all(constraints.maxWidth),
                      child: CustomPaint(
                        size: Size(canvasWidth, canvasHeight),
                        painter: HexGridPainter(
                          territories: data.territories,
                          attackableTerritoryIds: data.attackableTerritoryIds,
                          activeAttacks: data.activeAttacks,
                          myGuildId: data.myGuildId,
                          animationValue: pulseController.value,
                          entranceValue: entranceController.value,
                          bounceValue: bounceController.value,
                          bounceHex: bounceHex,
                          neutralColor: context.isDark
                              ? const Color(0xFF1B2B1C)
                              : const Color(0xFFB8C9B0),
                          borderColor: context.isDark
                              ? const Color(0xFF3A3A3A)
                              : const Color(0xFFBBBBBB),
                          attackableHighlight: context.srLime,
                          textColor: context.isDark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 14,
                  child: Row(
                    children: [
                      _RoundButton(
                        icon: Icons.info_outline,
                        onTap: onOpenRules,
                      ),
                      const SizedBox(width: 8),
                      _GuildBadge(
                        myGuildId: data.myGuildId,
                        territories: data.territories,
                        onTap: onOpenGuild,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                  child: _RoundButton(
                    icon: Icons.my_location,
                    onTap: onRecenter,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.srBgElev.withAlpha(220),
          shape: BoxShape.circle,
          border: Border.all(color: context.srLine),
          boxShadow: [
            BoxShadow(
              color: context.srShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: context.srTextMuted),
      ),
    );
  }
}

class _GuildBadge extends StatelessWidget {
  const _GuildBadge({
    required this.myGuildId,
    required this.territories,
    required this.onTap,
  });

  final String? myGuildId;
  final List<Territory> territories;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    TerritoryGuild? guild;
    if (myGuildId != null) {
      for (final t in territories) {
        if (t.ownerGuildId == myGuildId && t.guilds != null) {
          guild = t.guilds;
          break;
        }
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.srBgElev.withAlpha(220),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.srLine),
          boxShadow: [
            BoxShadow(
              color: context.srShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (guild != null) ...[
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: guildColorFromHex(guild.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                guild.name,
                style: TextStyle(
                  color: context.srText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Icon(Icons.group_add, size: 16, color: context.srLimeText),
              const SizedBox(width: 6),
              Text(
                'Guild',
                style: TextStyle(
                  color: context.srLimeText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: context.srTextDim),
          ],
        ),
      ),
    );
  }
}
