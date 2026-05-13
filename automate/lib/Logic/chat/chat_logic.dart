import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatLogic {
  final _supabase = Supabase.instance.client;

  Future<void> sendMessage(String receiverId, String content) async {
    final senderId = _supabase.auth.currentUser?.id;
    if (senderId == null) throw Exception('Not logged in');

    await _supabase.from('messages').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
    });
  }

  Stream<List<Map<String, dynamic>>> getMessagesWith(String partnerId) {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return const Stream.empty();

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .map((messages) {
      // filter messages between you and partner
      final filtered = messages.where((m) {
        return (m['sender_id'] == uid && m['receiver_id'] == partnerId) ||
               (m['sender_id'] == partnerId && m['receiver_id'] == uid);
      }).toList();
      
      filtered.sort((a, b) => a['created_at'].compareTo(b['created_at']));
      return filtered;
    });
  }

  /// Returns a periodic stream that re-fetches the list of conversation partners.
  /// Uses polling every 5 seconds to avoid Supabase stream RLS issues on
  /// unfiltered table scans.
  Stream<List<Map<String, dynamic>>> getActivePartners() {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return const Stream.empty();

    // Emit immediately and then every 5 seconds
    final controller = StreamController<List<Map<String, dynamic>>>();

    Future<void> fetch() async {
      try {
        final result = await _fetchPartners(uid);
        if (!controller.isClosed) controller.add(result);
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    // Kick off first fetch
    fetch();

    // Poll every 5 seconds
    Timer? timer;
    timer = Timer.periodic(const Duration(seconds: 5), (_) => fetch());

    controller.onCancel = () {
      timer?.cancel();
      controller.close();
    };

    return controller.stream;
  }

  Future<List<Map<String, dynamic>>> _fetchPartners(String uid) async {
    // Fetch messages where the current user is sender or receiver
    final sentMessages = await _supabase
        .from('messages')
        .select('id, sender_id, receiver_id, content, created_at, is_read')
        .eq('sender_id', uid)
        .order('created_at', ascending: false);

    final receivedMessages = await _supabase
        .from('messages')
        .select('id, sender_id, receiver_id, content, created_at, is_read')
        .eq('receiver_id', uid)
        .order('created_at', ascending: false);

    // Merge and remove duplicates
    final allMessages = <String, Map<String, dynamic>>{};
    for (var m in [...sentMessages, ...receivedMessages]) {
      allMessages[m['id'].toString()] = m;
    }
    final messages = allMessages.values.toList();
    messages.sort((a, b) => b['created_at'].compareTo(a['created_at']));

    // Build partner set with latest message
    final partnerIds = <String>{};
    final latestMsgMap = <String, Map<String, dynamic>>{};

    for (var m in messages) {
      final pId = m['sender_id'] == uid ? m['receiver_id'] : m['sender_id'];
      if (pId != null && pId.toString().trim().isNotEmpty && !partnerIds.contains(pId.toString())) {
        partnerIds.add(pId.toString());
        latestMsgMap[pId.toString()] = m;
      }
    }

    // Also include partners from active/completed jobs, and collect vehicle info
    final vehicleMap = <String, String>{}; // partnerId -> vehicle model
    try {
      final jobsRes = await _supabase
          .from('jobs')
          .select('user_id, mechanic_id, status, vehicle, updated_at')
          .or('user_id.eq.$uid,mechanic_id.eq.$uid');

      for (var job in jobsRes) {
        final status = job['status'] as String? ?? '';
        if (status == 'pending') continue;

        final pId = job['user_id'] == uid ? job['mechanic_id'] : job['user_id'];
        if (pId != null && pId.toString().trim().isNotEmpty) {
          final pIdStr = pId.toString();
          if (!partnerIds.contains(pIdStr)) {
            partnerIds.add(pIdStr);
          }
          final vehicle = job['vehicle']?.toString() ?? '';
          if (vehicle.isNotEmpty) {
            vehicleMap[pIdStr] = vehicle.toUpperCase();
          }
        }
      }
    } catch (_) {
      // ignore errors if jobs fails
    }

    // Resolve names for all partners
    final profilesMap = <String, String>{};
    for (var id in partnerIds) {
      final name = await _resolveUserName(id);
      if (name != null) profilesMap[id] = name;
    }

    final result = <Map<String, dynamic>>[];
    for (var pId in partnerIds) {
      final msg = latestMsgMap[pId];
      result.add({
        'partner_id': pId,
        'name': profilesMap[pId] ?? 'User',
        'vehicle': vehicleMap[pId] ?? '',
        'last_message': msg?['content'] ?? 'Tap to chat',
        'time': msg?['created_at'],
        'is_unread': msg != null && msg['receiver_id'] == uid && msg['is_read'] == false,
      });
    }
    return result;
  }

  /// Fetch the vehicle model from the most recent shared job between
  /// the current user and [partnerId].
  Future<String> getVehicleModelForPartner(String partnerId) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return '';
    try {
      final res = await _supabase
          .from('jobs')
          .select('vehicle')
          .or('and(user_id.eq.$uid,mechanic_id.eq.$partnerId),and(user_id.eq.$partnerId,mechanic_id.eq.$uid)')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return (res?['vehicle']?.toString() ?? '').toUpperCase();
    } catch (e) {
      debugPrint('[ChatLogic] getVehicleModelForPartner error: $e');
      return '';
    }
  }

  /// Deletes all messages between the current user and any partner whose
  /// shared job has been completed for more than 48 hours.
  Future<void> deleteExpiredMessages() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final completedJobs = await _supabase
          .from('jobs')
          .select('user_id, mechanic_id, updated_at')
          .or('user_id.eq.$uid,mechanic_id.eq.$uid')
          .eq('status', 'completed');

      final now = DateTime.now().toUtc();
      const threshold = Duration(hours: 48);

      for (final job in completedJobs) {
        final updatedAtStr = job['updated_at']?.toString();
        if (updatedAtStr == null) continue;
        final updatedAt = DateTime.tryParse(updatedAtStr)?.toUtc();
        if (updatedAt == null) continue;
        if (now.difference(updatedAt) < threshold) continue;

        final userId = job['user_id']?.toString() ?? '';
        final mechanicId = job['mechanic_id']?.toString() ?? '';
        if (userId.isEmpty || mechanicId.isEmpty) continue;

        await _supabase
            .from('messages')
            .delete()
            .or('and(sender_id.eq.$userId,receiver_id.eq.$mechanicId),and(sender_id.eq.$mechanicId,receiver_id.eq.$userId)');

        debugPrint('[ChatLogic] Purged expired chat: user=$userId mechanic=$mechanicId');
      }
    } catch (e) {
      debugPrint('[ChatLogic] deleteExpiredMessages error: $e');
    }
  }

  Future<String?> _resolveUserName(String uid) async {
    // Try mechanic table
    try {
      final res = await _supabase
          .from('mechanic')
          .select('first_name, last_name')
          .eq('uid', uid)
          .maybeSingle();
      if (res != null) return '${res['first_name']} ${res['last_name']}'.trim();
    } catch (e) {
      debugPrint('[ChatLogic] mechanic lookup failed for $uid: $e');
    }

    // Try user table (singular)
    try {
      final res = await _supabase
          .from('user')
          .select('first_name, last_name')
          .eq('uid', uid)
          .maybeSingle();
      if (res != null) return '${res['first_name']} ${res['last_name']}'.trim();
    } catch (e) {
      debugPrint('[ChatLogic] user lookup failed for $uid: $e');
    }

    // Try users table (plural)
    try {
      final res = await _supabase
          .from('users')
          .select('first_name, last_name')
          .eq('uid', uid)
          .maybeSingle();
      if (res != null) return '${res['first_name']} ${res['last_name']}'.trim();
    } catch (e) {
      debugPrint('[ChatLogic] users lookup failed for $uid: $e');
    }

    debugPrint('[ChatLogic] could not resolve name for uid: $uid');
    return null;
  }
}
