import 'package:flutter/material.dart';

import 'core/app_info.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/history_service.dart';
import 'services/ocr_service.dart';
import 'services/settings_service.dart';
import 'services/ussd_service.dart';
import 'state/app_controller.dart';
import 'widgets/game_backdrop.dart';

/// Shared service bundle created once in main().
class AppServices {
  AppServices({
    required this.settings,
    required this.history,
    required this.ocr,
    required this.ussd,
  });

  final SettingsService settings;
  final HistoryService history;
  final OcrService ocr;
  final UssdService ussd;
}

/// Root widget: theme switching plus the two-section shell
/// (Home and Settings kept alive by an IndexedStack).
class SaricomApp extends StatelessWidget {
  const SaricomApp({
    super.key,
    required this.appController,
    required this.services,
  });

  final AppController appController;
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appController,
      builder: (context, _) {
        return MaterialApp(
          title: '$appName — $appSubtitle',
          debugShowCheckedModeBanner: false,
          locale: appController.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: switch (appController.themeMode) {
            AppThemeMode.system => ThemeMode.system,
            AppThemeMode.light => ThemeMode.light,
            AppThemeMode.dark => ThemeMode.dark,
          },
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: _Shell(appController: appController, services: services),
        );
      },
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell({required this.appController, required this.services});

  final AppController appController;
  final AppServices services;

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return GameBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(
              appController: widget.appController,
              ocrService: widget.services.ocr,
              ussdService: widget.services.ussd,
            ),
            SettingsScreen(
              appController: widget.appController,
              ussdService: widget.services.ussd,
            ),
          ],
        ),
        bottomNavigationBar: _BottomNavBar(
          selectedIndex: _index,
          onSelected: (index) => setState(() => _index = index),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Two-item bottom navigation: a light-green pill marks the active
/// section, while the inactive one stays neutral gray.
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const List<_NavItem> _items = [
    _NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final light = theme.brightness == Brightness.light;
    final l10n = AppLocalizations.of(context);
    final items = [
      _NavItem(
        icon: _items[0].icon,
        selectedIcon: _items[0].selectedIcon,
        label: l10n.homeTab,
      ),
      _NavItem(
        icon: _items[1].icon,
        selectedIcon: _items[1].selectedIcon,
        label: l10n.settingsTab,
      ),
    ];

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: light
                ? AppColors.gameInkLight.withValues(alpha: 0.22)
                : colorScheme.outline,
            width: 2,
          ),
          boxShadow: AppShadows.of(context),
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0 : 4,
                    right: i == items.length - 1 ? 0 : 4,
                  ),
                  child: _NavBarItem(
                    item: items[i],
                    selected: i == selectedIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final light = theme.brightness == Brightness.light;

    final selectedBackground = light
        ? AppColors.primaryLight
        : AppColors.primaryDark;
    final selectedForeground = light ? Colors.white : const Color(0xFF062315);
    final inactiveColor = colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 50,
            decoration: BoxDecoration(
              color: selected ? selectedBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: selected
                  ? Border.all(
                      color: light
                          ? AppColors.primaryDarkGreen
                          : AppColors.borderDark,
                      width: 1.6,
                    )
                  : null,
              boxShadow: selected ? AppShadows.of(context) : const [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Icon(
                    key: ValueKey(selected),
                    selected ? item.selectedIcon : item.icon,
                    size: 23,
                    color: selected ? selectedForeground : inactiveColor,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: selected ? selectedForeground : inactiveColor,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
