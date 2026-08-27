String _localImageAsset(String? value) =>
    value != null && value.startsWith('assets/')
        ? value
        : AirConditionerUnit.fallbackImageAsset;

class CustomEquipment {
  String name;
  double quantity;
  String unit;
  String note;
  String category;

  CustomEquipment({
    required this.name,
    this.quantity = 1,
    this.unit = 'ชิ้น',
    this.note = '',
    this.category = 'อุปกรณ์อื่น',
  });
}

class AirConditionerUnit {
  static const fallbackImageAsset =
      'assets/products/air_conditioners/daikin_ftkq09uv2s.jpg';
  final String brand, model, imageUrl;
  final int btu, quantity;
  final double powerKw, hoursPerDay;

  const AirConditionerUnit({
    required this.brand,
    required this.model,
    required this.btu,
    required this.quantity,
    required this.powerKw,
    required this.hoursPerDay,
    this.imageUrl = fallbackImageAsset,
  });

  double get dailyKwh => quantity * powerKw * hoursPerDay;

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'model': model,
        'btu': btu,
        'quantity': quantity,
        'powerKw': powerKw,
        'hoursPerDay': hoursPerDay,
        'imageUrl': imageUrl,
      };

  factory AirConditionerUnit.fromJson(Map<String, dynamic> json) =>
      AirConditionerUnit(
        brand: json['brand'] as String? ?? '',
        model: json['model'] as String? ?? '',
        btu: (json['btu'] as num?)?.toInt() ?? 9000,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        powerKw: (json['powerKw'] as num?)?.toDouble() ?? 0,
        hoursPerDay: (json['hoursPerDay'] as num?)?.toDouble() ?? 0,
        imageUrl: _localImageAsset(json['imageUrl'] as String?),
      );
}

class AirConditionerModelOption {
  final String brand, model, imageUrl;
  final int btu;
  final double powerKw;

  const AirConditionerModelOption({
    required this.brand,
    required this.model,
    required this.btu,
    required this.powerKw,
    this.imageUrl = AirConditionerUnit.fallbackImageAsset,
  });

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'model': model,
        'btu': btu,
        'powerKw': powerKw,
        'imageUrl': imageUrl,
      };

  factory AirConditionerModelOption.fromJson(Map<String, dynamic> json) =>
      AirConditionerModelOption(
        brand: json['brand'] as String? ?? '',
        model: json['model'] as String? ?? '',
        btu: (json['btu'] as num?)?.toInt() ?? 9000,
        powerKw: (json['powerKw'] as num?)?.toDouble() ?? 0,
        imageUrl: _localImageAsset(json['imageUrl'] as String?),
      );
}

class SolarProject {
  String id;
  DateTime updatedAt;
  bool calculationCompleted;
  String customerName;
  String projectName;
  String customerPhone;
  String installationAddress;
  // พิกัดที่ปักหมุดไว้บนแผนที่ (หน้า "สถานที่ติดตั้ง") — เป็น null ถ้ายังไม่
  // เคยปักหมุด
  double? installationLatitude;
  double? installationLongitude;
  // รูปแบบหลังคาที่เลือกไว้ในหน้า "ข้อมูลหลังคา" (เช่น "จั่ว", "ปั้นหยา")
  String roofType;
  // ระบบไฟฟ้าหน้างานที่เลือกไว้ในหน้า "ระบบไฟฟ้า" — "1 เฟส" หรือ "3 เฟส"
  String electricalPhase;
  // พาธไฟล์รูปภาพหน้างานที่ถ่าย/เลือกไว้ในเครื่อง (หน้า "รูปภาพหน้างาน")
  final List<String> sitePhotoPaths;
  String customerNote;
  double monthlyBill;
  double monthlyKwh;
  double dayKwhPerDay;
  double nightKwhPerDay;
  double roofArea;
  double roofWidth;
  double roofLength;
  String systemType;

  // Solar air-conditioner system.  The energy value is kept separately from
  // the home's normal load so its panel recommendation is easy to review.
  int airConditionerBtu;
  String airConditionerBrand;
  String airConditionerModel;
  String airConditionerImageUrl;
  int airConditionerCount;
  double airConditionerPowerKw;
  double airConditionerHoursPerDay;
  final List<AirConditionerUnit> airConditioners;
  final List<AirConditionerModelOption> customAirConditionerModels;

