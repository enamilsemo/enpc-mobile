// ─────────────────────────────────────────────────────────────────────────────
// ENPC Mobile — All Screens
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../services/api.dart';
import '../widgets/widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// AUTH SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final api = context.read<ApiService>();
    try {
      if (_isLogin) {
        await api.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
      } else {
        await api.register(
          _usernameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          _fullNameCtrl.text.trim(),
        );
      }
    } on ApiException catch (e) {
      setState(() { _error = e.message; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnpcTheme.paper,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: EnpcTheme.ink,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ENPC',
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 36, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Official Communication System',
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.white54,
                            letterSpacing: 0.3)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: EnpcTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isLogin ? 'Welcome back' : 'Create account',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 22, color: EnpcTheme.ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLogin
                          ? 'Sign in to your ENPC account'
                          : 'Register with your student information',
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: EnpcTheme.ink3),
                    ),
                    const SizedBox(height: 24),

                    if (!_isLogin) ...[
                      _field(_fullNameCtrl, 'Full Name', Icons.person_outline),
                      const SizedBox(height: 14),
                      _field(_emailCtrl, 'Email', Icons.email_outlined,
                          type: TextInputType.emailAddress),
                      const SizedBox(height: 14),
                    ],

                    _field(_usernameCtrl, 'Username', Icons.badge_outlined),
                    const SizedBox(height: 14),
                    _field(_passwordCtrl, 'Password', Icons.lock_outline,
                        obscure: true),

                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Text(_error!,
                            style: GoogleFonts.dmSans(
                                fontSize: 13, color: EnpcTheme.accent)),
                      ),
                    ],

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(_isLogin ? 'Sign In' : 'Create Account'),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin
                              ? "Don't have an account? "
                              : 'Already have an account? ',
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: EnpcTheme.ink3),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() { _isLogin = !_isLogin; _error = null; }),
                          child: Text(
                            _isLogin ? 'Register' : 'Sign In',
                            style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: EnpcTheme.accent,
                                decoration: TextDecoration.underline),
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
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? type, bool obscure = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure ? _obscure : false,
      onSubmitted: (_) => _submit(),
      style: GoogleFonts.dmSans(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(fontSize: 13, color: EnpcTheme.ink3),
        prefixIcon: Icon(icon, size: 18, color: EnpcTheme.ink3),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: EnpcTheme.ink3),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOME SHELL — Bottom nav wrapper
// ═══════════════════════════════════════════════════════════════════════════════

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _pollUnread();
  }

  Future<void> _pollUnread() async {
    while (mounted) {
      try {
        final count = await context.read<ApiService>().getUnreadCount();
        if (mounted) setState(() => _unread = count);
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiService>();
    final user = api.currentUser!;

    final tabs = [
      const FeedScreen(),
      const MessagesScreen(),
      const NotificationsScreen(),
      if (user.isAdmin) const AdminScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.feed_outlined),
              activeIcon: Icon(Icons.feed),
              label: 'Feed'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.mail_outline),
              activeIcon: Icon(Icons.mail),
              label: 'Messages'),
          BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: _unread > 0,
                label: Text('$_unread'),
                child: const Icon(Icons.notifications_outlined)),
              activeIcon: Badge(
                isLabelVisible: _unread > 0,
                label: Text('$_unread'),
                child: const Icon(Icons.notifications)),
              label: 'Notifications'),
          if (user.isAdmin)
            const BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings_outlined),
                activeIcon: Icon(Icons.admin_panel_settings),
                label: 'Admin'),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FEED SCREEN — Main announcement list
// ═══════════════════════════════════════════════════════════════════════════════

