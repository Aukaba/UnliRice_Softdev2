import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final _supabase = Supabase.instance.client;

  // Check if the current user is verified
  Future<bool> checkVerificationStatus() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final data = await _supabase
          .from('mechanic')
          .select('is_verified')
          .eq('id', user.id)
          .single();

      return data['is_verified'] as bool;
    } catch (e) {
      return false;
    }
  }

  // Updated to accept image URL instead of license number
  Future<void> verifyMechanic(String validIdUrl) async {
    final user = _supabase.auth.currentUser;
    await _supabase.from('mechanic').update({
      'is_verified': true,
      'valid_id_image': validIdUrl, // Store the image URL
    }).eq('id', user!.id);
  }
}