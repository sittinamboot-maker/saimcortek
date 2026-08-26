# PVForge UI Improvement Specification

## 1. เป้าหมาย
ปรับปรุง UI ของ PVForge ให้ดูสะอาด ทันสมัย อ่านง่าย และเหมาะกับ Solar SaaS / Monitoring โดยนำแนวคิดจากหน้าจออ้างอิงมาใช้เฉพาะ Design Direction เช่น โทนสีอ่อน, White Card, Energy Flow และการจัดลำดับข้อมูล โดยไม่คัดลอกหน้าจอตรง ๆ

---

## 2. Design Style

### แนวทางหลัก
- Modern Solar SaaS
- Light Theme เป็นธีมหลัก
- พื้นหลังฟ้าอ่อนอมเทา
- Card สีขาว
- มุมโค้งขนาดใหญ่
- Shadow บางและนุ่ม
- ลดเส้นกรอบที่ไม่จำเป็น
- ใช้พื้นที่ว่าง (White Space) มากขึ้น
- ตัวเลขสำคัญต้องเด่นกว่าข้อความอธิบาย
- ใช้สีแยกประเภทพลังงานอย่างสม่ำเสมอทุกหน้า

### ความรู้สึกของ UI
Clean / Modern / Professional / Energy / Easy to Read

---

## 3. Color System

| Usage | Color | HEX |
|---|---|---|
| App Background | Light Blue Gray | `#EAF4FC` |
| Background Highlight | Pale Blue | `#DCEEFF` |
| Primary | Blue | `#3478F6` |
| PV / Solar | Amber | `#FFB800` |
| Battery / Normal | Green | `#25B56A` |
| Grid | Gray Blue | `#8B95A5` |
| Load / Consumption | Blue | `#4D82FF` |
| Warning | Orange | `#F59E0B` |
| Critical / Alarm | Red | `#EF4444` |
| Card | White | `#FFFFFF` |
| Main Text | Dark | `#18202A` |
| Secondary Text | Gray | `#7A8491` |
| Divider | Light Gray | `#E5EAF0` |

### Battery SOC Color
- SOC > 30% = Green
- SOC 15–30% = Orange/Yellow
- SOC < 15% = Red

ห้ามใช้สีเขียวกับ Battery SOC ต่ำ เพราะทำให้ผู้ใช้เข้าใจผิดว่าสถานะปกติ

---

## 4. Background

ใช้พื้นหลัง Gradient อ่อนมาก

`#DCEEFF → #F4F8FB`

Gradient ต้องไม่แรงจนรบกวนข้อมูล

พื้นที่ Energy Flow สามารถมี Glow/Gradient จาง ๆ เพื่อเพิ่ม Depth โดยไม่ใช้ภาพพื้นหลังที่รก

---

## 5. Card Design

### Standard Card
- Background: `#FFFFFF`
- Border Radius: 20–24 px
- Border: ไม่มี หรือใช้ `#E5EAF0` แบบบางมาก
- Shadow: Soft Shadow
- Padding: 16–20 px
- ระยะห่างระหว่าง Card: 12–16 px

หลีกเลี่ยง Shadow หนักและเส้นกรอบดำ

---

# 6. Dashboard Structure

## 6.1 Header

ด้านบนแสดง

**PVForge**

ชื่อโครงการ / Site Name

ตัวอย่าง:

`บ้านลูกค้า - เชียงใหม่`

แสดงสถานะด้านขวา:

`● Online`

หรือ

`● Real-time`

ข้อมูลรอง:

`อัปเดตล่าสุด 5 วินาที`

สามารถเพิ่ม Weather / Irradiance ในอนาคตได้

---

## 6.2 System Status

สร้าง Status Pill:

`● ระบบปกติ`

สถานะ:
- Normal = Green
- Warning = Orange
- Fault = Red
- Offline = Gray

เมื่อกด Status สามารถเปิดรายละเอียด Alarm / Warning ได้

---

# 7. Energy Flow

Energy Flow เป็นส่วนสำคัญที่สุดของ Dashboard

โครงสร้างหลัก:

```text
              PV ARRAY
              5.24 kW
                 │
                 ▼
             INVERTER
              5.01 kW
                 │
                 ▼
                LOAD
              3.20 kW

      BATTERY             GRID
       82%              0.31 kW
    +1.50 kW
```