const _categories = ['All', 'General', 'Academic', 'Events', 'Urgent', 'Administrative'];

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Announcement> _announcements = [];
  bool _loading = true;
  String? _error;
  String _selectedCat = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await context.read<ApiService>().getAnnouncements(
          category: _selectedCat == 'All' ? null : _selectedCat);
      setState(() => _announcements = data);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('ENPC Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () => api.logout(),
          ),
        ],
      ),
      floatingActionButton: api.isAdmin
          ? FloatingActionButton(
              backgroundColor: EnpcTheme.accent,
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const CreateAnnouncementScreen()));
                _load();
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: RefreshIndicator(
        color: EnpcTheme.ink,
        onRefresh: _load,
        child: Column(
          children: [
            // Category filter row
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final active = cat == _selectedCat;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCat = cat);
                      _load();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: active ? EnpcTheme.ink : Colors.white,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                            color: active ? EnpcTheme.ink : EnpcTheme.border),
                      ),
                      child: Text(cat,
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: active ? Colors.white : EnpcTheme.ink3)),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const EnpcLoader()
                  : _error != null
                      ? ErrorBanner(message: _error!, onRetry: _load)
                      : _announcements.isEmpty
                          ? const EmptyState(
                              emoji: '📢',
                              title: 'No announcements yet',
                              subtitle: 'Check back later for updates')
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _announcements.length,
                              itemBuilder: (_, i) => _AnnouncementCard(
                                ann: _announcements[i],
                                onRefresh: _load,
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Announcement Card ─────────────────────────────────────────────────────────

class _AnnouncementCard extends StatelessWidget {
  final Announcement ann;
  final VoidCallback onRefresh;

  const _AnnouncementCard({required this.ann, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiService>();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AnnouncementDetailScreen(id: ann.id))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pinned banner
            if (ann.isPinned)
              Container(
                width: double.infinity,
                color: const Color(0xFFFEF9C3),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                child: Row(children: [
                  const Icon(Icons.push_pin, size: 12, color: Color(0xFF92400E)),
                  const SizedBox(width: 5),
                  Text('Pinned',
                      style: GoogleFonts.dmSans(
                          fontSize: 11, color: const Color(0xFF92400E),
                          fontWeight: FontWeight.w600)),
                ]),
              ),

            // First image preview if any
            if (ann.attachments.any((a) => a.isImage))
              ClipRRect(
                child: CachedNetworkImage(
                  imageUrl: ann.attachments
                      .firstWhere((a) => a.isImage)
                      .fileUrl(ApiService.baseUrl),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                      height: 160, color: EnpcTheme.paper2,
                      child: const EnpcLoader()),
                  errorWidget: (_, __, ___) => Container(
                      height: 160, color: EnpcTheme.paper2),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta row
                  Row(children: [
                    CategoryChip(category: ann.category),
                    const SizedBox(width: 8),
                    Text(fmtTimeAgo(ann.createdAt),
                        style: GoogleFonts.dmSans(
                            fontSize: 11, color: EnpcTheme.ink3)),
                  ]),
                  const SizedBox(height: 10),

                  // Title
                  Text(ann.title,
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 19, color: EnpcTheme.ink, height: 1.25),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),

                  // Excerpt
                  Text(
                    ann.content.length > 120
                        ? '${ann.content.substring(0, 120)}…'
                        : ann.content,
                    style: GoogleFonts.dmSans(
                        fontSize: 13, color: EnpcTheme.ink2, height: 1.55),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: EnpcTheme.paper2))),
              child: Row(children: [
                UserAvatar(user: ann.author, size: 26),
                const SizedBox(width: 8),
                Text(ann.author.fullName,
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: EnpcTheme.ink3)),
                const SizedBox(width: 6),
                RoleBadge(role: ann.author.role),
                if (ann.attachments.isNotEmpty) ...[
                  const Spacer(),
                  const Icon(Icons.attach_file, size: 13, color: EnpcTheme.ink3),
                  const SizedBox(width: 3),
                  Text('${ann.attachments.length}',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: EnpcTheme.ink3)),
                ] else
                  const Spacer(),
                if (api.isAdmin) ...[
                  const SizedBox(width: 8),
                  _adminMenu(context, api),
                ],
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminMenu(BuildContext context, ApiService api) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: EnpcTheme.ink3),
      onSelected: (v) async {
        if (v == 'edit') {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      CreateAnnouncementScreen(existing: ann)));
          onRefresh();
        } else if (v == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Delete Announcement'),
              content: const Text('This cannot be undone.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Delete',
                        style:
                            TextStyle(color: EnpcTheme.accent))),
              ],
            ),
          );
          if (confirm == true) {
            await api.deleteAnnouncement(ann.id);
            onRefresh();
          }
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(
            value: 'delete',
            child: Text('Delete', style: TextStyle(color: EnpcTheme.accent))),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ANNOUNCEMENT DETAIL SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class AnnouncementDetailScreen extends StatefulWidget {
  final int id;
  const AnnouncementDetailScreen({super.key, required this.id});
  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  Announcement? _ann;
  List<Comment> _comments = [];
  bool _loading = true;
  String? _error;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = _ann == null; _error = null; });
    try {
      final api = context.read<ApiService>();
      final results = await Future.wait([
        api.getAnnouncement(widget.id),
        api.getComments(widget.id),
      ]);
      setState(() {
        _ann = results[0] as Announcement;
        _comments = results[1] as List<Comment>;
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await context
          .read<ApiService>()
          .createComment(widget.id, _commentCtrl.text.trim());
      _commentCtrl.clear();
      await _load();
    } on ApiException catch (e) {
      showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement'),
        actions: [
          if (_ann != null && api.isAdmin)
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              CreateAnnouncementScreen(existing: _ann)));
                  _load();
                } else if (v == 'delete') {
                  await api.deleteAnnouncement(widget.id);
                  Navigator.pop(context);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(color: EnpcTheme.accent))),
              ],
            ),
        ],
      ),
      body: _loading
          ? const EnpcLoader()
          : _error != null
              ? ErrorBanner(message: _error!, onRetry: _load)
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        color: EnpcTheme.ink,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Category & meta
                            Row(children: [
                              CategoryChip(category: _ann!.category),
                              const SizedBox(width: 10),
                              Text(fmtDate(_ann!.createdAt),
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12, color: EnpcTheme.ink3)),
                              if (_ann!.isPinned) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.push_pin,
                                    size: 13, color: Color(0xFF92400E)),
                              ],
                            ]),
                            const SizedBox(height: 14),

                            // Title
                            Text(_ann!.title,
                                style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 26,
                                    color: EnpcTheme.ink,
                                    height: 1.2)),
                            const SizedBox(height: 12),

                            // Author
                            Row(children: [
                              UserAvatar(user: _ann!.author, size: 30),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_ann!.author.fullName,
                                      style: GoogleFonts.dmSans(
                                          fontSize: 13, fontWeight: FontWeight.w600)),
                                  RoleBadge(role: _ann!.author.role),
                                ],
                              ),
                            ]),

                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Content
                            Text(_ann!.content,
                                style: GoogleFonts.dmSans(
                                    fontSize: 15,
                                    color: EnpcTheme.ink2,
                                    height: 1.75)),

                            // Attachments
                            if (_ann!.attachments.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 12),
                              Text('Attachments',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.1,
                                      color: EnpcTheme.ink3)),
                              const SizedBox(height: 10),
                              _AttachmentsSection(
                                  attachments: _ann!.attachments,
                                  isAdmin: api.isAdmin,
                                  onDelete: (id) async {
                                    await api.deleteAttachment(id);
                                    _load();
                                  }),
                            ],

                            // Comments section
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 4),
                            Row(children: [
                              Text('Comments',
                                  style: GoogleFonts.dmSerifDisplay(
                                      fontSize: 18, color: EnpcTheme.ink)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: EnpcTheme.paper2,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text('${_comments.length}',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 12, color: EnpcTheme.ink3)),
                              ),
                            ]),
                            const SizedBox(height: 14),
                            if (_comments.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text('No comments yet. Be the first!',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 13, color: EnpcTheme.ink3)),
                              )
                            else
                              ..._comments
                                  .where((c) => !c.isHidden || api.isAdmin)
                                  .map((c) => _CommentTile(
                                        comment: c,
                                        isAdmin: api.isAdmin,
                                        onAction: _load,
                                      )),
                          ],
                        ),
                      ),
                    ),

                    // Comment input
                    Container(
                      padding: EdgeInsets.fromLTRB(
                          12, 10, 12, MediaQuery.of(context).viewInsets.bottom + 10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: EnpcTheme.border)),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: TextField(
                            controller: _commentCtrl,
                            style: GoogleFonts.dmSans(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Write a comment…',
                              hintStyle: GoogleFonts.dmSans(
                                  fontSize: 13, color: EnpcTheme.ink3),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filled(
                          onPressed: _submitting ? null : _submitComment,
                          style: IconButton.styleFrom(
                              backgroundColor: EnpcTheme.ink,
                              foregroundColor: Colors.white),
                          icon: _submitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.send, size: 18),
                        ),
                      ]),
                    ),
                  ],
                ),
    );
  }
}

