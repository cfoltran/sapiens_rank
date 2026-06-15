import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/animation.dart';
import 'package:sapiens_rank/common/helpers/guild_visuals.dart';
import 'package:sapiens_rank/models/guild_models.dart';
import 'package:sapiens_rank/screens/map/cubit/map_state.dart';
import 'package:sapiens_rank/screens/map/game/ambiance_layer.dart';
import 'package:sapiens_rank/screens/map/game/attack_fx.dart';
import 'package:sapiens_rank/screens/map/game/hex_geometry.dart';
import 'package:sapiens_rank/screens/map/game/hex_tile.dart';

class MapColors {
  const MapColors({
    required this.neutral,
    required this.border,
    required this.highlight,
    required this.text,
    required this.ambient,
  });

  final Color neutral;
  final Color border;
  final Color highlight;
  final Color text;
  final Color ambient;
}

class _CamMove {
  _CamMove({
    required this.fromPos,
    required this.toPos,
    required this.fromZoom,
    required this.toZoom,
    required this.duration,
    required this.curve,
  });

  final Vector2 fromPos;
  final Vector2 toPos;
  final double fromZoom;
  final double toZoom;
  final double duration;
  final Curve curve;
  double elapsed = 0;
}

class MapGame extends FlameGame with ScaleDetector, DoubleTapDetector {
  MapGame({required this.colors});

  MapColors colors;

  void Function(Territory)? onTerritoryTapHandler;

  final Map<String, HexTileComponent> _tiles = {};
  final Map<String, SiegeRing> _sieges = {};
  MapData? _pending;
  bool _built = false;

  double _clock = 0;
  double _fitZoom = 1;
  _CamMove? _camMove;
  double _startZoom = 1;
  Vector2? _doubleTapWorld;

  double get clock => _clock;

