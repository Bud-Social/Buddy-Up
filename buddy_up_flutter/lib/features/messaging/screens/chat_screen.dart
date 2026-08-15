import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/messaging_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/reply_preview.dart';
import '../widgets/attachment_menu.dart';
import '../widgets/voice_note_recorder.dart';
import 'package:dio/dio.dart';
import '../../../data/models/messaging.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/auth/auth_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _imagePicker = ImagePicker();
  Message? _replyToMessage;

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
        callOffer: (callType, data) => _forwardCall('callOffer', data: data, callType: callType),
        callAnswer: (callType, data) => _forwardCall('callAnswer', data: data, callType: callType),
        callIce: (data) => _forwardCall('callIce', data: data),
        callEnd: () => _forwardCall('callEnd'),
        callDecline: () => _forwardCall('callDecline'),
        callRinging: (data) => _forwardCall('callRinging', data: data),
      );
    });
  }

  void _forwardCall(String kind, {Map<String, dynamic>? data, String? callType}) {
    final engine = ref.read(callEngineProvider);
    if (kind == 'callOffer') {
      final convoState = ref.read(conversationsProvider);
      final convo = convoState.conversations.where((c) => c.id == widget.conversationId).firstOrNull;
      final other = convo?.participantsData.where((p) => p.userId != _myUserId).firstOrNull;
      if (other != null) {
        engine.setPeer(userId: other.userId, name: other.displayName, avatar: other.avatarUrl);
      }
    }
    engine.handleSignal(kind, data: data, callTypeFromEvent: callType);
  }

  Future<void> _startCall(String callType) async {
    final engine = ref.read(callEngineProvider);
    if (engine.isActive) return;
    final socket = ref.read(chatSocketProvider(widget.conversationId));
    if (socket == null) return;
    final convoState = ref.read(conversationsProvider);
    final convo = convoState.conversations.where((c) => c.id == widget.conversationId).firstOrNull;
    final other = convo?.participantsData.where((p) => p.userId != _myUserId).firstOrNull;
    if (other == null) return;
    await engine.startCall(
      socket: socket,
      conversationId: widget.conversationId,
      callType: callType,
      peerName: other.displayName,
      peerAvatar: other.avatarUrl,
      peerUserId: other.userId,
    );
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

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesProvider(widget.conversationId));
    final conversationsState = ref.watch(conversationsProvider);
    final convo = conversationsState.conversations.where((c) => c.id == widget.conversationId).firstOrNull;

    final other = convo?.participantsData.where((p) => p.userId != _myUserId).firstOrNull;
    final title = convo?.isGroup == true
        ? ((convo?.groupName ?? '').isNotEmpty ? convo?.groupName ?? 'Group' : 'Group')
        : (other?.displayName ?? 'Chat');

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
              backgroundImage: other?.avatarUrl.isNotEmpty == true ? NetworkImage(other!.avatarUrl) : null,
              child: other?.avatarUrl.isNotEmpty != true
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
                  else
                    Text(other?.username ?? '', style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (convo?.isGroup != true && other != null) ...[
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
          ],
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Chat theme',
            onPressed: () => _showThemePicker(),
          ),
        ],
      ),
      body: Column(
        children: [
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
