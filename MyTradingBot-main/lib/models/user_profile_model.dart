class UserProfileModel {
  final String profileId;
  final String email;
  final String? telegramUser;
  final String? nickname;
  final String? country;

  UserProfileModel({
    required this.profileId,
    required this.email,
    this.telegramUser,
    this.nickname,
    this.country,
  });

  // تحويل البيانات القادمة من السيرفر إلى كائن
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      profileId: json['profile_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telegramUser: json['telegram_user']?.toString(),
      nickname: json['nickname']?.toString(),
      country: json['country']?.toString(),
    );
  }

  // تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'email': email,
      'telegram_user': telegramUser,
      'nickname': nickname,
      'country': country,
    };
  }
}
