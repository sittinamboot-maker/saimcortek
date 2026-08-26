# CORTek Solar Designer

Flutter MVP สำหรับช่วยช่างออกแบบและเตรียมติดตั้งระบบโซลาร์เซลล์

## ฟังก์ชันในเวอร์ชันนี้
- Dashboard
- สร้างโปรเจกต์ลูกค้า
- เลือก On-grid / Hybrid / Off-grid
- คำนวณ kWp และจำนวนแผง
- คำนวณพลังงานผลิตต่อวัน/เดือน
- String / MPPT Checker
- ตรวจ Voc, Cold Voc, Vmp, Current
- สรุประบบและ BOQ เบื้องต้น

## เปิดใน VS Code

1. ติดตั้ง Flutter SDK และ Flutter extension ใน VS Code
2. เปิดโฟลเดอร์ `cortek_solar_designer`
3. เปิด Terminal
4. รัน:

```bash
flutter pub get
flutter run
```

ถ้าจะรันบน Windows:

```bash
flutter config --enable-windows-desktop
flutter create .
flutter run -d windows
```

ถ้าจะ build Windows:

```bash
flutter build windows
```

ถ้าจะ build Android APK:

```bash
flutter build apk --release
```

## หมายเหตุด้านวิศวกรรม
ค่าการแนะนำสายไฟ, Breaker, SPD, Grounding และ Cold Voc ใน MVP นี้ยังเป็นแนวทางเบื้องต้น
ก่อนใช้กับงานจริงควรเพิ่ม temperature coefficient ของแผง, minimum site temperature,
derating, cable voltage drop และกฎตามมาตรฐานการติดตั้งที่ใช้งานจริง

## เพิ่มในเวอร์ชันอัปเดต
- Efficiency & Losses
- Panel Efficiency / Temperature Coefficient / Degradation
- Inverter Efficiency / MPPT Efficiency
- Temperature / Dust / DC Cable / AC Cable / Mismatch / Shading / Other Loss
- คำนวณ System Efficiency และ Total System Loss แบบตัวคูณต่อเนื่อง
