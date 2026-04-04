import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_helpers.dart';

class SignupLogic {
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
      final authResponse = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'account_type': accountType,
        },
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception('Sign-up failed. Please try again.');
      }
      if (user.identities != null && user.identities!.isEmpty) {
        throw Exception('An account with this email already exists.');
      }
      // Profile row is inserted automatically by the on_auth_user_created trigger.
    } on AuthException catch (e) {
      throw Exception(friendlyError(e));
    } on PostgrestException catch (e) {
      throw Exception(friendlyError(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(friendlyError(e));
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
      final authResponse = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'position': position,
          'account_type': 'admin', // triggers handle_new_admin()
        },
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception('Admin sign-up failed. Please try again.');
      }
      if (user.identities != null && user.identities!.isEmpty) {
        throw Exception('An account with this email already exists.');
      }
      // Admin row is inserted automatically by the on_auth_admin_created trigger.
    } on AuthException catch (e) {
      throw Exception(friendlyError(e));
    } on PostgrestException catch (e) {
      throw Exception(friendlyError(e));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception(friendlyError(e));
    }
  }
}
