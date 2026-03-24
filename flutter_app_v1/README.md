# Legal Connect Flutter App

This Flutter app talks to the Dockerized Legal Connect backend and AI services.

## Local Development

- Backend API default: `http://10.0.2.2:8080/v1` on Android emulator
- AI API default: `http://10.0.2.2:8000/api/v1` on Android emulator
- Web, iOS simulator, and desktop default to `localhost`
- Physical devices must point to your computer's LAN IP with `--dart-define`

## Run Commands

Android emulator:

```bash
flutter run
```

Physical device:

```bash
flutter run \
  --dart-define=LC_BACKEND_HOST=<LAN_IP> \
  --dart-define=LC_AI_HOST=<LAN_IP>
```

Optional overrides:

```bash
flutter run \
  --dart-define=LC_BACKEND_SCHEME=http \
  --dart-define=LC_BACKEND_HOST=192.168.0.10 \
  --dart-define=LC_BACKEND_PORT=8080 \
  --dart-define=LC_AI_SCHEME=http \
  --dart-define=LC_AI_HOST=192.168.0.10 \
  --dart-define=LC_AI_PORT=8000
```

## Login Check

- Docker backend should be reachable from the host at `http://localhost:8080/v1/auth/login`
- Demo credentials live in `legal-connect/demo-credentials.txt`
- If login fails with a connectivity message, confirm the host mapping matches your runtime target