  // Battery storage
  bool hasBattery;
  double batteryCapacityKwh;
  double batteryDepthOfDischarge;
  double batteryEfficiency;
  double backupHours;
  bool sizeBatteryFromNightUsage;
  final List<CustomEquipment> customEquipment;

  String panelModel;
  double panelAreaM2;
  double panelWatt;
  double panelVoc;
  double panelVmp;
  double panelIsc;
  double panelImp;

  // ผู้ใช้สามารถปรับจำนวนแผง/String หรือจำนวน String เองในหน้าจัด String ได้
  // ถ้ามีค่านี้ (ไม่ใช่ null) ให้ใช้แทนค่าที่คำนวณอัตโนมัติ ทั้งระบบ (kWp,
  // พื้นที่หลังคา, ผลผลิตไฟ, BOQ ฯลฯ) จะได้อัพเดตตรงกันหมด — ค่านี้จะถูก
  // ล้าง (กลับไปคำนวณอัตโนมัติ) ทุกครั้งที่เปลี่ยนรุ่นแผงใหม่
  int? manualPanelCount;

  // Panel performance data
  double panelEfficiency;
  double panelTempCoeffVoc;
  double panelDegradation;

  double inverterKw;
  String inverterModel;
  double inverterMaxDcVoltage;
  double inverterMpptMin;
  double inverterMpptMax;
  double inverterMaxInputCurrent;
  int inverterMpptCount;

  // Inverter performance data
  double inverterEfficiency;
  double mpptEfficiency;

  double peakSunHours;

  // Detailed system losses
  double temperatureLoss;
  double soilingLoss;
  double dcCableLoss;
  double acCableLoss;
  double mismatchLoss;
  double shadingLoss;
  double otherLoss;

