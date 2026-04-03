import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_helpers.dart';

class ResetPasswordLogic {
  /// Sends a password reset OTP email to the given address.
  static Future<void> forgotPassword({required String email}) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(friendlyError(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(friendlyError(e));
    }
  }

  /// Verifies the OTP sent to the email and establishes a recovery session.
  static Future<void> verifyOtp({
    required String email,
    required String token,
  }) async {
    try {
      final response = await supabaseClient.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      if (response.user == null) {
        throw Exception(
            'The code is invalid or has expired. Please request a new one.');
      }
    } on AuthException catch (e) {
      throw Exception(friendlyError(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(friendlyError(e));
    }
  }

  /// Updates the currently authenticated user's password.
  /// Must be called after [verifyOtp] establishes a recovery session.
  static Future<void> resetPassword({required String newPassword}) async {
    try {
      await supabaseClient.auth
          .updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw Exception(friendlyError(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(friendlyError(e));
    }
  }
}
