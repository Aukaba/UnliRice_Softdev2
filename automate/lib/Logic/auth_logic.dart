import 'package:supabase_flutter/supabase_flutter.dart';

class AuthLogic {
  static final _supabase = Supabase.instance.client;

  /// Signs in the user and returns the table they belong to: 'mechanic' or 'driver'.
  /// Throws an exception with a message on failure.
  static Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed. Please check your credentials.');
    }

    final uid = response.user!.id;

    // Check which table this user belongs to
    final mechanic = await _supabase
        .from('mechanic')
        .select('uid')
        .eq('uid', uid)
        .maybeSingle();

    return mechanic != null ? 'mechanic' : 'driver';
  }

  /// Signs up a new user and inserts into the correct table.
  /// [accountType] should be 'mechanic' or 'driver'.
  static Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String accountType,
  }) async {
    final authResponse = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final uid = authResponse.user?.id;
    if (uid == null) throw Exception('Sign up failed. Please try again.');

    final data = {
      'uid': uid,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
    };

    if (accountType == 'mechanic') {
      await _supabase.from('mechanic').insert({
        ...data,
        'verified': false,
      });
    } else {
      await _supabase.from('user').insert(data);
    }
  }

  /// Sends a password reset OTP email to the given address.
  static Future<void> forgotPassword({required String email}) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  /// Verifies the OTP sent to the email and establishes a recovery session.
  static Future<void> verifyOtp({
    required String email,
    required String token,
  }) async {
    final response = await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery,
    );
    if (response.user == null) {
      throw Exception('Invalid or expired OTP. Please try again.');
    }
  }

  /// Updates the currently authenticated user's password.
  /// Must be called after [verifyOtp] establishes a recovery session.
  static Future<void> resetPassword({required String newPassword}) async {
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
