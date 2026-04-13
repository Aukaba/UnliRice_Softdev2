import 'package:supabase_flutter/supabase_flutter.dart';
import '../authentication/auth_helpers.dart'; // To reuse supabaseClient if possible

class JobsLogic {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createJob({
    required String title,
    required String vehicle,
    required String pickupLocation,
    required String serviceType, // 'emergency' or 'scheduled'
    DateTime? scheduledDate,
    String? issueDescription,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await _supabase.from('jobs').insert({
      'user_id': user.id,
      'title': title,
      'vehicle': vehicle,
      'pickup_location': pickupLocation,
      'service_type': serviceType,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'issue_description': issueDescription,
      'status': 'pending',
      'priority': serviceType == 'emergency' ? 'High' : 'Medium',
    });
  }

  Stream<List<Map<String, dynamic>>> getPendingJobs() {
    return _supabase
        .from('jobs')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending');
        // If sorting is needed over stream: You can sort in dart, or add .order() (wait, .order on stream is supported in recent versions of supabase_flutter)
  }

  Future<void> acceptJob(String jobId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Mechanic is not logged in.');
    }

    await _supabase.from('jobs').update({
      'status': 'accepted',
      'mechanic_id': user.id,
    }).eq('id', jobId);
  }
}
