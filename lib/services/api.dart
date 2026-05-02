// ─────────────────────────────────────────────────────────────────────────────
// ENPC Mobile — API Service
// Single source of truth for all backend communication
// Base URL: https://enpc-system.onrender.com
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiService extends ChangeNotifier {
  static const String baseUrl = 'https://enpc-system.onrender.com';
  static const String _tokenKey = 'enpc_jwt_token';
  static const String _userKey = 'enpc_user_json';

  final _storage = const FlutterSecureStorage();

  String? _token;
  User? _currentUser;

  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isSuperAdmin => _currentUser?.isSuperAdmin ?? false;

  // ── Bootstrap: load saved session ──────────────────────────────────────────

  Future<bool> tryAutoLogin() async {
    try {
      _token = await _storage.read(key: _tokenKey);
      final userJson = await _storage.read(key: _userKey);
      if (_token == null || userJson == null) return false;
      _currentUser = User.fromJson(jsonDecode(userJson));
      // Verify token is still valid
      await me();
      notifyListeners();
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  // ── Internal HTTP helpers ───────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> _get(String path) => _request('GET', path);
  Future<dynamic> _post(String path, [Map<String, dynamic>? body]) =>
      _request('POST', path, body);
  Future<dynamic> _put(String path, [Map<String, dynamic>? body]) =>
      _request('PUT', path, body);
  Future<dynamic> _delete(String path) => _request('DELETE', path);

  Future<dynamic> _request(String method, String path,
      [Map<String, dynamic>? body]) async {
    final uri = Uri.parse('$baseUrl$path');
    http.Response res;
    try {
      switch (method) {
        case 'GET':
          res = await http.get(uri, headers: _headers);
          break;
        case 'POST':
          res = await http.post(uri,
              headers: _headers,
              body: body != null ? jsonEncode(body) : null);
          break;
        case 'PUT':
          res = await http.put(uri,
              headers: _headers,
              body: body != null ? jsonEncode(body) : null);
          break;
        case 'DELETE':
          res = await http.delete(uri, headers: _headers);
          break;
        default:
          throw ApiException('Unknown method: $method');
      }
    } on SocketException {
      throw ApiException('No internet connection. Check your network.');
    } on http.ClientException {
      throw ApiException('Could not reach the server. Try again later.');
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }

    String detail = 'Request failed (${res.statusCode})';
    try {
      final err = jsonDecode(res.body);
      detail = err['detail'] ?? detail;
    } catch (_) {}
    throw ApiException(detail, statusCode: res.statusCode);
  }

  // Multipart for file uploads
  Future<dynamic> _postMultipart(
      String path, Map<String, String> fields, List<File> files) async {
    final uri = Uri.parse('$baseUrl$path');
    final req = http.MultipartRequest('POST', uri);
    req.headers['Authorization'] = 'Bearer $_token';
    req.fields.addAll(fields);
    for (final file in files) {
      req.files.add(await http.MultipartFile.fromPath('files', file.path));
    }
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }
    String detail = 'Upload failed';
    try {
      detail = jsonDecode(res.body)['detail'] ?? detail;
    } catch (_) {}
    throw ApiException(detail);
  }

  // ── AUTH ────────────────────────────────────────────────────────────────────

  Future<User> login(String username, String password) async {
    final data =
        await _post('/auth/login', {'username': username, 'password': password});
    final result = AuthResult.fromJson(data);
    _token = result.token;
    _currentUser = result.user;
    await _storage.write(key: _tokenKey, value: _token);
    await _storage.write(key: _userKey, value: jsonEncode({
      'id': _currentUser!.id,
      'username': _currentUser!.username,
      'email': _currentUser!.email,
      'full_name': _currentUser!.fullName,
      'role': _currentUser!.role,
      'is_active': _currentUser!.isActive,
      'created_at': _currentUser!.createdAt.toIso8601String(),
    }));
    notifyListeners();
    return _currentUser!;
  }

  Future<User> register(String username, String email, String password,
      String fullName) async {
    await _post('/auth/register', {
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
    });
    return await login(username, password);
  }

  Future<User> me() async {
    final data = await _get('/auth/me');
    _currentUser = User.fromJson(data);
    notifyListeners();
    return _currentUser!;
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    notifyListeners();
  }

  // ── ANNOUNCEMENTS ───────────────────────────────────────────────────────────

  Future<List<Announcement>> getAnnouncements({String? category}) async {
    final q = category != null ? '?category=$category' : '';
    final data = await _get('/announcements$q') as List;
    return data.map((j) => Announcement.fromJson(j)).toList();
  }

  Future<Announcement> getAnnouncement(int id) async {
    final data = await _get('/announcements/$id');
    return Announcement.fromJson(data);
  }

  Future<Announcement> createAnnouncement({
    required String title,
    required String content,
    required String category,
    required bool isPinned,
    List<File> files = const [],
  }) async {
    final data = await _postMultipart(
      '/announcements',
      {
        'title': title,
        'content': content,
        'category': category,
        'is_pinned': isPinned.toString(),
      },
      files,
    );
    return Announcement.fromJson(data);
  }

  Future<Announcement> updateAnnouncement(int id,
      {String? title, String? content, String? category, bool? isPinned}) async {
    final data = await _put('/announcements/$id', {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (category != null) 'category': category,
      if (isPinned != null) 'is_pinned': isPinned,
    });
    return Announcement.fromJson(data);
  }

  Future<void> deleteAnnouncement(int id) async => await _delete('/announcements/$id');

  Future<void> uploadAttachments(int annId, List<File> files) async {
    final req = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/announcements/$annId/attachments'));
    req.headers['Authorization'] = 'Bearer $_token';
    for (final file in files) {
      req.files.add(await http.MultipartFile.fromPath('files', file.path));
    }
    final streamed = await req.send();
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw ApiException('Upload failed');
    }
  }

  Future<void> deleteAttachment(int attId) async =>
      await _delete('/attachments/$attId');

  // ── COMMENTS ────────────────────────────────────────────────────────────────

  Future<List<Comment>> getComments(int announcementId) async {
    final data = await _get('/announcements/$announcementId/comments') as List;
    return data.map((j) => Comment.fromJson(j)).toList();
  }

  Future<Comment> createComment(int announcementId, String content) async {
    final data =
        await _post('/announcements/$announcementId/comments', {'content': content});
    return Comment.fromJson(data);
  }

  Future<void> moderateComment(int commentId, {required bool hide}) async =>
      await _put('/comments/$commentId/hide?hide=$hide');

  Future<void> deleteComment(int commentId) async =>
      await _delete('/comments/$commentId');

  // ── MESSAGES ────────────────────────────────────────────────────────────────

  Future<List<InboxItem>> getInbox() async {
    final data = await _get('/messages/inbox') as List;
    return data.map((j) => InboxItem.fromJson(j)).toList();
  }

  Future<List<Message>> getConversation(int otherUserId) async {
    final data = await _get('/messages/conversation/$otherUserId') as List;
    return data.map((j) => Message.fromJson(j)).toList();
  }

  Future<Message> sendMessage(int receiverId, String content) async {
    final data =
        await _post('/messages', {'receiver_id': receiverId, 'content': content});
    return Message.fromJson(data);
  }

  // ── NOTIFICATIONS ────────────────────────────────────────────────────────────

  Future<List<AppNotification>> getNotifications({bool unreadOnly = false}) async {
    final q = unreadOnly ? '?unread_only=true' : '';
    final data = await _get('/notifications$q') as List;
    return data.map((j) => AppNotification.fromJson(j)).toList();
  }

  Future<int> getUnreadCount() async {
    final data = await _get('/notifications/count');
    return data['count'] as int? ?? 0;
  }

  Future<void> markNotificationRead(int notifId) async =>
      await _put('/notifications/$notifId/read');

  Future<void> markAllNotificationsRead() async =>
      await _put('/notifications/read-all');

  // ── USERS ────────────────────────────────────────────────────────────────────

  Future<List<User>> getUsers() async {
    final data = await _get('/users') as List;
    return data.map((j) => User.fromJson(j)).toList();
  }

  Future<User> promoteUser(int userId, String role) async {
    final data = await _put('/users/$userId/promote', {'role': role});
    return User.fromJson(data);
  }

  Future<User> deactivateUser(int userId) async {
    final data = await _put('/users/$userId/deactivate');
    return User.fromJson(data);
  }
}
