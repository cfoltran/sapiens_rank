import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/screens/fight/fight_page.dart';
import 'package:sapiens_rank/screens/today/today_page.dart';
import 'package:sapiens_rank/screens/world/world_page.dart';
import 'package:sapiens_rank/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  void _switchTab(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: SrColors.bg,
      body: IndexedStack(
        index: _tab,
        children: [
          TodayPage(onNavigateToWorld: () => _switchTab(1)),
          const WorldPage(),
          const FightPage(),
          const _ProfileTab(),
        ],
      ),
      bottomNavigationBar: _SrTabBar(selected: _tab, onTap: _switchTab),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return Scaffold(
      backgroundColor: SrColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          children: [
            Text(
              'Profile',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: SrColors.text,
              ),
            ),
            const SizedBox(height: 40),
            _SettingsRow(
              icon: Icons.logout,
              label: 'Sign out',
              color: SrColors.rose,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: SrColors.bgElev,
                    title: Text(
                      'Sign out?',
                      style: TextStyle(color: SrColors.text),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text('Cancel', style: TextStyle(color: SrColors.textMuted)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text('Sign out', style: TextStyle(color: SrColors.rose)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) auth.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? SrColors.text;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: SrColors.tintXs,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SrColors.line),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: c,
              ),
            ),
          ],
        ),
      ),
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
    _TabItem(label: 'Fight', icon: Icons.flash_on),
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
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: SrColors.navBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: SrColors.lineStrong),
                    boxShadow: const [
                      BoxShadow(
                        color: SrColors.shadow,
                        blurRadius: 40,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Inset highlight at top
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(15),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                        ),
                      ),
                      // Sliding active pill
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: 6,
                        bottom: 6,
                        left: 6 + selected * tabW,
                        width: tabW,
                        child: Container(
                          decoration: BoxDecoration(
                            color: SrColors.bgElev2,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: SrColors.lineStrong),
                          ),
                        ),
                      ),
                      // Tab buttons
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
                                  AnimatedTheme(
                                    data: Theme.of(context),
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      _tabs[i].icon,
                                      size: 20,
                                      color: i == selected
                                          ? SrColors.lime
                                          : SrColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _tabs[i].label,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: i == selected
                                          ? SrColors.lime
                                          : SrColors.textMuted,
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
