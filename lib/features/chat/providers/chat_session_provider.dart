import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';
import 'package:uuid/uuid.dart';

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'chat_session_provider.g.dart';

@Riverpod(keepAlive: true)
class ChatSessionManager extends _$ChatSessionManager {
  final _uuid = const Uuid();
  final _storage = const FlutterSecureStorage();
  static const _storageKey = 'chat_sessions_history';

  @override
  List<ChatSession> build() {
    _loadFromStorage();
    return [];
  }

  Future<void> _loadFromStorage() async {
    try {
      final data = await _storage.read(key: _storageKey);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        state = decoded.map((e) => ChatSession.fromJson(e)).toList();
      }
    } catch (e) {
      print('Failed to load chat sessions: $e');
    }
  }

  Future<void> _saveToStorage(List<ChatSession> sessions) async {
    try {
      final encoded = jsonEncode(sessions.map((e) => e.toJson()).toList());
      await _storage.write(key: _storageKey, value: encoded);
    } catch (e) {
      print('Failed to save chat sessions: $e');
    }
  }

  void saveSession(String id, List<ChatMessage> messages) {
    if (messages.isEmpty) return;
    
    final title = messages.firstWhere((m) => m.isUser, orElse: () => messages.first).text;
    // Keep title short
    final shortTitle = title.length > 40 ? '${title.substring(0, 40)}...' : title;

    final existingIndex = state.indexWhere((s) => s.id == id);
    
    if (existingIndex >= 0) {
      final updated = state[existingIndex].copyWith(
        messages: messages,
        title: shortTitle,
        timestamp: DateTime.now(),
      );
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex) updated else state[i],
      ];
    } else {
      final newSession = ChatSession(
        id: id,
        title: shortTitle,
        messages: messages,
        timestamp: DateTime.now(),
      );
      state = [newSession, ...state];
    }
    
    // Persist to storage
    _saveToStorage(state);
  }

  ChatSession? getSession(String id) {
    return state.where((s) => s.id == id).firstOrNull;
  }
}
