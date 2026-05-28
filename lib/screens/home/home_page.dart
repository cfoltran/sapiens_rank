import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sapiens_rank/common/theme/colors.dart';
import 'package:sapiens_rank/screens/today/today_page.dart';
import 'package:sapiens_rank/screens/world/world_page.dart';

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
          const _PlaceholderTab(label: 'Fight'),
          const _PlaceholderTab(label: 'Profile'),
        ],
      ),
      bottomNavigationBar: _SrTabBar(selected: _tab, onTap: _switchTab),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SrColors.bg,
      body: Center(
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: SrColors.textMuted),
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
                    color: const Color(0xC61D1A14),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: SrColors.lineStrong),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x80000000),
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