  SolarProject({
    String? id,
    DateTime? updatedAt,
    this.calculationCompleted = false,
    this.customerName = '',
    this.projectName = '',
    this.customerPhone = '',
    this.installationAddress = '',
    this.installationLatitude,
    this.installationLongitude,
    this.roofType = '',
    this.electricalPhase = '1 เฟส',
    List<String>? sitePhotoPaths,
    this.customerNote = '',
    this.monthlyBill = 3000,
    this.monthlyKwh = 450,
    this.dayKwhPerDay = 9,
    this.nightKwhPerDay = 6,
    this.roofArea = 40,
    this.roofWidth = 5,
    this.roofLength = 8,
    this.systemType = 'On-grid',
    this.airConditionerBtu = 9000,
    this.airConditionerBrand = 'Daikin',
    this.airConditionerModel = 'FTKQ09UV2S',
    this.airConditionerImageUrl = AirConditionerUnit.fallbackImageAsset,
    this.airConditionerCount = 1,
    this.airConditionerPowerKw = 0.8,
    this.airConditionerHoursPerDay = 8,
    List<AirConditionerUnit>? airConditioners,
    List<AirConditionerModelOption>? customAirConditionerModels,
    this.hasBattery = false,
    this.batteryCapacityKwh = 10,
    this.batteryDepthOfDischarge = 80,
    this.batteryEfficiency = 95,
    this.backupHours = 8,
    this.sizeBatteryFromNightUsage = true,
    List<CustomEquipment>? customEquipment,
    this.panelModel = 'Jinko Solar JKM620N-78HL4-V',
    this.panelAreaM2 = 2.795,
    this.panelWatt = 620,
    this.panelVoc = 49.5,
    this.panelVmp = 41.8,
    this.panelIsc = 15.2,
    this.panelImp = 14.4,
    this.panelEfficiency = 22.5,
    this.panelTempCoeffVoc = -0.25,
    this.panelDegradation = 0.4,
    this.manualPanelCount,
    this.inverterKw = 6,
    this.inverterModel = 'Deye SUN-6K-SG03LP1-EU',
    this.inverterMaxDcVoltage = 500,
    this.inverterMpptMin = 125,
    this.inverterMpptMax = 425,
    this.inverterMaxInputCurrent = 16,
    this.inverterMpptCount = 2,
    this.inverterEfficiency = 97.5,
    this.mpptEfficiency = 99.0,
    this.peakSunHours = 4.5,
    this.temperatureLoss = 5.0,
    this.soilingLoss = 3.0,
    this.dcCableLoss = 1.5,
    this.acCableLoss = 1.0,
    this.mismatchLoss = 2.0,
    this.shadingLoss = 3.0,
    this.otherLoss = 1.0,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        updatedAt = updatedAt ?? DateTime.now(),
        customEquipment = customEquipment ?? [],
        airConditioners = airConditioners ?? [],
        customAirConditionerModels = customAirConditionerModels ?? [],
        sitePhotoPaths = sitePhotoPaths ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'updatedAt': updatedAt.toIso8601String(),
        'calculationCompleted': calculationCompleted,
        'customerName': customerName,
        'projectName': projectName,
        'customerPhone': customerPhone,
        'installationAddress': installationAddress,
        'installationLatitude': installationLatitude,
        'installationLongitude': installationLongitude,
        'roofType': roofType,
        'electricalPhase': electricalPhase,
        'sitePhotoPaths': sitePhotoPaths,
        'customerNote': customerNote,
        'monthlyBill': monthlyBill,
        'monthlyKwh': monthlyKwh,
        'dayKwhPerDay': dayKwhPerDay,
        'nightKwhPerDay': nightKwhPerDay,
        'roofArea': roofArea,
        'roofWidth': roofWidth,
        'roofLength': roofLength,
        'systemType': systemType,
        'airConditionerBtu': airConditionerBtu,
        'airConditionerBrand': airConditionerBrand,
        'airConditionerModel': airConditionerModel,
        'airConditionerImageUrl': airConditionerImageUrl,
        'airConditionerCount': airConditionerCount,
        'airConditionerPowerKw': airConditionerPowerKw,
        'airConditionerHoursPerDay': airConditionerHoursPerDay,
        'airConditioners':
            airConditioners.map((unit) => unit.toJson()).toList(),
        'customAirConditionerModels':
            customAirConditionerModels.map((model) => model.toJson()).toList(),
        'hasBattery': hasBattery,
        'batteryCapacityKwh': batteryCapacityKwh,
        'batteryDepthOfDischarge': batteryDepthOfDischarge,
        'batteryEfficiency': batteryEfficiency,
        'backupHours': backupHours,
        'sizeBatteryFromNightUsage': sizeBatteryFromNightUsage,
        'panelModel': panelModel,
        'panelAreaM2': panelAreaM2,
        'panelWatt': panelWatt,
        'panelVoc': panelVoc,
        'panelVmp': panelVmp,
        'panelIsc': panelIsc,
        'panelImp': panelImp,
        'panelEfficiency': panelEfficiency,
        'panelTempCoeffVoc': panelTempCoeffVoc,
        'panelDegradation': panelDegradation,
        'manualPanelCount': manualPanelCount,
        'inverterKw': inverterKw,
        'inverterModel': inverterModel,
        'inverterMaxDcVoltage': inverterMaxDcVoltage,
        'inverterMpptMin': inverterMpptMin,
        'inverterMpptMax': inverterMpptMax,
        'inverterMaxInputCurrent': inverterMaxInputCurrent,
        'inverterMpptCount': inverterMpptCount,
        'inverterEfficiency': inverterEfficiency,
        'mpptEfficiency': mpptEfficiency,
        'peakSunHours': peakSunHours,
        'temperatureLoss': temperatureLoss,
        'soilingLoss': soilingLoss,
        'dcCableLoss': dcCableLoss,
        'acCableLoss': acCableLoss,
        'mismatchLoss': mismatchLoss,
        'shadingLoss': shadingLoss,
        'otherLoss': otherLoss,
        'customEquipment': customEquipment
            .map((e) => {
                  'name': e.name,
                  'quantity': e.quantity,
                  'unit': e.unit,
                  'note': e.note,
                  'category': e.category,
                })
            .toList(),
      };

  factory SolarProject.fromJson(Map<String, dynamic> j) {
    double d(String key, double fallback) =>
        (j[key] as num?)?.toDouble() ?? fallback;
    return SolarProject(
      id: j['id'] as String?,
      updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? ''),
      calculationCompleted: j['calculationCompleted'] as bool? ?? false,
      customerName: j['customerName'] as String? ?? '',
      projectName: j['projectName'] as String? ?? '',
      customerPhone: j['customerPhone'] as String? ?? '',
      installationAddress: j['installationAddress'] as String? ?? '',
      installationLatitude: (j['installationLatitude'] as num?)?.toDouble(),
      installationLongitude: (j['installationLongitude'] as num?)?.toDouble(),
      roofType: j['roofType'] as String? ?? '',
      electricalPhase: j['electricalPhase'] as String? ?? '1 เฟส',
      sitePhotoPaths: (j['sitePhotoPaths'] as List? ?? [])
          .map((e) => e as String)
          .toList(),
      customerNote: j['customerNote'] as String? ?? '',
      monthlyBill: d('monthlyBill', 3000),
      monthlyKwh: d('monthlyKwh', 450),
      dayKwhPerDay: d('dayKwhPerDay', 9),
      nightKwhPerDay: d('nightKwhPerDay', 6),
      roofArea: d('roofArea', 40),
      roofWidth: d('roofWidth', 5),
      roofLength: d('roofLength', 8),
      systemType: j['systemType'] as String? ?? 'On-grid',
      airConditionerBtu: (j['airConditionerBtu'] as num?)?.toInt() ?? 9000,
      airConditionerBrand: j['airConditionerBrand'] as String? ?? 'Daikin',
      airConditionerModel: j['airConditionerModel'] as String? ?? 'FTKQ09UV2S',
      airConditionerImageUrl:
          _localImageAsset(j['airConditionerImageUrl'] as String?),
      airConditionerCount: (j['airConditionerCount'] as num?)?.toInt() ?? 1,
      airConditionerPowerKw: d('airConditionerPowerKw', .8),
      airConditionerHoursPerDay: d('airConditionerHoursPerDay', 8),
      airConditioners: (j['airConditioners'] as List? ?? [])
          .map((item) => AirConditionerUnit.fromJson(
              Map<String, dynamic>.from(item as Map)))
          .toList(),
      customAirConditionerModels:
          (j['customAirConditionerModels'] as List? ?? [])
              .map((item) => AirConditionerModelOption.fromJson(
                  Map<String, dynamic>.from(item as Map)))
              .toList(),
      hasBattery: j['hasBattery'] as bool? ?? false,
      batteryCapacityKwh: d('batteryCapacityKwh', 10),
      batteryDepthOfDischarge: d('batteryDepthOfDischarge', 80),
      batteryEfficiency: d('batteryEfficiency', 95),
      backupHours: d('backupHours', 8),
      sizeBatteryFromNightUsage:
          j['sizeBatteryFromNightUsage'] as bool? ?? true,
      panelModel: j['panelModel'] as String? ?? 'Jinko Solar JKM620N-78HL4-V',
      panelAreaM2: d('panelAreaM2', 2.795),
      panelWatt: d('panelWatt', 620),
      panelVoc: d('panelVoc', 49.5),
      panelVmp: d('panelVmp', 41.8),
      panelIsc: d('panelIsc', 15.2),
      panelImp: d('panelImp', 14.4),
      panelEfficiency: d('panelEfficiency', 22.5),
      panelTempCoeffVoc: d('panelTempCoeffVoc', -0.25),
      panelDegradation: d('panelDegradation', .4),
      manualPanelCount: (j['manualPanelCount'] as num?)?.toInt(),
      inverterKw: d('inverterKw', 6),
      inverterModel: j['inverterModel'] as String? ?? 'Deye SUN-6K-SG03LP1-EU',
      inverterMaxDcVoltage: d('inverterMaxDcVoltage', 500),
      inverterMpptMin: d('inverterMpptMin', 125),
      inverterMpptMax: d('inverterMpptMax', 425),
      inverterMaxInputCurrent: d('inverterMaxInputCurrent', 16),
      inverterMpptCount: (j['inverterMpptCount'] as num?)?.toInt() ?? 2,
      inverterEfficiency: d('inverterEfficiency', 97.5),
      mpptEfficiency: d('mpptEfficiency', 99),
      peakSunHours: d('peakSunHours', 4.5),
      temperatureLoss: d('temperatureLoss', 5),
      soilingLoss: d('soilingLoss', 3),
      dcCableLoss: d('dcCableLoss', 1.5),
      acCableLoss: d('acCableLoss', 1),
      mismatchLoss: d('mismatchLoss', 2),
      shadingLoss: d('shadingLoss', 3),
      otherLoss: d('otherLoss', 1),
      customEquipment: (j['customEquipment'] as List? ?? []).map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return CustomEquipment(
            name: m['name'] as String? ?? '',
            quantity: (m['quantity'] as num?)?.toDouble() ?? 1,
            unit: m['unit'] as String? ?? 'ชิ้น',
            note: m['note'] as String? ?? '',
            category: m['category'] as String? ?? 'อุปกรณ์อื่น');
      }).toList(),
    );
  }

  double get dailyKwh => monthlyKwh / 30.0;
  double get splitDailyKwh => dayKwhPerDay + nightKwhPerDay;
  bool get isAirSolarSystem => systemType == 'Air solar';
  double get airConditionerDailyKwh => airConditioners.isNotEmpty
      ? airConditioners.fold(0, (sum, unit) => sum + unit.dailyKwh)
      : airConditionerCount * airConditionerPowerKw * airConditionerHoursPerDay;

  double get systemEfficiency {
    final factors = [
      inverterEfficiency,
      mpptEfficiency,
      100 - temperatureLoss,
      100 - soilingLoss,
      100 - dcCableLoss,
      100 - acCableLoss,
      100 - mismatchLoss,
      100 - shadingLoss,
      100 - otherLoss,
    ];
    double result = 1.0;
    for (final percent in factors) {
      result *= percent.clamp(0, 100) / 100.0;
    }
    return result;
  }

  double get totalSystemLoss => (1 - systemEfficiency) * 100;

  int get recommendedPanels {
    if (manualPanelCount != null) return manualPanelCount!;
    final dailyPerPanel = (panelWatt / 1000) * peakSunHours * systemEfficiency;
    if (dailyPerPanel <= 0) return 0;
    return (solarDailyEnergyTarget / dailyPerPanel).ceil();
  }

  double get systemKwp => recommendedPanels * panelWatt / 1000;

  double get estimatedDailyProduction =>
      systemKwp * peakSunHours * systemEfficiency;

  double get estimatedMonthlyProduction => estimatedDailyProduction * 30;

  double get estimatedRoofArea => recommendedPanels * panelAreaM2;

  double get requiredBackupEnergy => dailyKwh * backupHours / 24;

  double get batteryEnergyTarget =>
      sizeBatteryFromNightUsage ? nightKwhPerDay : requiredBackupEnergy;

  double get batteryDailyChargeEnergy {
    final efficiency = batteryEfficiency.clamp(0, 100) / 100;
    if (!hasBattery || batteryCapacityKwh <= 0 || efficiency <= 0) return 0;
    return batteryCapacityKwh / efficiency;
  }

  double get solarDailyEnergyTarget => isAirSolarSystem
      ? airConditionerDailyKwh
      : hasBattery
          ? dayKwhPerDay + batteryDailyChargeEnergy
          : dailyKwh;

  double get recommendedBatteryCapacity {
    final usableFactor = (batteryDepthOfDischarge.clamp(0, 100) / 100) *
        (batteryEfficiency.clamp(0, 100) / 100);
    if (!hasBattery || usableFactor <= 0) return 0;
    return batteryEnergyTarget / usableFactor;
  }

  double get usableBatteryEnergy => hasBattery
      ? batteryCapacityKwh *
          (batteryDepthOfDischarge.clamp(0, 100) / 100) *
          (batteryEfficiency.clamp(0, 100) / 100)
      : 0;

  double get estimatedBatteryBackupHours {
    final hourlyConsumption = dailyKwh / 24;
    if (!hasBattery || hourlyConsumption <= 0) return 0;
    return usableBatteryEnergy / hourlyConsumption;
  }

  double get estimatedNightCoveragePercent {
    if (!hasBattery || nightKwhPerDay <= 0) return 0;
    return (usableBatteryEnergy / nightKwhPerDay * 100).clamp(0, 100);
  }

  int get panelsThatFitRoof =>
      (roofArea / panelAreaM2).floor().clamp(0, 1000000);
  double get roofLimitedSystemKwp => panelsThatFitRoof * panelWatt / 1000;
}