// ── Comment Tile ──────────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final Comment comment;
  final bool isAdmin;
  final VoidCallback onAction;

  const _CommentTile(
      {required this.comment, required this.isAdmin, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiService>();
    return Opacity(
      opacity: comment.isHidden ? 0.45 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(user: comment.author, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(comment.author.fullName,
                        style: GoogleFonts.dmSans(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    RoleBadge(role: comment.author.role),
                    if (comment.isHidden) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(3)),
                        child: Text('Hidden',
                            style: GoogleFonts.dmSans(
                                fontSize: 10, color: EnpcTheme.accent)),
                      ),
                    ],
                    const Spacer(),
                    Text(fmtTimeAgo(comment.createdAt),
                        style: GoogleFonts.dmSans(
                            fontSize: 11, color: EnpcTheme.ink3)),
                  ]),
                  const SizedBox(height: 4),
                  Text(comment.content,
                      style: GoogleFonts.dmSans(
                          fontSize: 13.5, color: EnpcTheme.ink2, height: 1.5)),
                  if (isAdmin)
                    Row(children: [
                      TextButton(
                        onPressed: () async {
                          await api.moderateComment(comment.id,
                              hide: !comment.isHidden);
                          onAction();
                        },
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text(
                          comment.isHidden ? 'Unhide' : 'Hide',
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: EnpcTheme.ink3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () async {
                          await api.deleteComment(comment.id);
                          onAction();
                        },
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text('Delete',
                            style: GoogleFonts.dmSans(
                                fontSize: 12, color: EnpcTheme.accent)),
                      ),
                    ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Attachments Section ───────────────────────────────────────────────────────

class _AttachmentsSection extends StatefulWidget {
  final List<Attachment> attachments;
  final bool isAdmin;
  final Function(int) onDelete;

  const _AttachmentsSection(
      {required this.attachments, required this.isAdmin, required this.onDelete});

  @override
  State<_AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends State<_AttachmentsSection> {
  int? _lightboxIndex;

  @override
  Widget build(BuildContext context) {
    final images = widget.attachments.where((a) => a.isImage).toList();
    final others = widget.attachments.where((a) => !a.isImage).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: images.length,
            itemBuilder: (_, i) {
              final att = images[i];
              return GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) => Dialog(
                            backgroundColor: Colors.black,
                            child: InteractiveViewer(
                              child: CachedNetworkImage(
                                imageUrl: att.fileUrl(ApiService.baseUrl),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ));
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: CachedNetworkImage(
                        imageUrl: att.fileUrl(ApiService.baseUrl),
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: EnpcTheme.paper2),
                      ),
                    ),
                    if (widget.isAdmin)
                      Positioned(
                        top: 3,
                        right: 3,
                        child: GestureDetector(
                          onTap: () => widget.onDelete(att.id),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.close,
                                size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          if (others.isNotEmpty) const SizedBox(height: 10),
        ],
        ...others.map((att) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: EnpcTheme.paper,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: EnpcTheme.border),
              ),
              child: Row(children: [
                Text(fileIcon(att.fileType), style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(att.filename,
                          style: GoogleFonts.dmSans(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                      Text(att.sizeLabel,
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: EnpcTheme.ink3)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download_outlined,
                      size: 18, color: EnpcTheme.ink3),
                  onPressed: () {
                    launchUrl(Uri.parse(att.fileUrl(ApiService.baseUrl)),
                        mode: LaunchMode.externalApplication);
                  },
                ),
                if (widget.isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: EnpcTheme.accent),
                    onPressed: () => widget.onDelete(att.id),
                  ),
              ]),
            )),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CREATE / EDIT ANNOUNCEMENT SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class CreateAnnouncementScreen extends StatefulWidget {
  final Announcement? existing;
  const CreateAnnouncementScreen({super.key, this.existing});
  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  String _category = 'General';
  bool _isPinned = false;
  bool _saving = false;
  String? _error;
  final List<File> _files = [];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.existing?.content ?? '');
    _category = widget.existing?.category ?? 'General';
    _isPinned = widget.existing?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final picker = ImagePicker();
    final imgs = await picker.pickMultiImage();
    setState(() => _files.addAll(imgs.map((x) => File(x.path))));
  }

  Future<void> _pickDocs() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() => _files.addAll(
          result.files.where((f) => f.path != null).map((f) => File(f.path!))));
    }
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _contentCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Title and content are required.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    final api = context.read<ApiService>();
    try {
      if (widget.existing == null) {
        await api.createAnnouncement(
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          category: _category,
          isPinned: _isPinned,
          files: _files,
        );
      } else {
        await api.updateAnnouncement(
          widget.existing!.id,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
          category: _category,
          isPinned: _isPinned,
        );
        if (_files.isNotEmpty) {
          await api.uploadAttachments(widget.existing!.id, _files);
        }
      }
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New Announcement' : 'Edit Announcement'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Publish',
                    style: GoogleFonts.dmSans(
                        color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.dmSerifDisplay(fontSize: 20),
              decoration: InputDecoration(
                hintText: 'Announcement title…',
                hintStyle: GoogleFonts.dmSerifDisplay(
                    fontSize: 20, color: EnpcTheme.ink3),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _category,
                  style: GoogleFonts.dmSans(fontSize: 14, color: EnpcTheme.ink),
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['General', 'Academic', 'Events', 'Urgent', 'Administrative']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
              ),
              const SizedBox(width: 14),
              Column(children: [
                Text('Pin', style: GoogleFonts.dmSans(fontSize: 11, color: EnpcTheme.ink3)),
                Switch(
                  value: _isPinned,
                  onChanged: (v) => setState(() => _isPinned = v),
                  activeColor: EnpcTheme.gold,
                ),
              ]),
            ]),
            const SizedBox(height: 14),
            TextField(
              controller: _contentCtrl,
              minLines: 8,
              maxLines: null,
              style: GoogleFonts.dmSans(fontSize: 14, height: 1.6),
              decoration: InputDecoration(
                hintText: 'Write your announcement…',
                hintStyle: GoogleFonts.dmSans(color: EnpcTheme.ink3),
                alignLabelWithHint: true,
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              ErrorBanner(message: _error!),
            ],

            const SizedBox(height: 20),
            Text('Attachments',
                style: GoogleFonts.dmSans(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    letterSpacing: 0.1, color: EnpcTheme.ink3)),
            const SizedBox(height: 10),

            Row(children: [
              OutlinedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.image_outlined, size: 16),
                label: const Text('Images'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _pickDocs,
                icon: const Icon(Icons.attach_file, size: 16),
                label: const Text('Files'),
              ),
            ]),

            if (_files.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _files.asMap().entries.map((e) {
                  final f = e.value;
                  final isImg = f.path.endsWith('.jpg') ||
                      f.path.endsWith('.jpeg') ||
                      f.path.endsWith('.png') ||
                      f.path.endsWith('.webp');
                  return Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: EnpcTheme.border),
                          color: EnpcTheme.paper2,
                        ),
                        child: isImg
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.file(f, fit: BoxFit.cover))
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('📎', style: TextStyle(fontSize: 22)),
                                  Text(
                                    f.path.split('/').last,
                                    style: GoogleFonts.dmSans(fontSize: 9),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() => _files.removeAt(e.key)),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(9)),
                            child: const Icon(Icons.close,
                                size: 11, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MESSAGES SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<InboxItem> _inbox = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = _inbox.isEmpty; _error = null; });
    try {
      final data = await context.read<ApiService>().getInbox();
      setState(() => _inbox = data);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: EnpcTheme.ink,
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NewMessageScreen()));
          _load();
        },
        child: const Icon(Icons.edit, color: Colors.white, size: 20),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: EnpcTheme.ink,
        child: _loading
            ? const EnpcLoader()
            : _error != null
                ? ErrorBanner(message: _error!, onRetry: _load)
                : _inbox.isEmpty
                    ? const EmptyState(
                        emoji: '✉️',
                        title: 'No messages yet',
                        subtitle: 'Start a conversation with an admin or student')
                    : ListView.separated(
                        itemCount: _inbox.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 66),
                        itemBuilder: (_, i) {
                          final item = _inbox[i];
                          return ListTile(
                            leading: UserAvatar(user: item.user, size: 42),
                            title: Row(children: [
                              Text(item.user.fullName,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: item.unread
                                          ? FontWeight.w700
                                          : FontWeight.w500)),
                              const Spacer(),
                              Text(fmtTimeAgo(item.lastTime),
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11, color: EnpcTheme.ink3)),
                            ]),
                            subtitle: Row(children: [
                              Expanded(
                                child: Text(
                                  item.lastContent,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12.5,
                                      color: item.unread
                                          ? EnpcTheme.ink
                                          : EnpcTheme.ink3,
                                      fontWeight: item.unread
                                          ? FontWeight.w500
                                          : FontWeight.w400),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.unread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: EnpcTheme.accent,
                                      shape: BoxShape.circle),
                                ),
                            ]),
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ChatScreen(other: item.user)));
                              _load();
                            },
                          );
                        },
                      ),
      ),
    );
  }
}

