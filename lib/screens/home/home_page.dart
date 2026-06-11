import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/sr_theme.dart';
import 'package:sapiens_rank/screens/challenge/challenge_page.dart';
import 'package:sapiens_rank/screens/challenge/sheets/invite_sheet.dart';
import 'package:sapiens_rank/screens/challenge/sheets/result_sheet.dart';
import 'package:sapiens_rank/screens/map/map_page.dart';
import 'package:sapiens_rank/screens/profile/profile_page.dart';
import 'package:sapiens_rank/screens/today/today_page.dart';
import 'package:sapiens_rank/screens/world/world_page.dart';
import 'package:sapiens_rank/services/messaging_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _tab;
  Key _challengeKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    MessagingService.instance.listenForTokenRefresh();
    MessagingService.instance.saveOrRequestToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      MessagingService.instance.initialize(
        context,
        onChallengeInvite: _handleChallengeInvite,
        onChallengeResult: _handleChallengeResult,
      );
    });
  }

  Future<void> _handleChallengeInvite(String challengeId) async {
    _switchTab(2);
    final responded = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InviteSheet(challengeId: challengeId),
    );
    if (responded == true && mounted) {
      setState(() => _challengeKey = UniqueKey());
    }
  }

  void _handleChallengeResult(String challengeId) {
    _switchTab(2);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResultSheet(challengeId: challengeId),
    );
  }

  void _switchTab(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: context.srBg,
      body: IndexedStack(
        index: _tab,
        children: [
          TodayPage(onNavigateToWorld: () => _switchTab(1)),
          const WorldPage(),
          ChallengePage(key: _challengeKey),
          const MapPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: _SrTabBar(selected: _tab, onTap: _switchTab),
    );
  }
}

class _SrTabBar extends StatelessWidget {
  const _SrTabBar({required this.selected, required this.onTap});

  final int selected;
  final ValueChanged<int> onTap;

  static const _tabs = [
    _TabItem(label: 'Today', icon: Icons.auto_awesome),
    _TabItem(label: 'World', icon: Icons.public),
    _TabItem(label: 'Challenge', icon: Icons.flash_on),
    _TabItem(label: 'Map', icon: Icons.map),
    _TabItem(label: 'Profile', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottomPad),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final totalW = constraints.maxWidth;
          final tabW = (totalW - 12) / _tabs.length;

          return SizedBox(
            height: 68,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.srNavBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: context.srLineStrong),
                    boxShadow: [
                      BoxShadow(
                        color: context.srShadow,
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? Colors.white.withAlpha(15)
                                : Colors.black.withAlpha(8),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: 6,
                        bottom: 6,
                        left: 6 + selected * tabW,
                        width: tabW,
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.srBgElev2,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: context.srLineStrong),
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(
                          _tabs.length,
                          (i) => Expanded(
                            child: GestureDetector(
                              onTap: () => onTap(i),
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _tabs[i].icon,
                                    size: 20,
                                    color: i == selected
                                        ? context.srLimeText
                                        : context.srTextMuted,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _tabs[i].label,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: i == selected
                                          ? context.srLimeText
                                          : context.srTextMuted,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabItem {
  const _TabItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
