import 'package:supabase_flutter/supabase_flutter.dart';

class AuthLogic {
  static final _supabase = Supabase.instance.client;

  // ---------- helpers ----------

  /// Converts raw Supabase / Dart exception messages into friendly text.
  static String _friendly(Object e) {
    final raw = e is AuthException
        ? e.message.toLowerCase()
        : e is PostgrestException
            ? e.message.toLowerCase()
            : e.toString().toLowerCase();

    // Auth errors
    if (raw.contains('invalid login credentials') ||
        raw.contains('invalid email or password') ||
        raw.contains('wrong password')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (raw.contains('email not confirmed')) {
      return 'Please verify your email before logging in.';
    }
    if (raw.contains('user already registered') ||
        raw.contains('already been registered')) {
      return 'An account with this email already exists.';
    }
    if (raw.contains('password should be at least')) {
      return 'Password must be at least 6 characters long.';
    }
    if (raw.contains('unable to validate email address') ||
        raw.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (raw.contains('same_password') ||
        raw.contains('new password should be different')) {
      return 'Your new password must be different from your current one.';
    }

    // Database / RLS errors
    if (raw.contains('row-level security') || raw.contains('42501')) {
      return 'Account created but profile could not be saved. Please contact support.';
    }
    if (raw.contains('duplicate key') || raw.contains('23505')) {
      return 'An account with this information already exists.';
    }

    // Network errors
    if (raw.contains('network') || raw.contains('socket')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (raw.contains('rate limit') || raw.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    // OTP errors
    if (raw.contains('otp') ||
        raw.contains('token') ||
        raw.contains('expired')) {
      return 'The code is invalid or has expired. Please request a new one.';
    }

    // Fallback: strip prefixes and capitalise
    final cleaned = e
        .toString()
        .replaceAll('Exception: ', '')
        .replaceAll('AuthException: ', '')
        .replaceAll('AuthApiException: ', '')
        .replaceAll('PostgrestException: ', '');
    if (cleaned.isEmpty) return 'Something went wrong. Please try again.';
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  // ---------- public API ----------

  /// Signs in the user and returns the role they belong to:
  /// 'admin' | 'mechanic' | 'driver'.
  static Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Incorrect email or password. Please try again.');
      }

      final uid = response.user!.id;

      // Check admin first
      final admin = await _supabase
          .from('admin')
          .select('uid')
          .eq('uid', uid)
          .maybeSingle();
      if (admin != null) return 'admin';

      // Then mechanic
      final mechanic = await _supabase
          .from('mechanic')
          .select('uid')
          .eq('uid', uid)
          .maybeSingle();
      if (mechanic != null) return 'mechanic';

      // Default to driver
      return 'driver';
    } on AuthException catch (e) {
      throw Exception(_friendly(e));
    } on PostgrestException catch (e) {
      throw Exception(_friendly(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(_friendly(e));
    }
  }

  /// Signs up a new user — profile row is created by a DB trigger.
  /// [accountType] should be 'mechanic' or 'driver'.
  static Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String accountType,
  }) async {
    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'account_type': accountType,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Sign-up failed. Please try again.');
      }
      // Profile row is inserted automatically by the on_auth_user_created trigger.
    } on AuthException catch (e) {
      throw Exception(_friendly(e));
    } on PostgrestException catch (e) {
      throw Exception(_friendly(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(_friendly(e));
    }
  }

  /// Signs up a new admin account.
  /// The DB trigger [on_auth_admin_created] automatically inserts a row into
  /// the [admin] table using the metadata passed here.
  ///
  /// Fields stored: first_name, last_name, email, position.
  static Future<void> signUpAdmin({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String position,
  }) async {
    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'position': position,
          'account_type': 'admin', // triggers handle_new_admin()
        },
      );

      if (authResponse.user == null) {
        throw Exception('Admin sign-up failed. Please try again.');
      }
      // Admin row is inserted automatically by the on_auth_admin_created trigger.
    } on AuthException catch (e) {
      throw Exception(_friendly(e));
    } on PostgrestException catch (e) {
      throw Exception(_friendly(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(_friendly(e));
    }
  }

  /// Sends a password reset OTP email to the given address.
  static Future<void> forgotPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(_friendly(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(_friendly(e));
    }
  }

  /// Verifies the OTP sent to the email and establishes a recovery session.
  static Future<void> verifyOtp({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      if (response.user == null) {
        throw Exception(
            'The code is invalid or has expired. Please request a new one.');
      }
    } on AuthException catch (e) {
      throw Exception(_friendly(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(_friendly(e));
    }
  }

  /// Updates the currently authenticated user's password.
  /// Must be called after [verifyOtp] establishes a recovery session.
  static Future<void> resetPassword({required String newPassword}) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw Exception(_friendly(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(_friendly(e));
    }
  }
}
