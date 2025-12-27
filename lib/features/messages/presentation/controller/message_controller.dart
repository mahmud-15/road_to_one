import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/services/socket/socket_service.dart';
import 'package:road_project_flutter/services/storage/storage_services.dart';

import '../../data/message_view.dart';


class MessageController extends GetxController {
  final String conversationId;
  final String receiverId;
  final String chatName;
  final String chatAvatar;
  final bool isOnline;

  MessageController({
    required this.conversationId,
    required this.receiverId,
    required this.chatName,
    required this.chatAvatar,
    required this.isOnline,
  });

  final TextEditingController messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isSending = false.obs;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;

  final messages = <Message>[].obs;

  late final String _socketEvent;

  @override
  void onInit() {
    super.onInit();
    _socketEvent = 'new_message::$conversationId';
    SocketServices.on(_socketEvent, _onSocketMessage);
    fetchMessages(refresh: true);
  }

  Message _parseMessageFromMap(Map<String, dynamic> map) {
    final sender = _extractSenderId(map['sender']);
    final text = map['text']?.toString() ?? '';

    String? image;
    final rawImage = map['image'];
    if (rawImage is String && rawImage.trim().isNotEmpty) {
      image = _normalizeImageUrl(rawImage);
    } else if (rawImage is List && rawImage.isNotEmpty) {
      final first = rawImage.first;
      if (first != null && first.toString().trim().isNotEmpty) {
        image = _normalizeImageUrl(first.toString());
      }
    }

    return Message(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      text: text,
      time: _formatTimeFromIso(map['createdAt']?.toString()),
      isSentByMe: sender.isNotEmpty && sender == LocalStorage.userId,
      imageUrl: image,
    );
  }

  String _extractSenderId(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      return map['_id']?.toString() ?? '';
    }
    return value.toString();
  }

  void _onSocketMessage(dynamic data) {
    try {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      final msg = _parseMessageFromMap(map);
      if (msg.id.trim().isEmpty) return;

      final exists = messages.any((m) => m.id == msg.id);
      if (exists) return;

      messages.insert(0, msg);
    } catch (_) {}
  }

  String _normalizeImageUrl(String value) {
    final v = value.trim();
    if (v.isEmpty) return '';
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    return ApiEndPoint.imageUrl + v;
  }

  String _formatTimeFromIso(String? iso) {
    if (iso == null || iso.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return _formatTime(dt);
    } catch (_) {
      return '';
    }
  }

  Future<void> fetchMessages({
    required bool refresh,
  }) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;
    if (isLoading.value && refresh == false) return;
    if (isLoadingMore.value && refresh == false) return;

    if (refresh) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final url = "${ApiEndPoint.message}/$conversationId?page=$_page&limit=$_limit";
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

      final myId = LocalStorage.userId;

      final parsed = items
          .whereType<Map>()
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            final sender = map['sender']?.toString() ?? '';
            final text = map['text']?.toString() ?? '';

            String? image;
            final rawImage = map['image'];
            if (rawImage is String && rawImage.trim().isNotEmpty) {
              image = _normalizeImageUrl(rawImage);
            } else if (rawImage is List && rawImage.isNotEmpty) {
              final first = rawImage.first;
              if (first != null && first.toString().trim().isNotEmpty) {
                image = _normalizeImageUrl(first.toString());
              }
            }

            return Message(
              id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
              text: text,
              time: _formatTimeFromIso(map['createdAt']?.toString()),
              isSentByMe: sender.isNotEmpty && sender == myId,
              imageUrl: image,
            );
          })
          .toList(growable: false);

      // API returns newest first typically; our ListView uses reverse:true.
      if (refresh) {
        messages.assignAll(parsed);
      } else {
        messages.addAll(parsed);
      }

      _hasMore = parsed.length == _limit;
      if (_hasMore) _page += 1;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreIfNeeded(int index) async {
    if (index >= messages.length - 2) {
      await fetchMessages(refresh: false);
    }
  }

  Future<void> sendMessage() async {
    if (isSending.value) return;
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messageController.clear();
    await _sendToApi(text: text);
  }

  Future<void> _sendToApi({
    String? text,
    List<String>? images,
  }) async {
    if (isSending.value) return;
    final t = (text ?? '').trim();
    final files = (images ?? <String>[]).where((e) => e.trim().isNotEmpty).toList();
    if (t.isEmpty && files.isEmpty) return;

    isSending.value = true;
    try {
      final body = <String, dynamic>{
        'receiver': receiverId,
        'conversation': conversationId,
      };
      if (t.isNotEmpty) {
        body['text'] = t;
      }

      final response = await ApiService2.multipart(
        ApiEndPoint.message,
        isPost: true,
        body: body,
        images: files.isEmpty ? null : files,
      );

      if (response == null || (response.statusCode != 200 && response.statusCode != 201)) {
        return;
      }
      // Some servers don't echo the socket event back to the sender.
      // If response contains the created message, insert it locally (deduped by id).
      try {
        final data = response.data;
        final msgMap = (data is Map && data['data'] is Map)
            ? Map<String, dynamic>.from(data['data'] as Map)
            : null;
        if (msgMap != null) {
          final msg = _parseMessageFromMap(msgMap);
          if (msg.id.trim().isNotEmpty) {
            final exists = messages.any((m) => m.id == msg.id);
            if (!exists) {
              messages.insert(0, msg);
            }
          }
        }
      } catch (_) {}
    } finally {
      isSending.value = false;
    }
  }

  Future<void> pickAndSendImage() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) return;
      await _sendToApi(images: picked.map((e) => e.path).toList(growable: false));
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> pickAndSendImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        await _sendToApi(images: [image.path]);
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void showImageOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.white),
              title: Text('Choose from gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                pickAndSendImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.white),
              title: Text('Take a photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                pickAndSendImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onClose() {
    SocketServices.off(_socketEvent);
    messageController.dispose();
    super.onClose();
  }
}