import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(color: Color(0xFFD4AF37))),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('الإشعارات', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('تفعيل الإشعارات'),
            value: _notificationsEnabled,
            activeColor: const Color(0xFFD4AF37),
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          SwitchListTile(
            title: const Text('تفعيل الصوت'),
            value: _soundEnabled,
            activeColor: const Color(0xFFD4AF37),
            onChanged: (val) => setState(() => _soundEnabled = val),
          ),
          SwitchListTile(
            title: const Text('الاهتزاز'),
            value: _vibrationEnabled,
            activeColor: const Color(0xFFD4AF37),
            onChanged: (val) => setState(() => _vibrationEnabled = val),
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 20),
          const Text('حول التطبيق', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const ListTile(
            title: Text('الإصدار'),
            subtitle: Text('1.0.0'),
            trailing: Icon(Icons.info_outline, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
