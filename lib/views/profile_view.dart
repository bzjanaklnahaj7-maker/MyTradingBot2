import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';

class ProfileView extends StatelessWidget {
  final UserProfileModel? profile;

  const ProfileView({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي', style: TextStyle(color: Color(0xFFD4AF37))),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: profile == null
          ? const Center(child: Text('لا توجد بيانات متاحة', style: TextStyle(color: Colors.grey)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFD4AF37),
                    child: Icon(Icons.person, size: 60, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard('البريد الإلكتروني', profile!.email),
                  _buildInfoCard('معرف الحساب', profile!.profileId),
                  if (profile!.nickname != null)
                    _buildInfoCard('الاسم المستعار', profile!.nickname!),
                  if (profile!.telegramUser != null)
                    _buildInfoCard('تيليجرام', profile!.telegramUser!),
                  if (profile!.country != null)
                    _buildInfoCard('الدولة', profile!.country!),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        subtitle: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
