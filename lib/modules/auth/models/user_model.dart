class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bio;
  final String? phone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio,
    this.phone,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: map['uid'] as String? ?? '',
        name: map['name'] as String? ?? '',
        email: map['email'] as String? ?? '',
        photoUrl: map['photoUrl'] as String?,
        bio: map['bio'] as String?,
        phone: map['phone'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['createdAt'] as int? ?? 0,
        ),
        updatedAt: map['updatedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'bio': bio,
        'phone': phone,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt?.millisecondsSinceEpoch,
      };

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? bio,
    String? phone,
    DateTime? updatedAt,
  }) =>
      UserModel(
        uid: uid,
        name: name ?? this.name,
        email: email,
        photoUrl: photoUrl ?? this.photoUrl,
        bio: bio ?? this.bio,
        phone: phone ?? this.phone,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, email: $email)';
}
