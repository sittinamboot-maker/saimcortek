import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cortek_solar_designer/main.dart';
import 'package:cortek_solar_designer/models/solar_project.dart';

void main() {
  testWidgets('shows the solar designer home screen', (tester) async {
    await tester.pumpWidget(const CortekSolarApp());
    expect(find.byType(Image), findsWidgets);
    expect(find.text('เข้าสู่ระบบ'), findsWidgets);
  });

  testWidgets('opens settings and company workspace menu', (tester) async {
    await tester.pumpWidget(const CortekSolarApp());
    await tester.pump(const Duration(milliseconds: 300));
    final demoButton = find.text('ทดลองใช้ DEMO โดยไม่สมัครสมาชิก');
    await tester.ensureVisible(demoButton);
    await tester.tap(demoButton);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('ตั้งค่า'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Company Workspace'), findsOneWidget);
    expect(find.text('ธีมมาตรฐาน PVForge'), findsOneWidget);
  });

  test('sizes the battery from nightly consumption', () {
    final project = SolarProject(
      hasBattery: true,
      nightKwhPerDay: 7.6,
      batteryDepthOfDischarge: 80,
      batteryEfficiency: 95,
    );

    expect(project.nightKwhPerDay, 7.6);
    expect(project.recommendedBatteryCapacity, 10);
  });

  test('calculates panels that fit the roof', () {
    final project = SolarProject(roofArea: 40, panelWatt: 620);
    expect(project.panelsThatFitRoof, 14);
    expect(project.roofLimitedSystemKwp, closeTo(8.68, 0.001));
  });

  test('sizes panels to cover daytime load and a full battery charge', () {
    final project = SolarProject(
      hasBattery: true,
      dayKwhPerDay: 10,
      nightKwhPerDay: 7.6,
      batteryCapacityKwh: 10,
      batteryEfficiency: 95,
    );

    expect(project.solarDailyEnergyTarget, closeTo(20.526, 0.001));
    expect(
      project.estimatedDailyProduction,
      greaterThanOrEqualTo(project.solarDailyEnergyTarget),
    );
  });

  test('uses stored air-conditioner energy for an air solar system', () {
    final project = SolarProject(
      systemType: 'Air solar',
      airConditionerBtu: 18000,
      airConditionerCount: 2,
      airConditionerPowerKw: 1.7,
      airConditionerHoursPerDay: 6,
    );

    expect(project.isAirSolarSystem, isTrue);
    expect(project.airConditionerDailyKwh, closeTo(20.4, 0.001));
    expect(project.solarDailyEnergyTarget, closeTo(20.4, 0.001));
  });
}
