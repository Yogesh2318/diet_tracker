class UserModel {
  final String name;
  final String email;
  final String password;
  int wieght;
  int hieght;
  int claories;
  int protient;
  int nutrients;

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    this.wieght = 0,
    this.hieght = 0,
    this.claories = 0,
    this.protient = 0,
    this.nutrients = 0,
  });

  // Optional: Add a method to create a copy with some changes
  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    int? wieght,
    int? hieght,
    int? claories,
    int? protient,
    int? nutrients,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      wieght: wieght ?? this.wieght,
      hieght: hieght ?? this.hieght,
      claories: claories ?? this.claories,
      protient: protient ?? this.protient,
      nutrients: nutrients ?? this.nutrients,
    );
  }
}