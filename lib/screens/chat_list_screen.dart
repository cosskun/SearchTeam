import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/chat_session.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (dt.year == now.year && dt.month == now.month && dt.day == now.day - 1) {
      return 'Dün';
    } else {
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUser = appState.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Lütfen giriş yapın.'),
        ),
      );
    }

    // Filter conversations involving the current user
    final mySessions = appState.chatSessions.where((session) {
      return session.memberIds.contains(currentUser.id);
    }).toList();

    // Sort by last message time descending
    mySessions.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: mySessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz sohbetiniz yok.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'İlan detaylarından oyuncularla iletişime geçebilirsiniz.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: mySessions.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withOpacity(0.05),
                height: 1,
                indent: 80,
              ),
              itemBuilder: (context, index) {
                final session = mySessions[index];
                
                // Find the other member in the chat session
                final recipientId = session.memberIds.firstWhere((id) => id != currentUser.id);
                final recipientIndex = appState.users.indexWhere((u) => u.id == recipientId);
                
                if (recipientIndex == -1) return const SizedBox.shrink();
                final recipient = appState.users[recipientIndex];

                final unreadCount = session.unreadCountByUserId[currentUser.id] ?? 0;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  onTap: () {
                    // Navigate to the Chat Room
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomScreen(
                          sessionId: session.id,
                          recipientUser: recipient,
                        ),
                      ),
                    );
                  },
                  leading: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          recipient.avatarUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                              child: Text(
                                recipient.name[0].toUpperCase(),
                                style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.cardDark, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        recipient.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _formatTime(session.lastMessageTime),
                        style: TextStyle(
                          fontSize: 11,
                          color: unreadCount > 0 ? AppTheme.primaryGreen : AppTheme.textMuted,
                          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            session.lastMessageText,
                            style: TextStyle(
                              fontSize: 13,
                              color: unreadCount > 0 ? Colors.white : AppTheme.textMuted,
                              fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
