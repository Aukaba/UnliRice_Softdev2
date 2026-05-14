import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../Logic/chat/chat_logic.dart';
import 'homescreen.dart';
import 'jobs.dart';
import 'schedule.dart';
import 'profile.dart';

class MechanicChatScreen extends StatefulWidget {
  const MechanicChatScreen({super.key});

  @override
  State<MechanicChatScreen> createState() => _MechanicChatScreenState();
}

class _MechanicChatScreenState extends State<MechanicChatScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  StreamSubscription? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _listenForNewMessages();
    // Clean up expired conversations (2 days after job completion)
    ChatLogic().deleteExpiredMessages();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  // Load all conversations for the current mechanic
Future<void> _loadConversations() async {
  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    debugPrint('[Chat] Loading conversations for: $userId');

    // ✅ Simple query without joins
    final messages = await Supabase.instance.client
        .from('messages')
        .select('*')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);

    debugPrint('[Chat] Total messages found: ${messages.length}');

    if (messages.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Group by conversation partner
    final Map<String, Map<String, dynamic>> conversationMap = {};

    for (final msg in messages) {
      final senderId = msg['sender_id'] as String;
      final receiverId = msg['receiver_id'] as String;
      final otherUserId = senderId == userId ? receiverId : senderId;

if (!conversationMap.containsKey(otherUserId)) {
  String userName = 'User';
  
  try {
    // ✅ Use the correct table name with proper quoting
    final userData = await Supabase.instance.client
        .from('user')  // This is your actual table name
        .select('first_name, last_name')
        .eq('uid', otherUserId)
        .maybeSingle();
    
    debugPrint('[Chat] User lookup for $otherUserId: $userData');
    
    if (userData != null) {
      final first = userData['first_name'] ?? '';
      final last = userData['last_name'] ?? '';
      userName = '$first $last'.trim();
      if (userName.isEmpty) userName = 'User';
    }
  } catch (e) {
    debugPrint('[Chat] Error looking up user $otherUserId: $e');
  }

  conversationMap[otherUserId] = {
    'user_id': otherUserId,
    'name': userName,
    'vehicle': '',
    'last_message': msg['content'] ?? '',
    'time': msg['created_at'] ?? '',
    'unread_count': 0,
  };
}

      // Count unread
      if (msg['receiver_id'] == userId && msg['is_read'] == false) {
        conversationMap[otherUserId]!['unread_count'] = 
            (conversationMap[otherUserId]!['unread_count'] as int) + 1;
      }
    }

    debugPrint('[Chat] Conversations: ${conversationMap.length}');

    if (mounted) {
      setState(() {
        _conversations = conversationMap.values.toList();
        _isLoading = false;
      });
    }
  } catch (e) {
    debugPrint('[Chat] Error: $e');
    if (mounted) setState(() => _isLoading = false);
  }
}
  Future<Map<String, dynamic>> _getUserInfo(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('users')
          .select('first_name, last_name')
          .eq('uid', userId)
          .maybeSingle();
      return data ?? {};
    } catch (e) {
      return {};
    }
  }

  void _listenForNewMessages() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _messagesSubscription = Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId)
        .listen((data) {
      _loadConversations(); // Reload conversations when new message arrives
    });
  }

  String _formatTime(String timestamp) {
    final dateTime = DateTime.tryParse(timestamp);
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}';
  }

  int get totalUnread {
    return _conversations.fold(0, (sum, conv) => sum + (conv['unread_count'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative amber blobs
            Positioned(
              left: -60,
              top: 180,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  color: Color(0x33FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -50,
              bottom: 80,
              child: Container(
                width: 260,
                height: 260,
                decoration: const BoxDecoration(
                  color: Color(0x26FFB703),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB703),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.chat_bubble_outline_rounded,
                            color: Color(0xFFFFB703), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Messages',
                              style: GoogleFonts.montserrat(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '$totalUnread unread',
                              style: GoogleFonts.inriaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.notifications_none,
                                color: Colors.black87),
                          ),
                          if (totalUnread > 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDD2E44),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Thread list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFB703)))
                      : _conversations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text('No messages yet', style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                              itemCount: _conversations.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final conv = _conversations[index];
                                 return _ChatCard(
                                   name: conv['name'] ?? 'User',
                                   vehicle: conv['vehicle'] ?? '',
                                   lastMessage: conv['last_message'] ?? '',
                                   timeAgo: _formatTime(conv['time'] ?? ''),
                                   unreadCount: conv['unread_count'] as int,
                                   onTap: () {
                                     _openChat(
                                       userId: conv['user_id'] as String,
                                       userName: conv['name'] as String,
                                       vehicle: conv['vehicle'] ?? '',
                                     );
                                   },
                                 );
                              },
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MechanicBottomNavigationBar(
        currentIndex: 3,
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MechanicHomeScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MechanicJobsScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MechanicScheduleScreen()));
          } else if (index == 4) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MechanicProfileScreen()));
          }
        },
      ),
    );
  }

  void _openChat({required String userId, required String userName, String vehicle = ''}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ChatDetailScreen(
          receiverId: userId,
          receiverName: userName,
          vehicleModel: vehicle,
        ),
      ),
    );
  }
}

