import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/demo_screen.dart';
import 'screens/home_screen.dart';
import 'screens/workspace_screen.dart';
import 'theme/pvforge_theme.dart';
import 'widgets/app_bottom_navigation.dart';
import 'widgets/pvforge_components.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();
void main() => runApp(const CortekSolarApp());

enum AppVisualMode { warm, monochrome }

class CortekSolarApp extends StatefulWidget {
  const CortekSolarApp({super.key});
  @override
  State<CortekSolarApp> createState() => _CortekSolarAppState();
}

class _CortekSolarAppState extends State<CortekSolarApp> {
  AppVisualMode mode = AppVisualMode.warm;
  bool authenticated = false;
  bool demoMode = false;

  ThemeData _theme() {
    final mono = mode == AppVisualMode.monochrome;
    return buildPVForgeTheme(monochrome: mono);
  }

  Widget _background(Widget child) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/branding/pvforge_app_background.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
            filterQuality: FilterQuality.high,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: .16),
                  Colors.white.withValues(alpha: .42),
                  Colors.white.withValues(alpha: .10),
                ],
              ),
            ),
          ),
          child,
        ],
      );

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(shrinkWrap: true, children: [
                const Text('เลือกโทนสีแอป',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                ListTile(
                  leading: const GradientIconBadge(
                      icon: Icons.business_outlined,
                      color: PVForgeColors.primary),
                  title: const Text('Company Workspace'),
                  subtitle: const Text('บริษัท แพ็กเกจ และสมาชิก'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    appNavigatorKey.currentState?.push(MaterialPageRoute(
                        builder: (_) => const WorkspaceScreen()));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const GradientIconBadge(
                      text: 'D', color: PVForgeColors.warning),
                  title: const Text('DEMO'),
                  subtitle: const Text('ทดลองออกแบบระบบด้วยข้อมูลตัวอย่าง'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    appNavigatorKey.currentState?.push(
                        MaterialPageRoute(builder: (_) => const DemoScreen()));
                  },
                ),
                const Divider(),
                _themeChoice(
                    sheetContext, AppVisualMode.warm, 'ธีมมาตรฐาน PVForge'),
                _themeChoice(sheetContext, AppVisualMode.monochrome, 'ขาวดำ'),
              ]))),
    );
  }

  Widget _themeChoice(
          BuildContext sheetContext, AppVisualMode value, String label) =>
      ListTile(
        leading: Icon(mode == value
            ? Icons.radio_button_checked
            : Icons.radio_button_off),
        title: Text(label),
        onTap: () {
          setState(() => mode = value);
          Navigator.pop(sheetContext);
        },
      );

  @override
  Widget build(BuildContext context) => MaterialApp(
        navigatorKey: appNavigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'CORTek Solar Designer',
        theme: _theme(),
        builder: (context, child) {
          if (!authenticated) {
            return _background(child ?? const SizedBox.shrink());
          }
          if (MediaQuery.viewInsetsOf(context).bottom > 0) {
            return _background(child ?? const SizedBox.shrink());
          }
          final content = Stack(
            fit: StackFit.expand,
            children: [
              child ?? const SizedBox.shrink(),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: AppBottomNavigation(
                      navigatorKey: appNavigatorKey,
                      onSettings: () {
                        final navigatorContext = appNavigatorKey.currentContext;
                        if (navigatorContext != null) {
                          _showThemePicker(navigatorContext);
                        }
                      }),
                ),
              ),
            ],
          );
          final decoratedContent = _background(content);
          if (mode == AppVisualMode.warm) return decoratedContent;
          return ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              .2126,
              .7152,
              .0722,
              0,
              0,
              .2126,
              .7152,
              .0722,
              0,
              0,
              .2126,
              .7152,
              .0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: decoratedContent,
          );
        },
        home: authenticated
            ? const HomeScreen()
            : AuthScreen(
                onSignedIn: () => setState(() {
                  authenticated = true;
                  demoMode = false;
                }),
                onDemo: () => setState(() {
                  authenticated = true;
                  demoMode = true;
                }),
              ),
      );
}
