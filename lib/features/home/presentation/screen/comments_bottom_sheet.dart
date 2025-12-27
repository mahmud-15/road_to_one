import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_project_flutter/config/api/api_end_point.dart';
import 'package:road_project_flutter/services/api/api_service.dart';
import 'package:road_project_flutter/utils/constants/app_colors.dart';
import 'package:road_project_flutter/utils/constants/app_string.dart';
import 'dart:io';

import '../models/comment_model.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String postId;

  const CommentsBottomSheet({super.key, required this.postId});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final _scrollController = ScrollController();
  final _commentController = TextEditingController();
  final _picker = ImagePicker();

  final _comments = <CommentModel>[];
  final Map<String, List<ReplyModel>> _repliesByCommentId = {};
  final Map<String, int> _replyPageByCommentId = {};
  final Map<String, bool> _replyHasMoreByCommentId = {};
  final Map<String, bool> _replyIsLoadingByCommentId = {};
  final Set<String> _expandedReplyForCommentIds = <String>{};
  final Map<String, bool> _commentLikeLoadingById = {};
  CommentModel? _replyTo;
  File? _selectedImage;
  bool _isSending = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _timeAgo(String? iso) {
    if (iso == null || iso.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      var diff = now.difference(dt);
      if (diff.isNegative) diff = Duration.zero;

      final days = diff.inDays;
      if (days >= 365) return '${days ~/ 365}y ago';
      if (days >= 30) return '${days ~/ 30}mo ago';
      if (days >= 7) return '${days ~/ 7}w ago';
      if (days >= 1) return '${days}d ago';

      final hours = diff.inHours;
      if (hours >= 1) return '${hours}h ago';

      final minutes = diff.inMinutes;
      if (minutes >= 1) return '${minutes}m ago';

      final seconds = diff.inSeconds;
      if (seconds >= 5) return '${seconds}s ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (!mounted) return;
      if (image == null) return;
      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (_) {
      if (!mounted) return;
      _showSnack('Failed to pick image');
    }
  }

  Future<void> _toggleCommentLike(CommentModel comment) async {
    if (_commentLikeLoadingById[comment.id] == true) return;

    final previous = comment.isLiked;
    setState(() {
      _commentLikeLoadingById[comment.id] = true;
      comment.isLiked = !previous;
    });

    try {
      final url = "${ApiEndPoint.commentLikeToggle}/${comment.id}";
      final response = await ApiService2.post(url, body: {});
      if (!mounted) return;

      if (response == null) {
        setState(() => comment.isLiked = previous);
        _showSnack(AppString.someThingWrong);
        return;
      }

      final data = response.data;
      if (response.statusCode != 200) {
        setState(() => comment.isLiked = previous);
        _showSnack((data is Map && data['message'] != null)
            ? data['message'].toString()
            : AppString.someThingWrong);
        return;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => comment.isLiked = previous);
      _showSnack(AppString.someThingWrong);
    } finally {
      if (mounted) {
        setState(() => _commentLikeLoadingById[comment.id] = false);
      }
    }
  }

  void _clearReplyAndInput() {
    setState(() {
      _replyTo = null;
      _selectedImage = null;
    });
    _commentController.clear();
  }

  void _clearInputOnly() {
    setState(() {
      _selectedImage = null;
    });
    _commentController.clear();
  }

  Future<void> _sendComment() async {
    if (_isSending) return;

    final text = _commentController.text.trim();
    if (text.isEmpty && _selectedImage == null) {
      _showSnack('Write something or attach an image');
      return;
    }

    setState(() => _isSending = true);
    try {
      final url = ApiEndPoint.allComment;
      final body = <String, dynamic>{'post': widget.postId};
      if (text.isNotEmpty) {
        body['text'] = text;
      }

      final response = await ApiService2.multipart(
        url,
        isPost: true,
        body: body,
        image: _selectedImage?.path,
      );

      if (!mounted) return;

      if (response == null) {
        _showSnack(AppString.someThingWrong);
        return;
      }

      final data = response.data;
      if (response.statusCode != 200 && response.statusCode != 201) {
        _showSnack((data is Map && data['message'] != null)
            ? data['message'].toString()
            : AppString.someThingWrong);
        return;
      }

      _clearInputOnly();
      await _fetchInitial();
    } catch (_) {
      if (!mounted) return;
      _showSnack(AppString.someThingWrong);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _send() async {
    if (_replyTo == null) {
      return _sendComment();
    }
    return _sendReply();
  }

  Future<void> _fetchRepliesInitial(String commentId) async {
    if (_replyIsLoadingByCommentId[commentId] == true) return;
    setState(() {
      _replyIsLoadingByCommentId[commentId] = true;
      _replyPageByCommentId[commentId] = 1;
      _replyHasMoreByCommentId[commentId] = true;
      _repliesByCommentId[commentId] = <ReplyModel>[];
    });

    try {
      final url = "${ApiEndPoint.commentReply}/$commentId?page=1&limit=$_limit";
      final response = await ApiService2.get(url);
      if (!mounted) return;

      if (response == null) {
        _showSnack(AppString.someThingWrong);
        setState(() => _replyHasMoreByCommentId[commentId] = false);
        return;
      }

      final data = response.data;
      if (response.statusCode != 200) {
        _showSnack((data is Map && data['message'] != null)
            ? data['message'].toString()
            : AppString.someThingWrong);
        setState(() => _replyHasMoreByCommentId[commentId] = false);
        return;
      }

      final items = (data is Map &&
              data['data'] is Map &&
              (data['data'] as Map)['data'] is List)
          ? ((data['data'] as Map)['data'] as List)
          : <dynamic>[];

      final parsed = items
          .whereType<Map>()
          .map((e) => ReplyModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);

      setState(() {
        _repliesByCommentId[commentId] = parsed;
        _replyHasMoreByCommentId[commentId] = parsed.length == _limit;
      });
    } catch (_) {
      if (!mounted) return;
      _showSnack(AppString.someThingWrong);
      setState(() => _replyHasMoreByCommentId[commentId] = false);
    } finally {
      if (mounted) {
        setState(() => _replyIsLoadingByCommentId[commentId] = false);
      }
    }
  }

  Future<void> _fetchRepliesMore(String commentId) async {
    if (_replyIsLoadingByCommentId[commentId] == true) return;
    if (_replyHasMoreByCommentId[commentId] == false) return;

    final currentPage = _replyPageByCommentId[commentId] ?? 1;
    final nextPage = currentPage + 1;
    setState(() => _replyIsLoadingByCommentId[commentId] = true);

    try {
      final url = "${ApiEndPoint.commentReply}/$commentId?page=$nextPage&limit=$_limit";
      final response = await ApiService2.get(url);
      if (!mounted) return;

      if (response == null || response.statusCode != 200) {
        setState(() => _replyHasMoreByCommentId[commentId] = false);
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
          .map((e) => ReplyModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);

      final current = _repliesByCommentId[commentId] ?? <ReplyModel>[];
      setState(() {
        _replyPageByCommentId[commentId] = nextPage;
        _repliesByCommentId[commentId] = [...current, ...parsed];
        _replyHasMoreByCommentId[commentId] = parsed.length == _limit;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _replyHasMoreByCommentId[commentId] = false);
    } finally {
      if (mounted) {
        setState(() => _replyIsLoadingByCommentId[commentId] = false);
      }
    }
  }

  Future<void> _toggleReplies(String commentId) async {
    final isExpanded = _expandedReplyForCommentIds.contains(commentId);
    if (isExpanded) {
      setState(() => _expandedReplyForCommentIds.remove(commentId));
      return;
    }

    setState(() => _expandedReplyForCommentIds.add(commentId));

    final hasLoaded = _repliesByCommentId.containsKey(commentId);
    if (!hasLoaded) {
      await _fetchRepliesInitial(commentId);
    }
  }

  Future<void> _sendReply() async {
    if (_isSending) return;
    if (_replyTo == null) {
      _showSnack('Select a comment to reply');
      return;
    }

    final text = _commentController.text.trim();
    if (text.isEmpty && _selectedImage == null) {
      _showSnack('Write something or attach an image');
      return;
    }

    setState(() => _isSending = true);
    try {
      final url = "${ApiEndPoint.commentReply}/${_replyTo!.id}";
      final body = <String, dynamic>{};
      if (text.isNotEmpty) {
        body['text'] = text;
      }

      final response = await ApiService2.multipart(
        url,
        isPost: true,
        body: body.isEmpty ? null : body,
        image: _selectedImage?.path,
      );

      if (!mounted) return;

      if (response == null) {
        _showSnack(AppString.someThingWrong);
        return;
      }

      final data = response.data;
      if (response.statusCode != 200) {
        _showSnack((data is Map && data['message'] != null)
            ? data['message'].toString()
            : AppString.someThingWrong);
        return;
      }

      final repliedToCommentId = _replyTo!.id;
      _clearReplyAndInput();
      if (_expandedReplyForCommentIds.contains(repliedToCommentId)) {
        await _fetchRepliesInitial(repliedToCommentId);
      }
      await _fetchInitial();
    } catch (_) {
      if (!mounted) return;
      _showSnack(AppString.someThingWrong);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    final position = _scrollController.position;
    if (!position.hasPixels || !position.hasContentDimensions) return;

    if (position.pixels >= position.maxScrollExtent - 200) {
      _fetchMore();
    }
  }

  Future<void> _fetchInitial() async {
    setState(() {
      _isLoading = true;
      _page = 1;
      _hasMore = true;
      _comments.clear();
    });

    try {
      final url = "${ApiEndPoint.allComment}/${widget.postId}?page=$_page&limit=$_limit";
      final response = await ApiService2.get(url);
      if (!mounted) return;

      if (response == null) {
        _showSnack(AppString.someThingWrong);
        setState(() => _hasMore = false);
        return;
      }

      final data = response.data;
      if (response.statusCode != 200) {
        _showSnack((data is Map && data['message'] != null)
            ? data['message'].toString()
            : AppString.someThingWrong);
        setState(() => _hasMore = false);
        return;
      }

      final items = (data is Map && data['data'] is List) ? (data['data'] as List) : <dynamic>[];
      final parsed = items
          .whereType<Map>()
          .map((e) => CommentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);

      setState(() {
        _comments.addAll(parsed);
        _hasMore = parsed.length == _limit;
      });
    } catch (_) {
      if (!mounted) return;
      _showSnack(AppString.someThingWrong);
      setState(() => _hasMore = false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchMore() async {
    if (!_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _page + 1;
      final url = "${ApiEndPoint.allComment}/${widget.postId}?page=$nextPage&limit=$_limit";
      final response = await ApiService2.get(url);
      if (!mounted) return;

      if (response == null || response.statusCode != 200) {
        setState(() => _hasMore = false);
        return;
      }

      final data = response.data;
      final items = (data is Map && data['data'] is List) ? (data['data'] as List) : <dynamic>[];
      final parsed = items
          .whereType<Map>()
          .map((e) => CommentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);

      setState(() {
        _page = nextPage;
        _comments.addAll(parsed);
        _hasMore = parsed.length == _limit;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasMore = false);
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 46.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(99.r),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Comments',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Divider(height: 1, color: Colors.white.withOpacity(0.06)),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      itemCount: _comments.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _comments.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          );
                        }

                        final c = _comments[index];
                        final isLiking = _commentLikeLoadingById[c.id] == true;
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipOval(
                                child: Image.network(
                                  ApiEndPoint.imageUrl + c.creator.image,
                                  height: 40.r,
                                  width: 40.r,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.network(AppString.defaultProfilePic, height: 40.r, width: 40.r, fit: BoxFit.cover),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            c.creator.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.sp,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          _timeAgo(c.createAt),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.35),
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      c.text,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                    if (c.image.trim().isNotEmpty) ...[
                                      SizedBox(height: 8.h),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12.r),
                                        child: Image.network(
                                          ApiEndPoint.imageUrl + c.image,
                                          height: 160.h,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const SizedBox.shrink(),
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: 6.h),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _replyTo = c;
                                            });
                                          },
                                          child: Text(
                                            'Reply',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.35),
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 14.w),
                                        GestureDetector(
                                          onTap: () => _toggleReplies(c.id),
                                          child: Text(
                                            _expandedReplyForCommentIds.contains(c.id)
                                                ? 'Hide replies'
                                                : 'View replies',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.35),
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_expandedReplyForCommentIds.contains(c.id)) ...[
                                      SizedBox(height: 8.h),
                                      _buildRepliesSection(c.id),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(width: 10.w),
                              GestureDetector(
                                onTap: isLiking ? null : () => _toggleCommentLike(c),
                                child: SizedBox(
                                  height: 24.r,
                                  width: 24.r,
                                  child: Icon(
                                    c.isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: c.isLiked
                                        ? Colors.red
                                        : Colors.white.withOpacity(isLiking ? 0.18 : 0.35),
                                    size: 18.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Divider(height: 1, color: Colors.white.withOpacity(0.06)),
            Padding(
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                top: 10.h,
                bottom: 10.h + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_replyTo != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1C),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Replying to ${_replyTo!.creator.name}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: _clearReplyAndInput,
                            child: Icon(
                              Icons.close,
                              color: Colors.white.withOpacity(0.6),
                              size: 18.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_selectedImage != null) ...[
                    SizedBox(height: 10.h),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(
                            _selectedImage!,
                            height: 120.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 40.r,
                          width: 40.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1C),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.white.withOpacity(0.06)),
                          ),
                          child: Icon(
                            Icons.photo,
                            color: Colors.white.withOpacity(0.7),
                            size: 18.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1C),
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(color: Colors.white.withOpacity(0.06)),
                          ),
                          child: TextField(
                            controller: _commentController,
                            style: TextStyle(color: Colors.white, fontSize: 13.sp),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: _replyTo == null
                                  ? 'Write a comment...'
                                  : 'Write a reply... ',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.35),
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      GestureDetector(
                        onTap: _isSending ? null : _send,
                        child: Container(
                          height: 40.r,
                          width: 40.r,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: _isSending
                              ? Center(
                                  child: SizedBox(
                                    height: 16.r,
                                    width: 16.r,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              : Icon(Icons.send, color: Colors.black, size: 18.sp),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepliesSection(String commentId) {
    final isLoading = _replyIsLoadingByCommentId[commentId] == true;
    final replies = _repliesByCommentId[commentId] ?? <ReplyModel>[];
    final hasMore = _replyHasMoreByCommentId[commentId] == true;

    if (isLoading && replies.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!isLoading && replies.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(left: 4.w, top: 4.h),
        child: Text(
          'No replies yet',
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 12.sp,
          ),
        ),
      );
    }

    return Column(
      children: [
        ...replies.map(
          (r) => Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 18.w),
                ClipOval(
                  child: Image.network(
                    ApiEndPoint.imageUrl + r.creator.image,
                    height: 28.r,
                    width: 28.r,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.network(
                      AppString.defaultProfilePic,
                      height: 28.r,
                      width: 28.r,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              r.creator.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _timeAgo(r.createdAt),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        r.text,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12.sp,
                        ),
                      ),
                      if (r.image.trim().isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            ApiEndPoint.imageUrl + r.image,
                            height: 140.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasMore)
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: isLoading ? null : () => _fetchRepliesMore(commentId),
                child: Padding(
                  padding: EdgeInsets.only(left: 18.w),
                  child: Text(
                    isLoading ? 'Loading...' : 'Load more replies',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
