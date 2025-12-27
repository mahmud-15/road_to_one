import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/services/storage/storage_services.dart';

import '../../data/chat_model.dart' show ChatMessage;
import '../../data/story_model.dart';
import '../screen/message_screen.dart';

class ChatController extends GetxController {
  var searchController = TextEditingController();
  final conversations = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isRefreshing = false.obs;

  final stories = <Story>[].obs;
  final storyLoading = false.obs;

  int _storyPage = 1;
  final int _storyLimit = 10;
  bool _storyHasMore = true;

  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  String _currentSearchTerm = '';
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchStories(refresh: true);
    fetchConversations(refresh: true);
  }

  String _normalizeImageUrl(String value) {
    final v = value.trim();
    if (v.isEmpty) return '';
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    return ApiEndPoint.imageUrl + v;
  }

  Future<void> fetchStories({
    bool refresh = false,
  }) async {
    if (storyLoading.value) return;

    if (refresh) {
      _storyPage = 1;
      _storyHasMore = true;
      stories.clear();
      stories.add(
        Story(
          id: '',
          name: 'Your Story',
          avatar: _normalizeImageUrl(LocalStorage.profileImage),
          isYourStory: true,
        ),
      );
    }

    if (!_storyHasMore && !refresh) return;
    storyLoading.value = true;

    try {
      final url = "${ApiEndPoint.story}/?page=$_storyPage&limit=$_storyLimit";
      final response = await ApiService2.get(url);
      if (response == null || (response.statusCode != 200 && response.statusCode != 201)) {
        _storyHasMore = false;
        return;
      }

      final data = response.data;
      final items = (data is Map && data['data'] is List) ? (data['data'] as List) : <dynamic>[];
      final parsed = items
          .whereType<Map>()
          .map((e) {
            final s = Story.fromApiJson(Map<String, dynamic>.from(e));
            return Story(
              id: s.id,
              name: s.name,
              avatar: _normalizeImageUrl(s.avatar),
              isYourStory: false,
            );
          })
          .toList(growable: false);

      stories.addAll(parsed);
      _storyHasMore = parsed.length == _storyLimit;
      if (_storyHasMore) _storyPage += 1;
    } finally {
      storyLoading.value = false;
    }
  }

  String _timeAgoShort(String? iso) {
    if (iso == null || iso.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays >= 1) return '${diff.inDays}d';
      if (diff.inHours >= 1) return '${diff.inHours}h';
      if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
      return 'now';
    } catch (_) {
      return '';
    }
  }

  Future<void> fetchConversations({
    bool refresh = false,
    String? searchTerm,
  }) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    final term = (searchTerm ?? _currentSearchTerm).trim();
    _currentSearchTerm = term;

    if (!_hasMore && !refresh) return;
    if (isLoading.value && !refresh) return;
    if (isLoadingMore.value && !refresh) return;

    if (refresh) {
      isRefreshing.value = true;
      isLoading.value = conversations.isEmpty;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final q = <String>[
        'page=$_page',
        'limit=$_limit',
        if (term.isNotEmpty) 'searchTerm=${Uri.encodeQueryComponent(term)}',
      ].join('&');

      final url = '${ApiEndPoint.conversation}?$q';
      final response = await ApiService2.get(url);
      if (response == null || (response.statusCode != 200 && response.statusCode != 201)) {
        _hasMore = false;
        return;
      }

      final data = response.data;
      final items = (data is Map &&
              data['data'] is Map &&
              (data['data'] as Map)['data'] is List)
          ? ((data['data'] as Map)['data'] as List)
          : <dynamic>[];

      final parsed = items
          .whereType<Map>()
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            final timeLabel = _timeAgoShort(map['updatedAt']?.toString());
            return ChatMessage.fromConversationJson(map, timeLabel: timeLabel);
          })
          .toList(growable: false);

      if (refresh) {
        conversations.assignAll(parsed);
      } else {
        conversations.addAll(parsed);
      }

      _hasMore = parsed.length == _limit;
      if (_hasMore) _page += 1;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      isRefreshing.value = false;
    }
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      fetchConversations(refresh: true, searchTerm: query);
    });
  }

  Future<void> refreshConversations() async {
    await fetchConversations(refresh: true);
  }

  Future<void> loadMoreIfNeeded(int index) async {
    if (index >= conversations.length - 2) {
      await fetchConversations(refresh: false);
    }
  }

  void onChatTap(ChatMessage chat) {
    Get.to(() => MessageScreen(
      conversationId: chat.id,
      receiverId: chat.participantId,
      chatName: chat.name,
      chatAvatar: chat.avatar,
      isOnline: chat.isOnline,
    ));
  }

  void onStoryTap(Story story) {
    // Navigate to story view screen
    print('Opening story of ${story.name}');
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}