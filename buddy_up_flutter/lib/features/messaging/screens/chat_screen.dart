import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/messaging_provider.dart';
import '../providers/livekit_call_provider.dart';
import '../utils/conversation_identity.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/reply_preview.dart';
import '../widgets/attachment_menu.dart';
import '../widgets/voice_note_recorder.dart';
import 'package:dio/dio.dart';
import '../../../data/models/messaging.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/widgets/toast.dart';

/// Flat strip above the thread explaining where this chat stands as a buddy
/// relationship. Solid tint only — no gradient, no glow.
class _BuddyBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Widget? action;

  const _BuddyBanner({
    required this.icon,
    required this.color,
    required this.label,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color.withValues(alpha: 0.1),
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: BuddyColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class _PromoteAction extends StatelessWidget {
  final VoidCallback onPressed;

  const _PromoteAction({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: BuddyColors.green,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Ask',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  /// Set when opened from Buddy messages. The header then reads the thread as
  /// a discovery chat and can offer "Promote to main chat" — the same action
  /// a thread started from Find a Buddy needs, without duplicating the screen.
  final bool fromBuddyMessages;

  const ChatScreen({
    super.key,
    required this.conversationId,
    this.fromBuddyMessages = false,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _imagePicker = ImagePicker();
  Message? _replyToMessage;
  bool _promoting = false;

  /// Conversation the header reads when the list provider does not carry this
  /// thread — a Buddy-messages deep link, or a conversation the discovery
  /// filter has not picked up. The provider copy always wins when present, so
  /// this is a fallback, never a cache that shadows fresher data.
  Conversation? _convo;

  StreamSubscription<ChatEvent>? _socketSub;

  String? get _myUserId => ref.read(authProvider).user?.id;

  // Chat theme
  Color? _bgColor;
  Color? _senderColor;
  Color? _receiverColor;

  void _loadTheme() {
    SharedPreferences.getInstance().then((prefs) {
      final raw = prefs.getString('chat_preferences');
      if (raw == null) return;
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        setState(() {
          if ((map['background'] as String?)?.isNotEmpty == true) {
            _bgColor = Color(int.parse(map['background'].toString().replaceFirst('#', '0xff')));
          }
          if ((map['senderBubbleColor'] as String?)?.isNotEmpty == true) {
            _senderColor = Color(int.parse(map['senderBubbleColor'].toString().replaceFirst('#', '0xff')));
          }
          if ((map['receiverBubbleColor'] as String?)?.isNotEmpty == true) {
            _receiverColor = Color(int.parse(map['receiverBubbleColor'].toString().replaceFirst('#', '0xff')));
          }
        });
      } catch (_) {}
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesProvider(widget.conversationId).notifier).loadMessages();
      _ensureConversation();
      _connectSocket();
    });
    _scrollController.addListener(_onScroll);
  }

  void _connectSocket() {
    final socket = ref.read(chatSocketProvider(widget.conversationId));
    if (socket == null) return;
    _socketSub?.cancel();
    _socketSub = socket.events.listen((event) {
      event.when(
        message: (data) {
          final msg = Message.fromJson(data);
          ref.read(messagesProvider(widget.conversationId).notifier).addMessage(msg);
          _scrollToBottom();
        },
        typingStart: (userId, username, displayName, avatarUrl) {
          ref.read(messagesProvider(widget.conversationId).notifier).setTyping(true, displayName);
        },
        typingStop: (userId, username) {
          ref.read(messagesProvider(widget.conversationId).notifier).setTyping(false, null);
        },
        read: (conversationId, readerId, messageId, count) {
          if (readerId != _myUserId) {
            ref.read(messagesProvider(widget.conversationId).notifier).setRead(readerId);
          }
        },
        react: (conversationId, messageId, reactions) {
          ref.read(messagesProvider(widget.conversationId).notifier).updateMessage(messageId, reactions);
        },
      );
    });
  }

  /// The header needs the conversation itself — its title, participants and
  /// promotion state all live on it. A deep link (or a Buddy-messages thread
  /// the filtered list does not carry yet) arrives with nothing in the
  /// provider, so pull the single record rather than showing a bare "Chat".
  Future<void> _ensureConversation({bool force = false}) async {
    final known = ref
        .read(conversationsProvider)
        .conversations
        .any((c) => c.id == widget.conversationId);
    if (known && !force) return;
    try {
      final raw = await ref.read(messagingRepositoryProvider).getConversation(widget.conversationId);
      final data = raw['data'];
      if (data is! Map<String, dynamic>) return;
      final convo = Conversation.fromJson(data);
      // Publishing to the list keeps a promoted thread in place; keeping a
      // local copy means the header still works when the active filter would
      // have dropped it.
      ref.read(conversationsProvider.notifier).updateConversation(convo);
      if (mounted) setState(() => _convo = convo);
    } catch (_) {
      // A thread we cannot read still shows its messages; only the header
      // falls back to generic text.
    }
  }

  Future<void> _startCall(String callType) async {
    await ref.read(liveKitCallProvider.notifier).join(widget.conversationId, callType);
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= _scrollController.position.minScrollExtent + 100) {
      ref.read(messagesProvider(widget.conversationId).notifier).loadMore();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage({String? mediaUrl, String? mediaMime, String? fileName, String? messageType}) {
    final body = _textController.text.trim();
    if (body.isEmpty && mediaUrl == null) return;

    final socket = ref.read(chatSocketProvider(widget.conversationId));
    if (socket == null) return;

    _textController.clear();
    final replyTo = _replyToMessage;
    setState(() => _replyToMessage = null);

    socket.sendMessagePayload({
      'body': body,
      'message_type': messageType ?? 'text',
      'media_url': mediaUrl ?? '',
      'media_mime': mediaMime ?? '',
      'file_name': fileName ?? '',
      'reply_to_id': replyTo?.id,
      'metadata': replyTo != null ? {'reply_sender_name': replyTo.senderData.displayName, 'reply_body': replyTo.body} : {},
    });
    socket.sendTypingStop();
  }

  void _handleTyping(String value) {
    final socket = ref.read(chatSocketProvider(widget.conversationId));
    if (socket == null) return;
    if (value.isNotEmpty) {
      socket.sendTypingStart();
    } else {
      socket.sendTypingStop();
    }
  }

  Future<void> _onAttachmentTap(String type) async {
    switch (type) {
      case 'camera':
        final file = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85);
        if (file != null) _uploadAndSend(XFile(file.path));
        break;
      case 'photo':
        final file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
        if (file != null) _uploadAndSend(file);
        break;
      case 'video':
        final file = await _imagePicker.pickVideo(source: ImageSource.gallery);
        if (file != null) _uploadAndSend(file);
        break;
      case 'location':
        break;
      case 'voice':
        _showVoiceRecorder();
        break;
    }
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: BuddyColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ChatThemeSheet(
        currentBg: _bgColor,
        currentSender: _senderColor,
        currentReceiver: _receiverColor,
        onApply: (bg, sender, receiver) {
          setState(() {
            _bgColor = bg;
            _senderColor = sender;
            _receiverColor = receiver;
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> _uploadAndSend(XFile file) async {
    try {
      final dio = ref.read(apiClientProvider4).dio;
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.name),
      });
      final response = await dio.post('/messaging/upload/', data: form);
      final data = response.data['data'] as Map<String, dynamic>;
      final socket = ref.read(chatSocketProvider(widget.conversationId));
      socket?.sendMessagePayload({
        'body': '',
        'message_type': file.name.endsWith('.mp4') ? 'video' : 'photo',
        'media_url': data['url'],
        'media_mime': data['mime'],
        'file_name': file.name,
      });
    } catch (_) {}
  }

  void _showVoiceRecorder() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => VoiceNoteRecorder(
        onSend: (durationMs) {
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  // ── Buddy promotion ───────────────────────────────────────────────────────
  //
  // A Find-a-Buddy chat is a DM with no commitment behind it. Promotion asks
  // the other person to confirm, and only then does the backend flip them to
  // confirmed buddies. Three states, and the user should never have to guess
  // which one they are in:
  //   * no promotion yet      → offer the ask
  //   * pending               → "waiting on them", with a way to call it off
  //   * accepted              → "Now buddies", and the action disappears
  // A thread where they asked *me* is the same pending state from this side;
  // the accept/decline decision lives in their copy of the app.

  Future<void> _promote() async {
    if (_promoting) return;
    setState(() => _promoting = true);
    final err = await ref
        .read(conversationsProvider.notifier)
        .promoteConversation(widget.conversationId);
    // Re-read the thread so the banner flips to its new state whether or not
    // the active filter kept the row.
    await _ensureConversation(force: true);
    if (!mounted) return;
    setState(() => _promoting = false);
    showToast(
      context,
      err ?? 'Sent — waiting on them to say yes.',
      type: err == null ? ToastType.success : ToastType.error,
    );
  }

  Widget _promotionBanner(Conversation? convo) {
    final status = convo?.promotionStatus;
    final promoted = convo?.origin == 'buddy' || convo?.promotedAt != null;
    if (promoted || status == 'accepted') {
      return const _BuddyBanner(
        icon: Icons.check_circle_outline,
        color: BuddyColors.green,
        label: 'Now buddies',
      );
    }
    if (status == 'pending') {
      return const _BuddyBanner(
        icon: Icons.hourglass_top,
        color: BuddyColors.gold,
        label: 'Buddy request pending — waiting on them',
      );
    }
    if (status == 'declined') {
      return const _BuddyBanner(
        icon: Icons.remove_circle_outline,
        color: BuddyColors.textSecondary,
        label: 'Buddy request declined',
      );
    }
    if (convo == null || !convo.promotable) return const SizedBox.shrink();
    return _BuddyBanner(
      icon: Icons.handshake_outlined,
      color: BuddyColors.green,
      label: _promoting ? 'Sending…' : 'Promote to main chat',
      action: _promoting
          ? null
          : _PromoteAction(
              key: const ValueKey('chat-promote-action'),
              onPressed: _promote,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesProvider(widget.conversationId));
    final conversationsState = ref.watch(conversationsProvider);
    final convo = conversationsState.conversations.where((c) => c.id == widget.conversationId).firstOrNull ?? _convo;

    final other = convo?.participantsData.where((p) => p.userId != _myUserId).firstOrNull;
    final identity = ConversationIdentity.of(convo, _myUserId);
    final title = identity.name;
    final isGroupChat = identity.isGroup;

    final displayMessages = messagesState.messages.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: BuddyColors.surfaceRaised,
              backgroundImage: identity.avatarUrl.isNotEmpty ? NetworkImage(identity.avatarUrl) : null,
              child: identity.avatarUrl.isEmpty
                  ? Text((title.isNotEmpty ? title[0] : '?').toUpperCase(),
                      style: const TextStyle(color: BuddyColors.textPrimary))
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  if (messagesState.isTyping)
                    const Text('typing...', style: TextStyle(fontSize: 11, color: BuddyColors.green))
                  else if (isGroupChat)
                    Text('${convo?.participantsData.length ?? 0} members',
                        style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary))
                  else
                    Text(other?.username ?? '', style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            tooltip: 'Audio call',
            onPressed: () => _startCall('audio'),
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            tooltip: 'Video call',
            onPressed: () => _startCall('video'),
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Chat theme',
            onPressed: () => _showThemePicker(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.fromBuddyMessages) _promotionBanner(convo),
          Expanded(
            child: Container(
              color: _bgColor,
              child: messagesState.isLoading
                ? const Center(child: CircularProgressIndicator(color: BuddyColors.green))
                : displayMessages.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 48, color: BuddyColors.textSecondary),
                                SizedBox(height: 12),
                                Text('Say hello!', style: TextStyle(color: BuddyColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        itemCount: displayMessages.length + (messagesState.isTyping ? 1 : 0),
                        itemBuilder: (_, index) {
                          if (index == 0 && messagesState.isTyping) {
                            return const Padding(
                              padding: EdgeInsets.only(left: 12, bottom: 8),
                              child: TypingIndicator(),
                            );
                          }
                          final msgIndex = messagesState.isTyping ? index - 1 : index;
                          final msg = displayMessages[msgIndex];
                          final isMine = msg.senderId == _myUserId;
                          final nextMsg = msgIndex < displayMessages.length - 1 ? displayMessages[msgIndex + 1] : null;
                          final showSender = !isMine && (nextMsg == null || nextMsg.senderId != msg.senderId);

                          return MessageBubble(
                            message: msg,
                            isMine: isMine,
                            showSender: showSender,
                            senderBubbleColor: _senderColor,
                            receiverBubbleColor: _receiverColor,
                            onReply: () => setState(() => _replyToMessage = msg),
                            onReact: (emoji) {
                              final socket = ref.read(chatSocketProvider(widget.conversationId));
                              socket?.sendReact(msg.id, emoji);
                            },
                            onDelete: () {
                              ref.read(messagesProvider(widget.conversationId).notifier).removeMessage(msg.id);
                            },
                            onForward: () {},
                          );
                        },
                      ),
                    ),
          ),
          if (_replyToMessage != null)
            ReplyPreview(
              message: _replyToMessage!,
              onDismiss: () => setState(() => _replyToMessage = null),
            ),
          Container(
            decoration: const BoxDecoration(
              color: BuddyColors.surface,
              border: Border(top: BorderSide(color: BuddyColors.border)),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: BuddyColors.textSecondary),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (_) => AttachmentMenu(onSelect: _onAttachmentTap),
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        onChanged: _handleTyping,
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: 5,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          hintText: 'Message...',
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        ),
                      ),
                    ),
                    if (_textController.text.trim().isEmpty)
                      IconButton(
                        icon: const Icon(Icons.mic_outlined, color: BuddyColors.textSecondary),
                        onPressed: _showVoiceRecorder,
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: BuddyColors.green),
                        onPressed: () => _sendMessage(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatThemeSheet extends StatefulWidget {
  final Color? currentBg;
  final Color? currentSender;
  final Color? currentReceiver;
  final void Function(Color? bg, Color? sender, Color? receiver) onApply;

  const _ChatThemeSheet({
    this.currentBg,
    this.currentSender,
    this.currentReceiver,
    required this.onApply,
  });

  @override
  State<_ChatThemeSheet> createState() => _ChatThemeSheetState();
}

class _ChatThemeSheetState extends State<_ChatThemeSheet> {
  late Color? _bg;
  late Color? _sender;
  late Color? _receiver;

  static const _bgPresets = [
    null,
    Color(0xFF1a1a2e),
    Color(0xFF0f0c29),
    Color(0xFF0b1a11),
    Color(0xFF2d1b0e),
    Color(0xFF1a0b2e),
    Color(0xFF0f172a),
    Color(0xFF1e1e1e),
  ];

  static const _bubblePresets = [
    null,
    Color(0xFF60a5fa),
    Color(0xFFa78bfa),
    Color(0xFFf472b6),
    Color(0xFF5eead4),
    Color(0xFFfb923c),
    Color(0xFFf87171),
    Color(0xFFffffff),
  ];

  @override
  void initState() {
    super.initState();
    _bg = widget.currentBg;
    _sender = widget.currentSender;
    _receiver = widget.currentReceiver;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: BuddyColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Preview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _bg ?? BuddyColors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _sender ?? BuddyColors.green.withValues(alpha: 0.15),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16), topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16), bottomRight: Radius.circular(4),
                              ),
                            ),
                            child: const Text('Hey! How is it going?', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _receiver ?? BuddyColors.surface,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16), topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(4), bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: const Text('I am good, thanks!', style: TextStyle(fontSize: 13, color: BuddyColors.textPrimary)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Background presets
                  const Text('Background', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _bgPresets.map((c) {
                      final selected = _bg == c;
                      return GestureDetector(
                        onTap: () => setState(() => _bg = c),
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: c ?? BuddyColors.black,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? BuddyColors.green : BuddyColors.surfaceRaised,
                              width: selected ? 2.5 : 1,
                            ),
                          ),
                          child: c == null
                              ? const Center(child: Text('X', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)))
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Sender color
                  const Text('Your bubble color', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _bubblePresets.map((c) {
                      final selected = _sender == c;
                      return GestureDetector(
                        onTap: () => setState(() => _sender = c),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: c ?? BuddyColors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? BuddyColors.green : BuddyColors.surfaceRaised,
                              width: selected ? 2.5 : 1,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check, size: 16, color: BuddyColors.green)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Receiver color
                  const Text('Their bubble color', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _bubblePresets.map((c) {
                      final selected = _receiver == c;
                      return GestureDetector(
                        onTap: () => setState(() => _receiver = c),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: c ?? BuddyColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? BuddyColors.green : BuddyColors.surfaceRaised,
                              width: selected ? 2.5 : 1,
                            ),
                          ),
                          child: selected
                              ? const Icon(Icons.check, size: 16, color: BuddyColors.green)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => widget.onApply(_bg, _sender, _receiver),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BuddyColors.green,
                        foregroundColor: BuddyColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Apply Theme', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
