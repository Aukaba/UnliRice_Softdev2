import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_helpers.dart';

class LoginLogic {
  /// Signs in the user and returns the role they belong to:
  /// 'admin' | 'mechanic' | 'driver'.
  static Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Incorrect email or password. Please try again.');
      }

      final uid = response.user!.id;

      // Check admin first
      final admin = await supabaseClient
          .from('admin')
          .select('uid')
          .eq('uid', uid)
          .maybeSingle();
      if (admin != null) return 'admin';

      // Then mechanic
      final mechanic = await supabaseClient
          .from('mechanic')
          .select('uid')
          .eq('uid', uid)
          .maybeSingle();
      if (mechanic != null) return 'mechanic';

      // Default to driver
      return 'driver';
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
