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

  Stream<List<Map<String, dynamic>>> getActivePartners() {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return const Stream.empty();

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .asyncMap((messages) async {
      messages.sort((a, b) => b['created_at'].compareTo(a['created_at']));
      
      final partnerIds = <String>{};
      final latestMsgMap = <String, Map<String, dynamic>>{};

      for (var m in messages) {
        if (m['sender_id'] == uid || m['receiver_id'] == uid) {
          final pId = m['sender_id'] == uid ? m['receiver_id'] : m['sender_id'];
          if (pId != null && pId.toString().trim().isNotEmpty && !partnerIds.contains(pId)) {
            partnerIds.add(pId);
            latestMsgMap[pId] = m;
          }
        }
      }

      // Also fetch Active jobs so you can chat with any accepted mechanics/users.
      try {
        final jobsRes = await _supabase
            .from('jobs')
            .select('user_id, mechanic_id, status')
            .or('user_id.eq.$uid,mechanic_id.eq.$uid');
            
        for (var job in jobsRes) {
          if (job['status'] != 'pending' && job['status'] != 'completed' && job['status'] != 'canceled') {
            final pId = job['user_id'] == uid ? job['mechanic_id'] : job['user_id'];
            if (pId != null && pId.toString().trim().isNotEmpty && !partnerIds.contains(pId)) {
              partnerIds.add(pId);
            }
          }
        }
      } catch (e) {
        // ignore errors if jobs fails
      }

      final profilesMap = <String, String>{};
      for (var id in partnerIds) {
        String? partnerName;
        // Try mechanic
        try {
          final res = await _supabase.from('mechanic').select('first_name, last_name').eq('uid', id).maybeSingle();
          if (res != null) partnerName = '${res['first_name']} ${res['last_name']}';
        } catch (e) {
          print('Error fetching mechanic for $id: $e');
        }
        
        // Try driver
        if (partnerName == null) {
          try {
            final res = await _supabase.from('driver').select('first_name, last_name').eq('uid', id).maybeSingle();
            if (res != null) partnerName = '${res['first_name']} ${res['last_name']}';
          } catch (e) {
            print('Error fetching driver for $id: $e');
          }
        }
        
        // Try users
        if (partnerName == null) {
          try {
            final res = await _supabase.from('users').select('first_name, last_name').eq('uid', id).maybeSingle();
            if (res != null) partnerName = '${res['first_name']} ${res['last_name']}';
          } catch (_) {}
        }
        
        // Try user
        if (partnerName == null) {
          try {
            final res = await _supabase.from('user').select('first_name, last_name').eq('uid', id).maybeSingle();
            if (res != null) partnerName = '${res['first_name']} ${res['last_name']}';
          } catch (_) {}
        }

        if (partnerName != null && partnerName.trim().isNotEmpty) {
          profilesMap[id.toString()] = partnerName.trim();
        }
      }

      final result = <Map<String, dynamic>>[];
      for (var pId in partnerIds) {
        final msg = latestMsgMap[pId];
        result.add({
          'partner_id': pId,
          'name': profilesMap[pId.toString()] ?? 'User',
          'last_message': msg?['content'] ?? 'Tap to chat',
          'time': msg?['created_at'],
          'is_unread': msg != null && msg['receiver_id'] == uid && msg['is_read'] == false,
        });
      }
      return result;
    });
  }
}
