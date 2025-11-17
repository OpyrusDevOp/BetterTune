class User {
  final String id;
  final String name;
  final String? email;
  final bool hasPassword;
  final bool hasConfiguredPassword;

  User({
    required this.id,
    required this.name,
    this.email,
    required this.hasPassword,
    required this.hasConfiguredPassword,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['Id'] ?? '',
      name: json['Name'] ?? '',
      email: json['Email'],
      hasPassword: json['HasPassword'] ?? false,
      hasConfiguredPassword: json['HasConfiguredPassword'] ?? false,
    );
  }
}

class AuthenticationResult {
  final User user;
  final String accessToken;
  final String serverId;

  AuthenticationResult({
    required this.user,
    required this.accessToken,
    required this.serverId,
  });

  factory AuthenticationResult.fromJson(Map<String, dynamic> json) {
    return AuthenticationResult(
      user: User.fromJson(json['User']),
      accessToken: json['AccessToken'] ?? '',
      serverId: json['ServerId'] ?? '',
    );
  }
}
