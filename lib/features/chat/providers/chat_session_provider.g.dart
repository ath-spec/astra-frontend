// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatSessionManagerHash() =>
    r'9a4a47cf72b711df10d5d308146705013104ff3e';

/// See also [ChatSessionManager].
@ProviderFor(ChatSessionManager)
final chatSessionManagerProvider =
    NotifierProvider<ChatSessionManager, List<ChatSession>>.internal(
      ChatSessionManager.new,
      name: r'chatSessionManagerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatSessionManagerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatSessionManager = Notifier<List<ChatSession>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
