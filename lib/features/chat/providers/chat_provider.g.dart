// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isSpeakingHash() => r'75c517a5c3d65c8ce948def7756adc1afea3a8ca';

/// See also [IsSpeaking].
@ProviderFor(IsSpeaking)
final isSpeakingProvider =
    AutoDisposeNotifierProvider<IsSpeaking, bool>.internal(
      IsSpeaking.new,
      name: r'isSpeakingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$isSpeakingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$IsSpeaking = AutoDisposeNotifier<bool>;
String _$isProcessingHash() => r'a8105ad8ef6f7574af26870b7f17170fbbcaf95a';

/// See also [IsProcessing].
@ProviderFor(IsProcessing)
final isProcessingProvider =
    AutoDisposeNotifierProvider<IsProcessing, bool>.internal(
      IsProcessing.new,
      name: r'isProcessingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$isProcessingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$IsProcessing = AutoDisposeNotifier<bool>;
String _$isTypingHash() => r'80a930a55d0261d9781eb7bf2e3e664df378289d';

/// See also [IsTyping].
@ProviderFor(IsTyping)
final isTypingProvider = AutoDisposeNotifierProvider<IsTyping, bool>.internal(
  IsTyping.new,
  name: r'isTypingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isTypingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$IsTyping = AutoDisposeNotifier<bool>;
String _$chatNotifierHash() => r'e2abfbc91cc52507c8d510d8027697572a6a6465';

/// See also [ChatNotifier].
@ProviderFor(ChatNotifier)
final chatNotifierProvider =
    NotifierProvider<ChatNotifier, List<ChatMessage>>.internal(
      ChatNotifier.new,
      name: r'chatNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatNotifier = Notifier<List<ChatMessage>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
