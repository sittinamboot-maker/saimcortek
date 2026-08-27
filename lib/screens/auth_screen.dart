import 'package:flutter/material.dart';

import '../app_version.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onSignedIn;
  final VoidCallback onDemo;
  const AuthScreen({
    super.key,
    required this.onSignedIn,
    required this.onDemo,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool register = false;
  bool obscure = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  void submit() {
    if (formKey.currentState?.validate() ?? false) widget.onSignedIn();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Stack(children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(children: [
                    Semantics(
                      label: 'PVForge Solar Designer',
                      image: true,
                      child: Image.asset(
                        'assets/branding/pvforge_login_logo_transparent.png',
                        width: 360,
                        height: 215,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // เดิมครอบด้วย Card (มีกรอบ+เงา) เอากรอบออกตามที่ขอ เหลือ
                    // แค่ Padding เว้นระยะเดิมไว้ ฟอร์มลอยอยู่บนพื้นหลังตรง ๆ
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: formKey,
                        child: Column(children: [
                          Text(register ? 'สมัครสมาชิก' : 'เข้าสู่ระบบ',
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 18),
                          if (register) ...[
                            TextFormField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'ชื่อบริษัท'),
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? 'กรุณากรอกชื่อบริษัท'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                          ],
                          TextFormField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration:
                                const InputDecoration(labelText: 'อีเมล'),
                            validator: (v) => !(v ?? '').contains('@')
                                ? 'กรุณากรอกอีเมลให้ถูกต้อง'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: passwordCtrl,
                            obscureText: obscure,
                            decoration: InputDecoration(
                              labelText: 'รหัสผ่าน',
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => obscure = !obscure),
                                icon: Text(obscure ? 'ดู' : 'ซ่อน'),
                              ),
                            ),
                            validator: (v) => (v ?? '').length < 6
                                ? 'รหัสผ่านอย่างน้อย 6 ตัวอักษร'
                                : null,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: submit,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                child: Text(register
                                    ? 'สร้างบัญชีและเข้าสู่ระบบ'
                                    : 'เข้าสู่ระบบ'),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => register = !register),
                            child: Text(register
                                ? 'มีบัญชีแล้ว? เข้าสู่ระบบ'
                                : 'ยังไม่มีบัญชี? สมัครสมาชิก'),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('ระบบบัญชีพร้อมสำหรับเชื่อมต่อ Firebase Auth',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF7A8491))),
                  ]),
                ),
              ),
            ),
            // ปุ่มทดลองใช้ DEMO: เดิมเป็น OutlinedButton (มีกรอบ) เต็มความกว้าง
            // อยู่ใต้ฟอร์ม แก้เป็นปุ่มข้อความล้วน (ไม่มีกรอบ) ชื่อ "demo" ลอย
            // อยู่มุมล่างขวาของจอแทนตามที่ขอ
            Positioned(
              right: 8,
              bottom: 8,
              child: TextButton(
                onPressed: widget.onDemo,
                child: const Text('demo'),
              ),
            ),
            // เลขเวอร์ชันแอป ลอยมุมล่างซ้าย ให้เช็กง่าย ๆ ว่าเครื่องนี้รันโค้ด
            // เวอร์ชันล่าสุดจริงหรือไม่
            const Positioned(
              left: 12,
              bottom: 10,
              child: Text(
                'v$kAppVersion',
                style: TextStyle(fontSize: 11, color: Color(0xFF9AA5B1)),
              ),
            ),
          ]),
        ),
      );
}
