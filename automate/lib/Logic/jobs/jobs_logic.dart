import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobsLogic {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ─── Polling interval ────────────────────────────────────────────────────────
  // Fetches fresh data every 10 seconds. Reliable on all platforms (no realtime
  // websocket needed), and avoids the blank-data flash caused by Supabase stream
  // reconnection events emitting empty snapshots.
  static const _pollInterval = Duration(seconds: 10);

  // ─── Internal: create a polling stream from a REST fetch function ─────────────
  Stream<List<Map<String, dynamic>>> _pollingStream(
    Future<List<Map<String, dynamic>>> Function() fetch,
  ) {
    late StreamController<List<Map<String, dynamic>>> controller;
    Timer? timer;

    Future<void> poll() async {
      try {
        final data = await fetch();
        if (!controller.isClosed) {
          controller.add(data);
        }
      } catch (e) {
        debugPrint('[JobsLogic] poll error: $e');
        // Don't add error — just skip this cycle, keep last data in StreamBuilder
      }
    }

    controller = StreamController<List<Map<String, dynamic>>>(
      onListen: () {
        poll(); // Fetch immediately on first listen
        timer = Timer.periodic(_pollInterval, (_) => poll());
      },
      onCancel: () {
        timer?.cancel();
      },
    );

    return controller.stream;
  }

  // ─── Helper: look up a display name for a given uid ──────────────────────────
  Future<String?> _lookupName(String uid) async {
    // Only query the 'user' table — 'driver' table doesn't exist in this DB
    try {
      final res = await _supabase
          .from('user')
          .select('first_name, last_name')
          .eq('uid', uid)
          .maybeSingle();
      if (res != null) {
        final first = res['first_name'] ?? '';
        final last = res['last_name'] ?? '';
        final full = '$first $last'.trim();
        if (full.isNotEmpty) return full;
      }
    } catch (e) {
      debugPrint('[JobsLogic] _lookupName(user, $uid): $e');
    }
    return null;
  }

  // ─── Helper: look up a mechanic display name ──────────────────────────────────
  Future<String?> _lookupMechanicName(String uid) async {
    try {
      final res = await _supabase
          .from('mechanic')
          .select('first_name, last_name')
          .eq('uid', uid)
          .maybeSingle();
      if (res != null) {
        final first = res['first_name'] ?? '';
        final last = res['last_name'] ?? '';
        final full = '$first $last'.trim();
        if (full.isNotEmpty) return full;
      }
    } catch (e) {
      debugPrint('[JobsLogic] _lookupMechanicName($uid): $e');
    }
    return null;
  }

  // ─── Create a new job ─────────────────────────────────────────────────────────
  Future<void> createJob({
    required String title,
    required String vehicle,
    required String pickupLocation,
    required String serviceType,
    DateTime? scheduledDate,
    String? issueDescription,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User is not logged in.');

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

  // ─── Pending jobs (for mechanic homescreen / job list) ────────────────────────
  Stream<List<Map<String, dynamic>>> getPendingJobs() {
    return _pollingStream(() async {
      final res = await _supabase
          .from('jobs')
          .select()
          .eq('status', 'pending')
          .neq('service_type', 'emergency')
          .order('created_at', ascending: false);
      debugPrint('[JobsLogic] getPendingJobs: ${res.length} rows');
      return List<Map<String, dynamic>>.from(res);
    });
  }

  // ─── Mechanic: accepted jobs for the schedule screen ─────────────────────────
  Stream<List<Map<String, dynamic>>> getMechanicScheduledJobs() {
    final user = _supabase.auth.currentUser;
    debugPrint('[JobsLogic] getMechanicScheduledJobs: uid=${user?.id}');
    if (user == null) return const Stream.empty();

    return _pollingStream(() async {
      final res = await _supabase
          .from('jobs')
          .select()
          .eq('mechanic_id', user.id)
          .eq('status', 'accepted')
          .order('created_at', ascending: false);

      debugPrint('[JobsLogic] getMechanicScheduledJobs: ${res.length} rows');

      final jobs = List<Map<String, dynamic>>.from(res);

      // Enrich with user names
      final userIds = jobs
          .map((j) => j['user_id'])
          .where((id) => id != null)
          .toSet()
          .cast<String>();

      final profilesMap = <String, String>{};
      for (final id in userIds) {
        final name = await _lookupName(id);
        if (name != null) profilesMap[id] = name;
      }

      return jobs.map((job) {
        final newJob = Map<String, dynamic>.from(job);
        final uId = job['user_id'] as String?;
        if (uId != null && profilesMap.containsKey(uId)) {
          newJob['user_name'] = profilesMap[uId];
        }
        return newJob;
      }).toList();
    });
  }

  // ─── User: all jobs for the activity / homescreen ─────────────────────────────
  Stream<List<Map<String, dynamic>>> getUserActivityJobs() {
    final user = _supabase.auth.currentUser;
    debugPrint('[JobsLogic] getUserActivityJobs: uid=${user?.id}');
    if (user == null) return const Stream.empty();

    return _pollingStream(() async {
      final res = await _supabase
          .from('jobs')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      debugPrint('[JobsLogic] getUserActivityJobs: ${res.length} rows');

      final jobs = List<Map<String, dynamic>>.from(res);

      // Enrich with mechanic names
      final mechanicIds = jobs
          .map((j) => j['mechanic_id'])
          .where((id) => id != null)
          .toSet()
          .cast<String>();

      final profilesMap = <String, String>{};
      for (final id in mechanicIds) {
        final name = await _lookupMechanicName(id);
        if (name != null) profilesMap[id] = name;
      }

      return jobs.map((job) {
        final newJob = Map<String, dynamic>.from(job);
        final mId = job['mechanic_id'] as String?;
        if (mId != null && profilesMap.containsKey(mId)) {
          newJob['mechanic_name'] = profilesMap[mId];
        }
        return newJob;
      }).toList();
    });
  }

  // ─── Count of total requests for the current user ─────────────────────────────
  Future<int> getTotalRequestsCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    final res =
        await _supabase.from('jobs').select('id').eq('user_id', user.id);
    return (res as List).length;
  }

  // ─── Accept a job (mechanic action) ──────────────────────────────────────────
  Future<void> acceptJob(String jobId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Mechanic is not logged in.');

    await _supabase.from('jobs').update({
      'status': 'accepted',
      'mechanic_id': user.id,
    }).eq('id', jobId);
  }

  // ─── Emergency Auto-Match ──────────────────────────────────────────
  Future<void> dispatchEmergency({
    required String title,
    required String vehicle,
    required String pickupLocation,
    String? issueDescription,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User is not logged in.');

    // 1. Create the job
    final jobRes = await _supabase.from('jobs').insert({
      'user_id': user.id,
      'title': title,
      'vehicle': vehicle,
      'pickup_location': pickupLocation,
      'service_type': 'emergency',
      'issue_description': issueDescription,
      'status': 'pending',
      'priority': 'High',
    }).select('id').single();

    final jobId = jobRes['id'];

    // 2. Pick a random available mechanic
    final mechanicsRes = await _supabase
        .from('mechanic')
        .select('uid')
        .eq('available_for_emergency', true)
        .limit(1);

    debugPrint('[JobsLogic] dispatchEmergency - matching mechanics count: ${(mechanicsRes as List).length}');

    if (mechanicsRes.isNotEmpty) {
      final mechanicId = mechanicsRes[0]['uid'];
      debugPrint('[JobsLogic] dispatchEmergency - dispatching to mechanicId: $mechanicId');
      
      // 3. Insert dispatch
      await _supabase.from('emergency_dispatches').insert({
        'job_id': jobId,
        'mechanic_id': mechanicId,
        'status': 'pending',
      });
    } else {
      debugPrint('[JobsLogic] dispatchEmergency - NO AVAILABLE MECHANIC FOUND');
    }
  }

  Stream<List<Map<String, dynamic>>> getMyEmergencyDispatch() {
    final user = _supabase.auth.currentUser;
    if (user == null) return const Stream.empty();

    return _pollingStream(() async {
      try {
        final res = await _supabase
            .from('emergency_dispatches')
            .select('*, jobs(*)')
            .eq('mechanic_id', user.id)
            .eq('status', 'pending')
            .order('created_at', ascending: false)
            .limit(1);
        
        final dispatches = List<Map<String, dynamic>>.from(res);
        if (dispatches.isNotEmpty) {
          debugPrint('[JobsLogic] getMyEmergencyDispatch - fetched ${dispatches.length} pending dispatches');
        }

        // We should also enrich the job with the user name
        for (var dispatch in dispatches) {
          final job = dispatch['jobs'];
          if (job != null && job['user_id'] != null) {
            final uName = await _lookupName(job['user_id']);
            job['user_name'] = uName;
          }
        }

        return dispatches;
      } catch (e) {
        debugPrint('[JobsLogic] getMyEmergencyDispatch ERROR: $e');
        return [];
      }
    });
  }

  Future<void> respondToDispatch(String dispatchId, String jobId, bool accept) async {
    final status = accept ? 'accepted' : 'declined';
    
    await _supabase.from('emergency_dispatches').update({
      'status': status,
      'responded_at': DateTime.now().toIso8601String(),
    }).eq('id', dispatchId);

    if (accept) {
      await acceptJob(jobId);
    }
  }
}