// ── Chat Screen ───────────────────────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  final User other;
  const ChatScreen({super.key, required this.other});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _messages = [];
  bool _loading = true;
  final _msgCtrl = TextEditingController();
  bool _sending = false;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await context.read<ApiService>().getConversation(widget.other.id);
      setState(() { _messages = data; _loading = false; });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _send() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    final content = _msgCtrl.text.trim();
    _msgCtrl.clear();
    setState(() => _sending = true);
    try {
      await context.read<ApiService>().sendMessage(widget.other.id, content);
      await _load();
    } on ApiException catch (e) {
      showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.read<ApiService>().currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          UserAvatar(user: widget.other, size: 30),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.other.fullName,
                  style: GoogleFonts.dmSans(fontSize: 15, color: Colors.white)),
              Text(widget.other.roleLabel,
                  style: GoogleFonts.dmSans(fontSize: 10, color: Colors.white54)),
            ],
          ),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const EnpcLoader()
                : _messages.isEmpty
                    ? EmptyState(
                        emoji: '💬',
                        title: 'Start the conversation',
                        subtitle: 'Say hello to ${widget.other.fullName}!')
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg = _messages[i];
                          final isMine = msg.senderId == me.id;
                          return Align(
                            alignment: isMine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: isMine
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.72),
                                  decoration: BoxDecoration(
                                    color: isMine
                                        ? EnpcTheme.ink
                                        : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(14),
                                      topRight: const Radius.circular(14),
                                      bottomLeft: Radius.circular(isMine ? 14 : 3),
                                      bottomRight: Radius.circular(isMine ? 3 : 14),
                                    ),
                                    border: isMine
                                        ? null
                                        : Border.all(color: EnpcTheme.border),
                                  ),
                                  child: Text(msg.content,
                                      style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          color: isMine
                                              ? Colors.white
                                              : EnpcTheme.ink,
                                          height: 1.45)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(fmtTimeAgo(msg.createdAt),
                                      style: GoogleFonts.dmSans(
                                          fontSize: 10, color: EnpcTheme.ink3)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
                12, 10, 12, MediaQuery.of(context).viewInsets.bottom + 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: EnpcTheme.border)),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  style: GoogleFonts.dmSans(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Type a message…',
                    hintStyle: GoogleFonts.dmSans(color: EnpcTheme.ink3, fontSize: 13),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: _sending ? null : _send,
                style: IconButton.styleFrom(
                    backgroundColor: EnpcTheme.ink,
                    foregroundColor: Colors.white),
                icon: _sending
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send, size: 18),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── New Message Screen ────────────────────────────────────────────────────────

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});
  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  List<User> _users = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    context.read<ApiService>().getUsers().then((u) {
      final me = context.read<ApiService>().currentUser;
      setState(() {
        _users = u.where((user) => user.id != me?.id).toList();
        _loading = false;
      });
    }).catchError((_) => setState(() => _loading = false));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _users
        .where((u) => u.fullName.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('New Message')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users…',
                hintStyle: GoogleFonts.dmSans(color: EnpcTheme.ink3),
                prefixIcon: const Icon(Icons.search, size: 18, color: EnpcTheme.ink3),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: _loading
                ? const EnpcLoader()
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 66),
                    itemBuilder: (_, i) {
                      final u = filtered[i];
                      return ListTile(
                        leading: UserAvatar(user: u, size: 40),
                        title: Text(u.fullName,
                            style: GoogleFonts.dmSans(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: RoleBadge(role: u.role),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ChatScreen(other: u)));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = _notifs.isEmpty);
    try {
      final data = await context.read<ApiService>().getNotifications();
      setState(() => _notifs = data);
    } catch (_) {}
    finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiService>();
    final unread = _notifs.where((n) => !n.isRead).length;
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications${unread > 0 ? ' ($unread)' : ''}'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () async {
                await api.markAllNotificationsRead();
                _load();
              },
              child: Text('Mark all read',
                  style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 12)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: EnpcTheme.ink,
        child: _loading
            ? const EnpcLoader()
            : _notifs.isEmpty
                ? const EmptyState(
                    emoji: '🔔',
                    title: 'No notifications',
                    subtitle: 'You\'re all caught up!')
                : ListView.separated(
                    itemCount: _notifs.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 60),
                    itemBuilder: (_, i) {
                      final n = _notifs[i];
                      return InkWell(
                        onTap: () async {
                          if (!n.isRead) {
                            await api.markNotificationRead(n.id);
                            _load();
                          }
                        },
                        child: Container(
                          color: n.isRead ? null : const Color(0xFFFFF8F6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: n.type == 'announcement'
                                      ? const Color(0xFFFEF3C7)
                                      : const Color(0xFFDBEAFE),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    n.type == 'announcement' ? '📢' : '✉️',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.title,
                                        style: GoogleFonts.dmSans(
                                            fontSize: 13,
                                            fontWeight: n.isRead
                                                ? FontWeight.w400
                                                : FontWeight.w700)),
                                    const SizedBox(height: 3),
                                    Text(n.body,
                                        style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: EnpcTheme.ink3),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(fmtTimeAgo(n.createdAt),
                                        style: GoogleFonts.dmSans(
                                            fontSize: 11,
                                            color: EnpcTheme.ink3)),
                                  ],
                                ),
                              ),
                              if (!n.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: const BoxDecoration(
                                      color: EnpcTheme.accent,
                                      shape: BoxShape.circle),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ADMIN SCREEN — User management (Super Admin only)
// ═══════════════════════════════════════════════════════════════════════════════

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<User> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await context.read<ApiService>().getUsers();
      setState(() => _users = data);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _promote(User user) async {
    final api = context.read<ApiService>();
    String selected =
        user.role == 'STUDENT' ? 'ADMIN' : 'STUDENT';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Change Role: ${user.fullName}'),
        content: StatefulBuilder(
          builder: (ctx, setState2) => Column(
            mainAxisSize: MainAxisSize.min,
            children: ['STUDENT', 'ADMIN'].map((r) => RadioListTile<String>(
              value: r,
              groupValue: selected,
              title: Text(r, style: GoogleFonts.dmSans(fontSize: 14)),
              onChanged: (v) => setState2(() => selected = v!),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await api.promoteUser(user.id, selected);
              _load();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text('${_users.length} Users',
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: const Color(0xFF713F12),
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: EnpcTheme.ink,
        child: _loading
            ? const EnpcLoader()
            : _error != null
                ? ErrorBanner(message: _error!, onRetry: _load)
                : ListView.separated(
                    itemCount: _users.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 70),
                    itemBuilder: (_, i) {
                      final u = _users[i];
                      final isMe = u.id == api.currentUser?.id;
                      return ListTile(
                        leading: UserAvatar(user: u, size: 42),
                        title: Row(children: [
                          Expanded(
                            child: Text(u.fullName,
                                style: GoogleFonts.dmSans(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis),
                          ),
                          RoleBadge(role: u.role),
                        ]),
                        subtitle: Row(children: [
                          Text('@${u.username}',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12, color: EnpcTheme.ink3)),
                          const SizedBox(width: 8),
                          if (!u.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(3)),
                              child: Text('Inactive',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 10, color: EnpcTheme.accent)),
                            ),
                        ]),
                        trailing: (u.role != 'SUPER_ADMIN' && !isMe && api.isSuperAdmin)
                            ? PopupMenuButton<String>(
                                onSelected: (v) async {
                                  if (v == 'promote') await _promote(u);
                                  if (v == 'deactivate') {
                                    await api.deactivateUser(u.id);
                                    _load();
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                      value: 'promote',
                                      child: Text('Change Role')),
                                  if (u.isActive)
                                    const PopupMenuItem(
                                        value: 'deactivate',
                                        child: Text('Deactivate',
                                            style: TextStyle(
                                                color: EnpcTheme.accent))),
                                ],
                              )
                            : null,
                      );
                    },
                  ),
      ),
    );
  }
}
