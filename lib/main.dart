import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/pvforge_theme.dart';
import 'widgets/app_bottom_navigation.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();
void main() => runApp(const CortekSolarApp());

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

  // เดิมใช้รูปภาพเป็นพื้นหลัง (Image.asset) แต่รูปโหลดช้าทำให้เห็นจอขาวก่อน
  // สักครู่ทุกครั้งที่เปิดแอป — เปลี่ยนกลับมาใช้พื้นไล่สีขาวไปฟ้าธรรมดาแทน
  // (ไม่ต้องโหลดไฟล์รูปเลย ขึ้นทันที)
  Widget _background(Widget child) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              PVForgeColors.backgroundHighlight,
              PVForgeColors.primaryLight,
            ],
          ),
        ),
        child: child,
      );

  // เดิมเป็น modal bottom sheet (_showThemePicker) ลอยขึ้นมา ตอนนี้เปลี่ยน
  // ไปเป็นหน้าเต็มจอ (SettingsScreen) เหมือนเมนูอื่น ๆ แล้วตามที่ขอ — เปิด
  // ผ่าน appNavigatorKey เพื่อให้อยู่ในสแต็กเดียวกับหน้าอื่นที่ AppBottomNavigation
  // ใช้อยู่ (จะได้เห็นแถบเมนูล่างค้างอยู่เหมือนหน้าอื่นด้วย)
  void _openSettings() {
    appNavigatorKey.currentState?.push(MaterialPageRoute(
      builder: (_) => SettingsScreen(
        currentMode: mode,
        onModeChanged: (value) => setState(() => mode = value),
      ),
    ));
  }

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
                      onSettings: _openSettings),
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
