class SolarPanelProduct {
  final String brand;
  final String model;
  final String technology;
  final double watt;
  final double voc;
  final double vmp;
  final double isc;
  final double imp;
  final double efficiency;
  final int lengthMm;
  final int widthMm;
  final String imageAsset;

  const SolarPanelProduct(
      {required this.brand,
      required this.model,
      required this.technology,
      required this.watt,
      required this.voc,
      required this.vmp,
      required this.isc,
      required this.imp,
      required this.efficiency,
      required this.lengthMm,
      required this.widthMm,
      this.imageAsset = ''});

  double get areaM2 => lengthMm * widthMm / 1000000;
  String get displayName => '$brand $model';
}

/// ค่า STC จากเอกสารผู้ผลิต ควรตรวจ datasheet รุ่นที่จำหน่ายจริงก่อนออกแบบขั้นสุดท้าย
const solarPanelCatalog = <SolarPanelProduct>[
  SolarPanelProduct(
      brand: 'Jinko Solar',
      model: 'JKM620N-78HL4-V',
      technology: 'N-type TOPCon',
      watt: 620,
      voc: 49.5,
      vmp: 41.8,
      isc: 15.2,
      imp: 14.4,
      efficiency: 22.5,
      lengthMm: 2465,
      widthMm: 1134),
      // TODO: assets/products/solar_panels/jinko_jkm620n.webp is actually a
      // duplicate of the Astronergy/Trina photo (same file, wrong panel) —
      // left as no image (shows brand-color placeholder instead) until a
      // real Jinko Tiger Neo photo is added.
  SolarPanelProduct(
      brand: 'LONGi',
      model: 'Hi-MO 7 LR7-72HGD-590M',
      technology: 'N-type HPDC',
      watt: 590,
      voc: 52.1,
      vmp: 44.0,
      isc: 14.3,
      imp: 13.4,
      efficiency: 22.8,
      lengthMm: 2382,
      widthMm: 1134,
      imageAsset: 'assets/products/solar_panels/longi_himo7_590.jpg'),
  SolarPanelProduct(
      brand: 'Trina Solar',
      model: 'Vertex N NEG19R.20-620',
      technology: 'N-type i-TOPCon dual glass',
      watt: 620,
      voc: 49.6,
      vmp: 41.4,
      isc: 15.91,
      imp: 14.99,
      efficiency: 23.0,
      lengthMm: 2382,
      widthMm: 1134),
      // TODO: assets/products/solar_panels/trina_vertex_n.webp is actually a
      // duplicate of the Jinko/Astronergy photo (same file, wrong panel) —
      // left as no image (shows brand-color placeholder instead) until a
      // real Trina Vertex N photo is added.
  SolarPanelProduct(
      brand: 'JA Solar',
      model: 'DeepBlue 4.0 Pro JAM72D42-620/LB',
      technology: 'N-type bifacial dual glass',
      watt: 620,
      voc: 52.07,
      vmp: 43.51,
      isc: 15.11,
      imp: 14.25,
      efficiency: 22.2,
      lengthMm: 2465,
      widthMm: 1134,
      imageAsset: 'assets/products/solar_panels/ja_solar_jam72d42_620.png'),
  SolarPanelProduct(
      brand: 'Astronergy',
      model: 'ASTRO N7 CHSM66RN(DG)/F-BH-620',
      technology: 'N-type TOPCon bifacial',
      watt: 620,
      voc: 49.04,
      vmp: 41.56,
      isc: 16.11,
      imp: 14.92,
      efficiency: 23.0,
      lengthMm: 2382,
      widthMm: 1134),
      // TODO: assets/products/solar_panels/astronergy_astro_n7.webp is
      // actually a duplicate of the Jinko/Trina photo (same file, wrong
      // panel) — left as no image (shows brand-color placeholder instead)
      // until a real Astronergy ASTRO N7 photo is added.
];

/// รายการที่ผู้ใช้เพิ่มเองระหว่างเปิดแอป
final userSolarPanelCatalog = <SolarPanelProduct>[];