รองรับ:
- PV
- Inverter
- Battery
- Grid
- Load

### Node Design

แต่ละ Node ใช้วงกลมหรือ Rounded Card

PV:
- Accent = Yellow
- Icon = Solar Panel
- Power = kW

Battery:
- Accent = Green/Yellow/Red ตาม SOC
- SOC %
- Charge / Discharge Power

Grid:
- Accent = Gray Blue
- Import / Export

Load:
- Accent = Blue
- Consumption Power

Inverter:
- Accent = Primary Blue
- Output Power
- Efficiency

---

# 8. Animated Power Flow

เส้น Energy Flow ต้องแสดงทิศทางพลังงาน

ตัวอย่าง:

`PV → Inverter → Load`

`PV → Battery`

`Grid → Load`

`PV → Grid`

ใช้ Animated Dot / Moving Gradient บนเส้น

ความเร็ว Animation สามารถสัมพันธ์กับกำลังไฟ:
- Low Power = Slow
- Medium Power = Normal
- High Power = Faster

เมื่อ Power = 0 ให้เส้นเป็นสีเทาและหยุด Animation

---

# 9. Interactive Nodes

ผู้ใช้สามารถกดแต่ละ Node เพื่อเปิด Bottom Sheet

## PV Detail
- PV Power
- PV Voltage
- PV Current
- Voc
- Vmp
- Irradiance
- Expected Power
- PV Performance

## Inverter Detail
- DC Input
- AC Output
- Efficiency
- Temperature
- MPPT1
- MPPT2
- Status
- System Loss

## Battery Detail
- SOC
- Voltage
- Current
- Power
- Temperature
- Charge / Discharge
- Battery Status

## Grid Detail
- Import Power
- Export Power
- Voltage
- Current
- Energy Import Today
- Energy Export Today

## Load Detail
- Current Consumption
- Energy Today
- Peak Power

---

# 10. Summary Cards

ใต้ Energy Flow แสดงข้อมูลสำคัญเท่านั้น

### Today Energy
`30.32 kWh`
`พลังงานผลิตวันนี้`

### Saving
`฿212.24`
`ประหยัดวันนี้`

ถ้าเป็นระบบขายไฟสามารถเปลี่ยน Label เป็น `รายได้วันนี้`

### Efficiency
`96.4%`
`ประสิทธิภาพระบบ`

---

# 11. Energy Statistics

สร้าง Card สรุป:

| Metric | Example |
|---|---:|
| เดือนนี้ | 312.10 kWh |
| ปีนี้ | 4.20 MWh |
| ผลิตสะสม | 8.42 MWh |

ใช้คำว่า **พลังงานผลิตปีนี้** แทน “กำลังการผลิตไฟปีนี้” เพราะ kWh/MWh เป็นหน่วย Energy

---

# 12. PVForge Engineering Layer

PVForge ควรมีข้อมูลที่ลึกกว่า Solar Monitoring App ทั่วไป

เพิ่ม:

### System Efficiency
`96.4%`

### System Loss
`5.2%`

### Expected vs Actual
`Expected 32.5 kWh`
`Actual 30.3 kWh`

### Performance Ratio
`PR 93.2%`

### Inverter Efficiency
`97.6%`

### PV Performance
`94.3%`

ข้อมูลเหล่านี้อยู่หน้า Analyze หรือเปิดจาก Dashboard ได้

---

# 13. Bottom Navigation

แนะนำ Navigation หลัก:

1. **ภาพรวม**
2. **วิเคราะห์**
3. **ออกแบบ**
4. **โครงการ**
5. **เพิ่มเติม**

### ภาพรวม
Real-time Energy Flow และสถานะระบบ

### วิเคราะห์
- Energy Graph
- Performance Ratio
- System Loss
- Expected vs Actual
- Efficiency
- Historical Data

### ออกแบบ
- PV Design
- Panel
- Inverter
- Battery
- String Design
- System Calculation

### โครงการ
- Site / Customer
- Installation
- Equipment
- Documents
- Project Status

### เพิ่มเติม
- Account
- Company
- Devices
- Notifications
- Settings

