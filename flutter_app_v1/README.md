# Legal Connect Mobile App

Flutter client for the Legal Connect Docker backend.

## Requirements

- Backend API running at `http://localhost:8080/v1`
- AI API running at `http://localhost:8000/api/v1`

## Default API Mapping

- Android emulator: `http://10.0.2.2:8080/v1`
- Chrome, Linux desktop, iOS simulator: `http://localhost:8080/v1`
- Physical device: pass your computer LAN IP with `--dart-define`

## Run

Android emulator:

```bash
flutter run
```

Chrome web:

```bash
flutter run -d chrome --web-port 5173
```

Physical device:

```bash
flutter run \
  --dart-define=LC_BACKEND_HOST=<LAN_IP> \
  --dart-define=LC_AI_HOST=<LAN_IP>
```

## Demo Login

- Email: `demo.user1@legalconnect.local`
- Password: `Demo@1234`

More demo accounts are listed in `legal-connect/demo-credentials.txt`.
