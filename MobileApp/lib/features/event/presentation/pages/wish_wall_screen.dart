import 'package:flutter/material.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/api_config.dart';
import '../../../../core/services/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_detail_scaffold.dart';
import '../../data/repositories/wish_repository.dart';

class WishWallScreen extends StatefulWidget {
  final String eventId;
  final bool isMember;
  const WishWallScreen({super.key, required this.eventId, this.isMember = false});

  @override
  State<WishWallScreen> createState() => _WishWallScreenState();
}

class _WishWallScreenState extends State<WishWallScreen> {
  final _wishRepo = WishRepository();
  List<Map<String, dynamic>> _wishes = [];
  final TextEditingController _textController = TextEditingController();
  bool _hasWished = false;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadWishes();
  }

  Future<void> _loadWishes() async {
    try {
      final wishes = await _wishRepo.list(widget.eventId);
      // Check if current user already sent a wish
      final userId = await TokenStorage().getUserId();
      bool alreadyWished = false;
      if (userId != null) {
        alreadyWished = wishes.any((w) {
          final u = w['user'] as Map<String, dynamic>?;
          return u?['id'] == userId || w['userId'] == userId;
        });
      }
      if (mounted) setState(() { _wishes = wishes; _hasWished = alreadyWished; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendWish() async {
    if (_textController.text.trim().isEmpty || _hasWished || _sending) return;
    setState(() => _sending = true);
    try {
      await _wishRepo.create(widget.eventId, _textController.text.trim());
      _textController.clear();
      setState(() { _hasWished = true; _sending = false; });
      _loadWishes();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        if (e.statusCode == 409) {
          setState(() => _hasWished = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send wish: $e')),
        );
      }
    }
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return AppDetailScaffold(
      title: 'Guest Wishes Wall',
      child: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _wishes.isEmpty
                    ? _buildEmptyState()
                    : _buildWishList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/empty_wishwall.png',
                height: 200,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No one has written a well-wishes yet",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              "watch this space for offer, update, and more",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _wishes.length,
      itemBuilder: (context, index) {
        final item = _wishes[index];
        final user = item['user'] as Map<String, dynamic>? ?? {};
        final name = user['fullName'] ?? 'Guest';
        final rawAvatar = user['avatarUrl'] ?? '';
        final avatar = rawAvatar.isNotEmpty && !rawAvatar.startsWith('http')
            ? '${ApiConfig.uploadsUrl}/$rawAvatar'
            : rawAvatar;
        final message = item['message'] ?? '';
        final time = _timeAgo(item['createdAt']);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\u201c$message\u201d',
                style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                    child: avatar.isEmpty ? const Icon(Icons.person, size: 14, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 10),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const Spacer(),
                  Text(time, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    if (!widget.isMember) return const SizedBox.shrink();
    if (_hasWished) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          'You have already sent your wish',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _textController,
                  enabled: !_sending,
                  decoration: const InputDecoration(
                    hintText: "Aa",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.inputHint),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _sending
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : IconButton(
                    icon: const Icon(Icons.chat_bubble_rounded, color: Colors.indigo),
                    onPressed: _sendWish,
                  ),
          ],
        ),
      ),
    );
  }
}