---

# 14. Typography

หลักการ:
- ตัวเลข Power/Energy ใหญ่และ Bold
- Label เล็กกว่าและใช้ Secondary Text
- หน่วย kW / kWh / V / A เล็กกว่าค่าหลัก
- ไม่ใช้ Font Weight หนาเกินไปทั้งหน้า

ตัวอย่าง:

`5.24` **kW**

โดย 5.24 เป็นค่าหลัก และ kW มีขนาดเล็กกว่า

---

# 15. Responsive Design

UI ต้องรองรับ:
- Mobile
- Tablet
- Windows/Desktop
- Web

Mobile:
Energy Flow เป็นแนวตั้ง

Tablet/Desktop:
สามารถขยาย Energy Flow และวาง Analytics ด้านข้าง

ห้าม Fix ขนาดตามมือถือเครื่องเดียว

---

# 16. UI Component System

สร้าง Component กลางเพื่อใช้ซ้ำ:

- `PVForgeCard`
- `StatusPill`
- `MetricCard`
- `EnergyNode`
- `EnergyFlowLine`
- `PowerValue`
- `BatterySOC`
- `SystemStatus`
- `SectionHeader`
- `AlarmBadge`
- `RealtimeIndicator`

ทุกหน้าต้องอ้างอิง Theme/Color จากส่วนกลาง หลีกเลี่ยงการ Hard-code สีซ้ำใน Widget

---

# 17. Animation

Animation ต้องเรียบและไม่มากเกินไป

ใช้กับ:
- Energy Flow
- Realtime Indicator
- Card Transition
- Bottom Sheet
- Chart Update

ระยะ Transition โดยทั่วไปประมาณ 200–350 ms

Energy Flow สามารถทำงานต่อเนื่องขณะมี Power Flow

---

# 18. Alarm UX

Critical Alarm ต้องมองเห็นทันที

ตัวอย่าง:

`⚠ Inverter Temperature High`

ใช้ Red Accent เฉพาะ Alarm ไม่ควรใช้สีแดงตกแต่งทั่วไป

หน้า Dashboard แสดงเฉพาะ Alarm ที่สำคัญ ส่วนรายละเอียดทั้งหมดอยู่หน้า Alarm/Analyze

---

# 19. เป้าหมาย Dashboard ใหม่

ผู้ใช้เปิด Dashboard แล้วควรตอบได้ภายในไม่กี่วินาทีว่า:

1. ระบบ Online หรือไม่
2. ระบบปกติหรือมี Alarm
3. Solar ผลิตกี่ kW
4. บ้าน/โหลดใช้กี่ kW
5. Battery เหลือกี่ %
6. กำลังซื้อหรือขายไฟ Grid
7. วันนี้ผลิตกี่ kWh
8. วันนี้ประหยัดเงินประมาณเท่าไร

ข้อมูล Engineering เชิงลึกต้องเข้าถึงได้ แต่ไม่ควรทำให้หน้าแรกซับซ้อน

---

# 20. Implementation Priority

## Phase 1 — Visual Refresh
- Theme Colors
- Background Gradient
- White Cards
- Typography
- Bottom Navigation
- Status Pill

## Phase 2 — Energy Flow
- PV Node
- Inverter Node
- Battery Node
- Grid Node
- Load Node
- Animated Flow
- Real-time values

## Phase 3 — Engineering Data
- Efficiency
- System Loss
- Performance Ratio
- Expected vs Actual
- Detail Bottom Sheets

## Phase 4 — Responsive
- Tablet
- Desktop
- Web

---

## Final Design Direction

PVForge UI ใหม่ให้ใช้แนวคิด:

**Light Blue Background + White Floating Cards + Blue Primary + Energy Color Coding + Real-time Animated Energy Flow**

เป้าหมายคือให้ UI ดูง่ายสำหรับเจ้าของระบบ แต่เมื่อกดดูรายละเอียดต้องมีข้อมูลเพียงพอสำหรับช่างติดตั้งและวิศวกร

**ไม่คัดลอก UI ต้นฉบับโดยตรง** แต่ใช้เป็น Visual Reference แล้วสร้าง Component, Layout และ Identity ของ PVForge เอง
