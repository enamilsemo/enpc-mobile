// ─────────────────────────────────────────────────────────────────────────────
// ENPC Mobile — Models
// Matches exactly the existing FastAPI backend response shapes
// ─────────────────────────────────────────────────────────────────────────────

// ── User ─────────────────────────────────────────────────────────────────────

class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role; // SUPER_ADMIN | ADMIN | STUDENT
  final bool isActive;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'],
        username: j['username'],
        email: j['email'],
        fullName: j['full_name'],
        role: j['role'],
        isActive: j['is_active'] ?? true,
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
      );

  bool get isAdmin => role == 'ADMIN' || role == 'SUPER_ADMIN';
  bool get isSuperAdmin => role == 'SUPER_ADMIN';

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String get roleLabel => role.replaceAll('_', ' ');
}

// ── Attachment ────────────────────────────────────────────────────────────────

class Attachment {
  final int id;
  final String filename;
  final String storedName;
  final String fileType; // image | pdf | doc | sheet | ppt | other
  final int fileSize;
  final int announcementId;
  final DateTime uploadedAt;

  const Attachment({
    required this.id,
    required this.filename,
    required this.storedName,
    required this.fileType,
    required this.fileSize,
    required this.announcementId,
    required this.uploadedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> j) => Attachment(
        id: j['id'],
        filename: j['filename'],
        storedName: j['stored_name'],
        fileType: j['file_type'],
        fileSize: j['file_size'] ?? 0,
        announcementId: j['announcement_id'],
        uploadedAt: DateTime.tryParse(j['uploaded_at'] ?? '') ?? DateTime.now(),
      );

  bool get isImage => fileType == 'image';

  String get sizeLabel {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String fileUrl(String base) => '$base/uploads/$storedName';
}

// ── Announcement ──────────────────────────────────────────────────────────────

class Announcement {
  final int id;
  final String title;
  final String content;
  final String category;
  final bool isPinned;
  final int authorId;
  final User author;
  final List<Attachment> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.isPinned,
    required this.authorId,
    required this.author,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> j) => Announcement(
        id: j['id'],
        title: j['title'],
        content: j['content'],
        category: j['category'] ?? 'General',
        isPinned: j['is_pinned'] ?? false,
        authorId: j['author_id'],
        author: User.fromJson(j['author']),
        attachments: (j['attachments'] as List<dynamic>? ?? [])
            .map((a) => Attachment.fromJson(a))
            .toList(),
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(j['updated_at'] ?? '') ?? DateTime.now(),
      );
}

// ── Comment ───────────────────────────────────────────────────────────────────

class Comment {
  final int id;
  final String content;
  final bool isHidden;
  final int authorId;
  final int announcementId;
  final User author;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.content,
    required this.isHidden,
    required this.authorId,
    required this.announcementId,
    required this.author,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> j) => Comment(
        id: j['id'],
        content: j['content'],
        isHidden: j['is_hidden'] ?? false,
        authorId: j['author_id'],
        announcementId: j['announcement_id'],
        author: User.fromJson(j['author']),
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
      );
}

// ── Message ───────────────────────────────────────────────────────────────────

class Message {
  final int id;
  final String content;
  final int senderId;
  final int receiverId;
  final bool isRead;
  final User sender;
  final User receiver;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.isRead,
    required this.sender,
    required this.receiver,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> j) => Message(
        id: j['id'],
        content: j['content'],
        senderId: j['sender_id'],
        receiverId: j['receiver_id'],
        isRead: j['is_read'] ?? false,
        sender: User.fromJson(j['sender']),
        receiver: User.fromJson(j['receiver']),
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
      );
}

// ── Inbox Item ────────────────────────────────────────────────────────────────

class InboxItem {
  final User user;
  final String lastContent;
  final DateTime lastTime;
  final bool unread;

  const InboxItem({
    required this.user,
    required this.lastContent,
    required this.lastTime,
    required this.unread,
  });

  factory InboxItem.fromJson(Map<String, dynamic> j) => InboxItem(
        user: User.fromJson(j['user']),
        lastContent: j['last_message']?['content'] ?? '',
        lastTime: DateTime.tryParse(j['last_message']?['created_at'] ?? '') ?? DateTime.now(),
        unread: j['unread'] ?? false,
      );
}

// ── Notification ──────────────────────────────────────────────────────────────

class AppNotification {
  final int id;
  final String title;
  final String body;
  final String type; // announcement | message
  final bool isRead;
  final int? refId;
  final int userId;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.refId,
    required this.userId,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'],
        title: j['title'],
        body: j['body'],
        type: j['type'],
        isRead: j['is_read'] ?? false,
        refId: j['ref_id'],
        userId: j['user_id'],
        createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
      );
}

// ── Auth Result ───────────────────────────────────────────────────────────────

class AuthResult {
  final String token;
  final User user;

  const AuthResult({required this.token, required this.user});

  factory AuthResult.fromJson(Map<String, dynamic> j) => AuthResult(
        token: j['access_token'],
        user: User.fromJson(j['user']),
      );
}