// ─── Chat card ────────────────────────────────────────────────────────────────

class _ChatCard extends StatelessWidget {
  final String name;
  final String vehicle;
  final String lastMessage;
  final String timeAgo;
  final int unreadCount;
  final VoidCallback onTap;

  const _ChatCard({
    required this.name,
    this.vehicle = '',
    required this.lastMessage,
    required this.timeAgo,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFB703),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$unreadCount',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
                            if (vehicle.isNotEmpty)
                              Text(vehicle, style: GoogleFonts.inriaSans(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.black45)),
                          ],
                        ),
                      ),
                      Text(timeAgo, style: GoogleFonts.inriaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black38)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inriaSans(
                      fontSize: 13,
                      fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w400,
                      color: unreadCount > 0 ? Colors.black87 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Individual Chat Screen ───────────────────────────────────────────────────

class _ChatDetailScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String vehicleModel;

  const _ChatDetailScreen({
    required this.receiverId,
    required this.receiverName,
    this.vehicleModel = '',
  });

  @override
  State<_ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<_ChatDetailScreen> {
  final _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;
  String _vehicleModel = '';

  @override
  void initState() {
    super.initState();
    _vehicleModel = widget.vehicleModel;
    _loadMessages();
    _listenForMessages();
    if (_vehicleModel.isEmpty) {
      ChatLogic().getVehicleModelForPartner(widget.receiverId).then((v) {
        if (mounted && v.isNotEmpty) setState(() => _vehicleModel = v);
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final messages = await Supabase.instance.client
          .from('messages')
          .select('*')
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: true);

      // Filter messages between these two users
      final conversationMessages = messages.where((msg) {
        final sender = msg['sender_id'] as String;
        final receiver = msg['receiver_id'] as String;
        return (sender == userId && receiver == widget.receiverId) ||
            (sender == widget.receiverId && receiver == userId);
      }).toList();

      if (mounted) {
        setState(() {
          _messages = conversationMessages;
          _isLoading = false;
        });
      }

      // Mark messages as read
      await _markMessagesAsRead();
    } catch (e) {
      debugPrint("Error loading messages: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markMessagesAsRead() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await Supabase.instance.client
        .from('messages')
        .update({'is_read': true})
        .eq('receiver_id', userId)
        .eq('sender_id', widget.receiverId)
        .eq('is_read', false);
  }

  void _listenForMessages() {
    _subscription = Supabase.instance.client
        .from('messages')
        .stream(primaryKey: ['id'])
        .listen((data) {
      _loadMessages();
    });
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await Supabase.instance.client.from('messages').insert({
        'sender_id': userId,
        'receiver_id': widget.receiverId,
        'content': content,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      _messageController.clear();
      _loadMessages();
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB703),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receiverName, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 16)),
            if (_vehicleModel.isNotEmpty)
              Text(_vehicleModel, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.black54)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['sender_id'] == Supabase.instance.client.auth.currentUser?.id;
                      return _MessageBubble(
                        message: msg['content'] ?? '',
                        isMe: isMe,
                        time: msg['created_at'] ?? '',
                      );
                    },
                  ),
          ),
          // Message input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.inriaSans(color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB703),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateTime.tryParse(time);
    final formattedTime = timeStr != null
        ? '${timeStr.hour}:${timeStr.minute.toString().padLeft(2, '0')}'
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFFFB703) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message, style: GoogleFonts.inriaSans(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(formattedTime, style: GoogleFonts.inriaSans(fontSize: 10, color: Colors.black38)),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom nav ───────────────────────────────────────────────────────────────

class _MechanicBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const _MechanicBottomNavigationBar(
      {required this.currentIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                active: currentIndex == 0,
                onTap: () => onItemTapped(0)),
            _NavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Jobs',
                active: currentIndex == 1,
                onTap: () => onItemTapped(1)),
            _NavItem(
                icon: Icons.calendar_month_outlined,
                label: 'Schedule',
                active: currentIndex == 2,
                onTap: () => onItemTapped(2)),
            _NavItem(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                active: currentIndex == 3,
                onTap: () => onItemTapped(3)),
            _NavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                active: currentIndex == 4,
                onTap: () => onItemTapped(4)),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem(
      {required this.icon,
      required this.label,
      this.active = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFFFB703) : Colors.black54;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: active ? const Color(0x33FFB703) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inriaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}