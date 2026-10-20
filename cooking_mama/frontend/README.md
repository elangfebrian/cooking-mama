# Cooking Mama — Frontend (Flutter)

Frontend Web, Android, dan iOS (satu codebase). Data diambil dari REST API di folder `../backend`.

```bash
flutter pub get
flutter run -d chrome                                   # Web (API: http://localhost:3000/api)
flutter run -d <android-emulator>                       # API: http://10.0.2.2:3000/api
flutter run --dart-define=API_BASE_URL=http://<IP-PC>:3000/api   # HP fisik
flutter test
```

Alur data: `screens` → `AppState` (`lib/data/app_state.dart`) → `ApiClient` (`lib/services/api_client.dart`).
Jalankan backend terlebih dahulu (lihat `../README.md`).
