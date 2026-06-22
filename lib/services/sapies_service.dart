import 'package:supabase_flutter/supabase_flutter.dart';

/// Wallet for Sapies — the game's reward currency. Balance is stored on
/// `profiles.sapies`; harvesting is a server-side RPC that reads the real
/// `scores.personal_score`, so the collectable amount can't be forged.
class SapiesService {
  SapiesService._();
  static final SapiesService instance = SapiesService._();

  final _db = Supabase.instance.client;

  String? get _uid => _db.auth.currentUser?.id;

  static String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Future<SapiesWallet> load({DateTime? date}) async {
    final uid = _uid;
    if (uid == null) return const SapiesWallet(balance: 0, harvestedToday: 0);
    final day = _dateStr(date ?? DateTime.now());

    final profileF = _db.from('profiles').select('sapies').eq('id', uid).single();
    final harvestF = _db
        .from('sapie_harvests')
        .select('harvested')
        .eq('user_id', uid)
        .eq('date', day)
        .maybeSingle();

    final profile = await profileF;
    final harvestRow = await harvestF;

    return SapiesWallet(
      balance: (profile['sapies'] as int?) ?? 0,
      harvestedToday: (harvestRow?['harvested'] as int?) ?? 0,
    );
  }

  /// Collects the uncollected part of [date]'s personal score. Returns the new
  /// balance and how much was collected (0 if already fully harvested).
  Future<HarvestResult> harvest({DateTime? date}) async {
    final uid = _uid;
    if (uid == null) return const HarvestResult(balance: 0, collected: 0);
    final day = _dateStr(date ?? DateTime.now());

    final rows =
        await _db.rpc('harvest_sapies', params: {'p_date': day}) as List;
    if (rows.isEmpty) return const HarvestResult(balance: 0, collected: 0);
    final row = rows.first as Map<String, dynamic>;
    return HarvestResult(
      balance: (row['balance'] as int?) ?? 0,
      collected: (row['collected'] as int?) ?? 0,
    );
  }
}

class SapiesWallet {
  const SapiesWallet({required this.balance, required this.harvestedToday});

  final int balance;
  final int harvestedToday;

  /// Coins still collectable for a given daily [score].
  int harvestableFor(int score) => (score - harvestedToday).clamp(0, score);
}

class HarvestResult {
  const HarvestResult({required this.balance, required this.collected});

  final int balance;
  final int collected;
}
