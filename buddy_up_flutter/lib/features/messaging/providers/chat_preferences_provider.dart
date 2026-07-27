import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPreferences {
  final String background;
  final String senderBubbleColor;
  final String receiverBubbleColor;

  const ChatPreferences({
    this.background = '',
    this.senderBubbleColor = '',
    this.receiverBubbleColor = '',
  });

  ChatPreferences copyWith({
    String? background,
    String? senderBubbleColor,
    String? receiverBubbleColor,
  }) {
    return ChatPreferences(
      background: background ?? this.background,
      senderBubbleColor: senderBubbleColor ?? this.senderBubbleColor,
      receiverBubbleColor: receiverBubbleColor ?? this.receiverBubbleColor,
    );
  }

  Map<String, dynamic> toJson() => {
    'background': background,
    'senderBubbleColor': senderBubbleColor,
    'receiverBubbleColor': receiverBubbleColor,
  };

  factory ChatPreferences.fromJson(Map<String, dynamic> json) => ChatPreferences(
    background: json['background'] as String? ?? '',
    senderBubbleColor: json['senderBubbleColor'] as String? ?? '',
    receiverBubbleColor: json['receiverBubbleColor'] as String? ?? '',
  );
}

class ChatPreferencesNotifier extends Notifier<ChatPreferences> {
  @override
  ChatPreferences build() => const ChatPreferences();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('chat_preferences');
    if (raw != null) {
      try {
        state = ChatPreferences.fromJson(raw as Map<String, dynamic>);
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_preferences', state.toJson().toString());
  }

  Future<void> setBackground(String bg) async {
    state = state.copyWith(background: bg);
    await _save();
  }

  Future<void> setSenderBubbleColor(String c) async {
    state = state.copyWith(senderBubbleColor: c);
    await _save();
  }

  Future<void> setReceiverBubbleColor(String c) async {
    state = state.copyWith(receiverBubbleColor: c);
    await _save();
  }

  Future<void> resetAll() async {
    state = const ChatPreferences();
    await _save();
  }
}

final chatPreferencesProvider =
    NotifierProvider<ChatPreferencesNotifier, ChatPreferences>(
  ChatPreferencesNotifier.new,
);