  /// 0..1 breathing value, ~1.8s period (mirrors the old pulse controller).
  double get breath => 0.5 - 0.5 * math.cos(2 * math.pi * (_clock / 1.8 % 1.0));

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    world.add(AmbianceLayer(color: colors.ambient));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.x == 0 || size.y == 0) return;
    _fitZoom = math.min(size.x / canvasWidth, size.y / canvasHeight) * 0.92;
    if (!_built && _pending != null) _buildInitial(_pending!);
  }

  void onTerritoryTap(Territory t) => onTerritoryTapHandler?.call(t);

  void applyData(MapData data) {
    if (!_built) {
      _pending = data;
      if (_fitZoom > 0 && isMounted) _buildInitial(data);
      return;
    }
    _diff(data);
  }

  void _buildInitial(MapData data) {
    _built = true;
    _pending = null;
    final attackable = data.attackableTerritoryIds;
    final maxDist = math.sqrt(
      gridCols * gridCols / 4.0 + gridRows * gridRows / 4.0,
    );

    for (final t in data.territories) {
      final mine = _isMine(t, data);
      final delay = _delayFor(t.gridX, t.gridY, maxDist);
      final tile = HexTileComponent(
        col: t.gridX,
        row: t.gridY,
        entranceDelay: delay,
        territory: t,
        faceColor: _faceColor(t, mine),
        isMine: mine,
        attackable: attackable.contains(t.id),
        label: t.guilds == null ? '' : guildInitials(t.guilds!.name),
      );
      _tiles[t.id] = tile;
      world.add(tile);
    }
    _syncSieges(data);

    final center = Vector2(canvasWidth / 2, canvasHeight / 2);
    camera.viewfinder
      ..position = center
      ..zoom = _fitZoom * 1.4;
    _animateCamera(center, _fitZoom, duration: 0.9, curve: Curves.easeOutCubic);
  }

  void _diff(MapData data) {
    final attackable = data.attackableTerritoryIds;
    for (final t in data.territories) {
      final tile = _tiles[t.id];
      final mine = _isMine(t, data);
      if (tile == null) continue;
      tile.syncState(
        t,
        _faceColor(t, mine),
        mine,
        attackable.contains(t.id),
        t.guilds == null ? '' : guildInitials(t.guilds!.name),
      );
    }
    _syncSieges(data);
  }

  void _syncSieges(MapData data) {
    final activeByTerritory = {
      for (final a in data.activeAttacks) a.territoryId: a,
    };
    _sieges.removeWhere((territoryId, ring) {
      if (!activeByTerritory.containsKey(territoryId)) {
        ring.removeFromParent();
        return true;
      }
      return false;
    });
    activeByTerritory.forEach((territoryId, attack) {
      if (_sieges.containsKey(territoryId)) return;
      final tile = _tiles[territoryId];
      if (tile == null) return;
      final ring = SiegeRing(
        center: tile.position.clone(),
        startsAt: attack.startsAt,
        endsAt: attack.endsAt,
      );
      _sieges[territoryId] = ring;
      world.add(ring);
    });
  }

  bool _isMine(Territory t, MapData data) =>
      data.myGuildId != null && t.ownerGuildId == data.myGuildId;

  Color _faceColor(Territory t, bool mine) {
    if (t.isNeutral) return colors.neutral;
    final raw = t.guilds?.color ?? '#888888';
    return guildColorFromHex(raw).withAlpha(mine ? 230 : 180);
  }

  double _delayFor(int c, int r, double maxDist) {
    final dc = c - gridCols / 2;
    final dr = r - gridRows / 2;
    return math.sqrt(dc * dc + dr * dr) / maxDist * 0.55;
  }

  void fitAll() =>
      _animateCamera(Vector2(canvasWidth / 2, canvasHeight / 2), _fitZoom);

  void focusOnMine(List<Territory> mine) {
    if (mine.isEmpty) {
      fitAll();
      return;
    }
    var sum = Vector2.zero();
    for (final t in mine) {
      sum += hexCenter(t.gridX, t.gridY).toVector2();
    }
    _animateCamera(sum / mine.length.toDouble(), _fitZoom * 1.25);
  }

  void _animateCamera(
    Vector2 target,
    double zoom, {
    double duration = 0.6,
    Curve curve = Curves.easeInOutCubic,
  }) {
    _camMove = _CamMove(
      fromPos: camera.viewfinder.position.clone(),
      toPos: target,
      fromZoom: camera.viewfinder.zoom,
      toZoom: zoom,
      duration: duration,
      curve: curve,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    final move = _camMove;
    if (move != null) {
      move.elapsed += dt;
      final e = move.curve.transform(
        (move.elapsed / move.duration).clamp(0.0, 1.0),
      );
      camera.viewfinder
        ..position = move.fromPos + (move.toPos - move.fromPos) * e
        ..zoom = move.fromZoom + (move.toZoom - move.fromZoom) * e;
      if (move.elapsed >= move.duration) _camMove = null;
    }
  }

  @override
  void onScaleStart(ScaleStartInfo info) {
    _camMove = null;
    _startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final scale = info.scale.global;
    if ((scale.y - 1).abs() > 0.01) {
      camera.viewfinder.zoom = (_startZoom * scale.y).clamp(
        _fitZoom * 0.6,
        _fitZoom * 2.5,
      );
    } else {
      final delta = info.delta.global;
      camera.viewfinder.position += -delta / camera.viewfinder.zoom;
    }
  }

  @override
  void onDoubleTapDown(TapDownInfo info) {
    _doubleTapWorld = camera.globalToLocal(info.eventPosition.widget);
  }

  @override
  void onDoubleTap() {
    final zoomedIn = camera.viewfinder.zoom > _fitZoom * 1.3;
    if (zoomedIn) {
      fitAll();
    } else {
      final target =
          _doubleTapWorld ?? Vector2(canvasWidth / 2, canvasHeight / 2);
      _animateCamera(target, _fitZoom * 1.7);
    }
  }
}
