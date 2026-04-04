import 'package:supabase_flutter/supabase_flutter.dart';

class AdminChangePasswordLogic {
  static final _supabase = Supabase.instance.client;

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser?.email == null) {
      throw Exception('User not found.');
    }

    // Re-authenticate to verify current password
    await _supabase.auth.signInWithPassword(
      email: currentUser!.email!,
      password: currentPassword,
    );

    // Update to new password
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}
