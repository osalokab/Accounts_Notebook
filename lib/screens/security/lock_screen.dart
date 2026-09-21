import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/constants.dart';

class LockScreen extends StatefulWidget {
  final Widget child;

  const LockScreen({super.key, required this.child});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    final success = await context.read<SettingsProvider>().unlockWithPin(pin);
    if (!success) {
      setState(() {
        _errorMessage = 'رمز المرور غير صحيح';
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();

    if (!settingsProv.isAppLocked) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white12,
                  child: Icon(Icons.lock, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'دفتر الحسابات محمي',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'يرجى إدخال رمز المرور (PIN) للمتابعة',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, color: Colors.white),
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: '••••',
                    hintStyle: const TextStyle(color: Colors.white38, letterSpacing: 8),
                    filled: true,
                    fillColor: Colors.white10,
                    errorText: _errorMessage,
                    errorStyle: const TextStyle(color: Colors.redAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  onSubmitted: (_) => _verify(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _verify,
                    child: const Text('فتح التطبيق', style: TextStyle(fontSize: 16)),
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
