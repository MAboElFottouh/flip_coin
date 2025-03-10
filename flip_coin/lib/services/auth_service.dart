import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersKey = 'users';

  // Get all users
  Future<List<String>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_usersKey) ?? [];
  }

  // Check if username exists
  Future<bool> isUsernameTaken(String username) async {
    final users = await getUsers();
    return users.contains(username);
  }

  // Login user
  Future<bool> login(String username) async {
    return await isUsernameTaken(username);
  }

  // Signup new user
  Future<bool> signup(String username) async {
    if (await isUsernameTaken(username)) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();
    users.add(username);
    return await prefs.setStringList(_usersKey, users);
  }
}
