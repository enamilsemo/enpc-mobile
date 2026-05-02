# ENPC Mobile App — Flutter Client

Mobile application for the **ENPC Official Communication System**.  
Connects to the live backend at: **https://enpc-system.onrender.com**

---

## 📁 Project Structure

```
enpc_mobile/
├── lib/
│   ├── main.dart              # App entry, routing, splash screen
│   ├── models/
│   │   └── models.dart        # All data classes (User, Announcement, Message…)
│   ├── services/
│   │   └── api.dart           # All API calls — single source of truth
│   ├── widgets/
│   │   └── widgets.dart       # Shared UI: theme, avatar, badges, etc.
│   └── screens/
│       └── screens.dart       # All screens in one file
│
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── res/xml/file_paths.xml
│   ├── build.gradle
│   ├── settings.gradle
│   └── gradle.properties
│
└── pubspec.yaml
```

---

## 🔗 Backend

The app uses the existing deployed backend — **no backend changes needed**.

| Endpoint Base | `https://enpc-system.onrender.com` |
|---|---|
| Auth | `/auth/login`, `/auth/register`, `/auth/me` |
| Announcements | `/announcements` |
| Comments | `/announcements/{id}/comments` |
| Messages | `/messages/inbox`, `/messages/conversation/{id}` |
| Notifications | `/notifications`, `/notifications/count` |
| Users | `/users` (admin only) |

---

## 👤 Default Credentials

| Role | Username | Password |
|------|----------|----------|
| Super Admin | `slimane` | `slimane.2007` |
| Student | Register via app | — |

---

## 🚀 Setup & Run

### 1. Install Flutter SDK

```bash
# Download from https://docs.flutter.dev/get-started/install
# Minimum version: Flutter 3.10+

flutter --version
flutter doctor
```

### 2. Install Dependencies

```bash
cd enpc_mobile
flutter pub get
```

### 3. Run on Device / Emulator

```bash
# List available devices
flutter devices

# Run on connected Android device
flutter run

# Run on specific device
flutter run -d <device_id>
```

### 4. Run on Android Emulator

```bash
# Start emulator from Android Studio, then:
flutter run
```

---

## 📦 Build APK

### Debug APK (for testing)

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (for distribution)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Split APKs by ABI (smaller file size, recommended)

```bash
flutter build apk --split-per-abi --release
# Outputs:
#   app-arm64-v8a-release.apk    ← modern phones (use this)
#   app-armeabi-v7a-release.apk  ← older phones
#   app-x86_64-release.apk       ← emulators
```

### App Bundle (for Google Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 📱 Install APK on Phone

```bash
# Via ADB (USB)
adb install build/app/outputs/flutter-apk/app-release.apk

# Or just copy the APK file to your phone and open it
# (Enable "Install unknown apps" in Android Settings)
```

---

## 🎨 Features

### All Users (Students)
- ✅ Login / Register
- ✅ Auto-login (JWT saved securely)
- ✅ Browse announcements feed with category filter
- ✅ Pull-to-refresh
- ✅ View full announcement with images & file attachments
- ✅ Post comments
- ✅ View & send private messages (inbox + chat)
- ✅ Notifications with unread badge
- ✅ Mark notifications as read / mark all read

### Admins
- ✅ All student features
- ✅ Create announcements with image/file upload
- ✅ Edit and delete announcements
- ✅ Delete existing attachments
- ✅ Hide/unhide comments
- ✅ Delete comments

### Super Admin
- ✅ All admin features
- ✅ User management screen
- ✅ Promote/demote users (Student ↔ Admin)
- ✅ Deactivate users

---

## ⚙️ Configuration

To change the backend URL, edit one line in `lib/services/api.dart`:

```dart
static const String baseUrl = 'https://enpc-system.onrender.com';
```

---

## 🔒 Security

- JWT token stored in **Flutter Secure Storage** (Android Keystore)
- Token auto-cleared on logout
- Auto-login validates token on every app launch
- Role checks enforced by backend on every request

---

## 📋 Dependencies

| Package | Purpose |
|---------|---------|
| `http` | HTTP requests to backend |
| `flutter_secure_storage` | Secure JWT storage |
| `provider` | State management |
| `google_fonts` | DM Sans + DM Serif Display |
| `cached_network_image` | Image loading & caching |
| `timeago` | "2 minutes ago" timestamps |
| `image_picker` | Pick images from gallery/camera |
| `file_picker` | Pick PDF/Word/Excel files |
| `url_launcher` | Open file downloads in browser |

---

## 🛠️ Troubleshooting

**"flutter pub get" fails:**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

**Gradle sync issues:**
```bash
cd android
./gradlew clean
cd ..
flutter pub get
```

**App can't connect to backend:**
- Check internet connection
- The Render free tier spins down after inactivity — first request may take 30–60 seconds
- After the backend wakes up, refresh the app

**Secure storage issues on emulator:**
```bash
# Use a physical device, or add this to your emulator config:
# In android/app/build.gradle:
# minSdk 23
```

**File picker not working on Android 13+:**
- The AndroidManifest.xml already includes `READ_MEDIA_IMAGES` permission
- Grant permission when prompted on device
