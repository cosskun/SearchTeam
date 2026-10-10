import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/chat_message.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';

class ChatRoomScreen extends StatefulWidget {
  final String sessionId;
  final AppUser recipientUser;

  const ChatRoomScreen({
    super.key,
    required this.sessionId,
    required this.recipientUser,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _mockImages = [
    {
      'title': 'Saha Planı',
      'url': 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=500',
    },
    {
      'title': 'Taktik Tahtası',
      'url': 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=500',
    },
    {
      'title': 'Sakatlık Durumu',
      'url': 'https://images.unsplash.com/photo-1517466787929-bc90951d0974?w=500',
    },
    {
      'title': 'Kramponlar',
      'url': 'https://images.unsplash.com/photo-1511886929837-354d827aae26?w=500',
    },
  ];

  final List<String> _quickEmojis = ['⚽', '🏃', '🥅', '🧤', '🏆', '👍', '🔥', '👏'];

  @override
  void initState() {
    super.initState();
    // Mark messages as read on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).markChatAsRead(widget.sessionId);
      _scrollToBottom(animated: false);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 100);
      }
    }
  }

  void _sendMessage(AppState appState) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    appState.sendMessage(widget.sessionId, text);
    _textController.clear();
    
    // Scroll to bottom after message is added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _sendImage(AppState appState, String url, String title) {
    appState.sendMessage(widget.sessionId, '📷 Fotoğraf paylaşıldı: $title', imageUrl: url);
    Navigator.pop(context);
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _showImagePickerSheet(AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Görsel Gönder',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mockImages.length,
                  itemBuilder: (context, index) {
                    final img = _mockImages[index];
                    return GestureDetector(
                      onTap: () => _sendImage(appState, img['url']!, img['title']!),
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(img['url']!, fit: BoxFit.cover),
                              Container(color: Colors.black45),
                              Center(
                                child: Text(
                                  img['title']!,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUser = appState.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Lütfen giriş yapın.')));
    }

    // Filter messages for this chat session
    final sessionMessages = appState.chatMessages.where((msg) => msg.sessionId == widget.sessionId).toList();

    // Mark as read if a new message arrives while active
    final hasUnread = appState.chatSessions
        .firstWhere((s) => s.id == widget.sessionId)
        .unreadCountByUserId[currentUser.id] ?? 0;
    if (hasUnread > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appState.markChatAsRead(widget.sessionId);
      });
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                widget.recipientUser.avatarUrl,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                    child: Text(
                      widget.recipientUser.name[0].toUpperCase(),
                      style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipientUser.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Çevrimiçi (Saha Aramada)',
                    style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.recipientUser.name} aranıyor...')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Message Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: sessionMessages.length,
              itemBuilder: (context, index) {
                final msg = sessionMessages[index];
                final isSelf = msg.senderId == currentUser.id;

                return Align(
                  alignment: isSelf ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelf ? AppTheme.primaryGreen : AppTheme.cardDark,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isSelf ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isSelf ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Image if any
                        if (msg.imageUrl != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              msg.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 150,
                                  color: Colors.black26,
                                  child: const Center(
                                    child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 100,
                                  color: Colors.black26,
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.broken_image, color: Colors.orangeAccent, size: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Görsel Yüklenemedi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isSelf ? Colors.black87 : Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        // Text message
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: isSelf ? Colors.black : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Timestamp and double check icon
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _formatTime(msg.dateTime),
                              style: TextStyle(
                                color: isSelf ? Colors.black54 : AppTheme.textMuted,
                                fontSize: 10,
                              ),
                            ),
                            if (isSelf) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.done_all,
                                size: 12,
                                color: msg.isRead ? Colors.blue : Colors.black54,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick Emojis Selection Bar
          Container(
            height: 40,
            color: Colors.black26,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _quickEmojis.length,
              itemBuilder: (context, index) {
                final emoji = _quickEmojis[index];
                return InkWell(
                  onTap: () {
                    final text = _textController.text;
                    final selection = _textController.selection;
                    final newText = text.replaceRange(selection.start >= 0 ? selection.start : text.length, selection.end >= 0 ? selection.end : text.length, emoji);
                    _textController.value = TextEditingValue(
                      text: newText,
                      selection: TextSelection.collapsed(offset: (selection.start >= 0 ? selection.start : text.length) + emoji.length),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Input Control
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.cardDark,
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: AppTheme.primaryGreen),
                    onPressed: () => _showImagePickerSheet(appState),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Mesaj yazın...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        fillColor: Colors.black26,
                        filled: true,
                      ),
                      onSubmitted: (_) => _sendMessage(appState),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    onPressed: () => _sendMessage(appState),
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.black,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
