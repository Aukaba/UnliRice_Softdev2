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

  Stream<List<Map<String, dynamic>>> getMechanicScheduledJobs() {
    final user = _supabase.auth.currentUser;
    if (user == null) return const Stream.empty();
    return _supabase
        .from('jobs')
        .stream(primaryKey: ['id'])
        .eq('mechanic_id', user.id)
        .asyncMap((jobs) async {
      
      final userIds = jobs.map((j) => j['user_id']).where((id) => id != null).toSet();
      final profilesMap = <String, String>{};
      
      for (var id in userIds) {
        try {
          final res = await _supabase.from('profiles').select('first_name, last_name').eq('id', id).maybeSingle();
          if (res != null) {
            profilesMap[id.toString()] = '${res['first_name']} ${res['last_name']}';
          }
        } catch (_) {}
      }

      return jobs.map((job) {
        final newJob = Map<String, dynamic>.from(job);
        final uId = job['user_id'];
        if (uId != null && profilesMap.containsKey(uId.toString())) {
          newJob['user_name'] = profilesMap[uId.toString()];
        }
        return newJob;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUserActivityJobs() {
    final user = _supabase.auth.currentUser;
    if (user == null) return const Stream.empty();
    return _supabase
        .from('jobs')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .asyncMap((jobs) async {
          
      final mechanicIds = jobs.map((j) => j['mechanic_id']).where((id) => id != null).toSet();
      final profilesMap = <String, String>{};
      
      for (var id in mechanicIds) {
        try {
          final res = await _supabase.from('profiles').select('first_name, last_name').eq('id', id).maybeSingle();
          if (res != null) {
            profilesMap[id.toString()] = '${res['first_name']} ${res['last_name']}';
          }
        } catch (_) {}
      }

      return jobs.map((job) {
        final newJob = Map<String, dynamic>.from(job);
        final mId = job['mechanic_id'];
        if (mId != null && profilesMap.containsKey(mId.toString())) {
          newJob['mechanic_name'] = profilesMap[mId.toString()];
        }
        return newJob;
      }).toList();
    });
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
