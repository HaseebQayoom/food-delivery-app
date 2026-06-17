class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final bool isCravePlusMember;
  final int totalOrders;
  final int favoriteCount;
  final int points;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.isCravePlusMember = false,
    this.totalOrders = 0,
    this.favoriteCount = 0,
    this.points = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      isCravePlusMember: json['is_crave_plus_member'] as bool? ?? false,
      totalOrders: json['total_orders'] as int? ?? 0,
      favoriteCount: json['favorite_count'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'avatar_url': avatarUrl,
        'is_crave_plus_member': isCravePlusMember,
        'total_orders': totalOrders,
        'favorite_count': favoriteCount,
        'points': points,
      };

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isCravePlusMember,
    int? totalOrders,
    int? favoriteCount,
    int? points,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isCravePlusMember: isCravePlusMember ?? this.isCravePlusMember,
      totalOrders: totalOrders ?? this.totalOrders,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      points: points ?? this.points,
    );
  }
}
