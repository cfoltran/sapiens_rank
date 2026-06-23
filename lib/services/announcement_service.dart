import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sapiens_rank/models/announcement.dart';

/// Remote in-app announcements. Active rows are fetched from Supabase;
/// dismissals are remembered locally (by id) so a closed banner stays closed.
class AnnouncementService {
  AnnouncementService._();
  static final AnnouncementService instance = AnnouncementService._();

  final _db = Supabase.instance.client;
  final _log = Logger('AnnouncementService');

  static const _kDismissedKey = 'dismissed_announcements';

  /// Active, in-window announcements the user hasn't dismissed. Returns an
  /// empty list on any failure so it never breaks the Today screen load.
  Future<List<Announcement>> getActive() async {
    try {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      final rows =
          await _db
                  .from('announcements')
                  .select()
                  .eq('active', true)
                  .or('starts_at.is.null,starts_at.lte.$nowIso')
                  .or('ends_at.is.null,ends_at.gte.$nowIso')
                  .order('created_at', ascending: false)
              as List;

      final prefs = await SharedPreferences.getInstance();
      final dismissed =
          prefs.getStringList(_kDismissedKey)?.toSet() ?? const {};

      return rows
          .map((r) => Announcement.fromJson(r as Map<String, dynamic>))
          .where((a) => !dismissed.contains(a.id))
          .toList();
    } catch (e) {
      _log.warning('getActive failed: $e');
      return const [];
    }
  }

  Future<void> dismiss(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getStringList(_kDismissedKey) ?? [];
    if (!dismissed.contains(id)) {
      dismissed.add(id);
      await prefs.setStringList(_kDismissedKey, dismissed);
    }
  }
}
