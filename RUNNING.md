# Running Astra Frontend

A complete guide to running **astra-frontend** — locally for development, as a Docker
container, and deployed to Kubernetes (EKS). Pick the section that matches what you're
trying to do.

| I want to... | Go to |
|---|---|
| Hack on the app and see live changes | [Local Development](#-local-development) |
| Build a production web bundle | [Building for Production](#-building-for-production) |
| Build & run the Docker image | [Docker](#-docker) |
| Deploy to the Kubernetes cluster | [Kubernetes (EKS)](#-kubernetes-eks) |
| Fix a config/env problem | [Troubleshooting](#-troubleshooting) |

---

## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| [FVM](https://fvm.app/) | latest | Manages the pinned Flutter SDK version for this repo |
| Flutter SDK | `3.44.9` | Installed automatically by `fvm install` — don't install Flutter globally and use it directly |
| Docker Desktop | latest, with **buildx** | Needed for image builds; buildx ships with modern Docker Desktop |
| `kubectl` | latest | Only needed for the Kubernetes deploy steps |
| Xcode / Android Studio | latest | Only if targeting iOS / Android |

Verify buildx supports `arm64` (the cluster's node architecture):

```bash
docker buildx ls
# look for "linux/arm64" in the PLATFORMS column
```

---

## 🔑 Environment Configuration (`dart_defines.json`)

Astra **never** bakes secrets or environment config into source or a bundled `.env` file —
a `.env` shipped as a Flutter asset is just a plain, publicly fetchable file inside the
web/mobile build. Instead, every environment value is injected at **build/run time** via
`--dart-define` and compiled directly into the binary.

**Setup (one-time):**

```bash
cp dart_defines.example.json dart_defines.json
```

Then fill in real values. `dart_defines.json` is **gitignored** — never commit it.

```jsonc
{
  "API_BASE_URL": "https://astradep.zeyro.in",
  // Optional, only needed if you're wiring up RM-portal-specific endpoints:
  "APP_RM_API_BASE_URL": "http://k8s-default-astraapi-....elb.ap-south-1.amazonaws.com/api/rm",
  "APP_BACKEND_URL": "http://k8s-default-astraapi-....elb.ap-south-1.amazonaws.com"
}
```

| Key | Required | Description |
|---|---|---|
| `API_BASE_URL` | ✅ Yes | Base URL the app talks to for all core API calls. Missing this throws a `StateError` on first network call, by design — no silent fallback to a wrong URL. |
| `APP_RM_API_BASE_URL` | ⛔ Not yet wired up | Reserved for the RM-portal API surface (`/api/rm`). |
| `APP_BACKEND_URL` | ⛔ Not yet wired up | Reserved for a generic backend base URL. |

> ⚠️ Internal vs. public URLs: an EKS-internal ELB (private IP, e.g. `172.16.x.x`) is only
> reachable from **inside the VPC** — that's fine when this app itself runs as a pod
> inside the same cluster, but it will hang/timeout for anyone hitting it from outside
> (their laptop browser, a public deployment, etc.). Use a public/Cloudflare-fronted URL
> when the app needs to be reachable from the open internet.

---

## 💻 Local Development

```bash
# 1. Pin & install the correct Flutter SDK (once per machine)
fvm use 3.44.9
fvm flutter clean
fvm flutter pub get

# 2. Run — always with --dart-define-from-file
fvm flutter run --dart-define-from-file=dart_defines.json
```

**Platform-specific run targets:**

```bash
# Web (Chrome)
fvm flutter run -d chrome --dart-define-from-file=dart_defines.json

# Mobile (debug)
fvm flutter run --dart-define-from-file=dart_defines.json

# Mobile (release mode, still local)
fvm flutter run --release --dart-define-from-file=dart_defines.json
```

**Quieter Android logs** — strip noisy platform-channel spam from `flutter run` output:

```powershell
fvm flutter run --dart-define-from-file=dart_defines.json | `
  Select-String -NotMatch "mali_config|PipelineWatcher|gralloc4|CCodecBufferChannel|MediaCodec"
```

> 💡 **Prefer VS Code's Run/Debug panel.** `.vscode/launch.json` already has
> `--dart-define-from-file` wired into every configuration, so you can't forget it there.

---

## 📦 Building for Production

### Web bundle (static files)

```bash
fvm flutter build web --release --dart-define-from-file=dart_defines.json
```
Output lands in `build/web/` — this is what the Docker image serves via nginx.

### Android App Bundle (Play Store)

Don't call `flutter build appbundle` directly — use the wrapper script, which **refuses to
build** if `dart_defines.json` is missing, so a release can't silently ship without config:

```bash
./build_android_release.sh
```

---

## 🐳 Docker

The image is a two-stage build: Flutter compiles the web bundle, then it's served by
`nginx:alpine`. The Dockerfile **hard-fails the build** if `dart_defines.json` (or its
`API_BASE_URL` key) is missing — a build can't silently ship with an empty base URL.

### Build for the EKS cluster (arm64)

The cluster's nodes are **arm64** — always build for that platform, not your host's
native architecture:

```bash
# Remove any stale image first
docker rmi astra-frontend:latest

# Build for arm64 and load into local Docker (slow: emulated via QEMU, ~20-40 min)
docker buildx build --platform linux/arm64 -t astra-frontend:latest --load .
```

Confirm the architecture:

```bash
docker inspect astra-frontend:latest --format '{{.Os}}/{{.Architecture}}'
# -> linux/arm64
```

### Run it locally (sanity check)

```bash
docker run --rm -p 8080:80 astra-frontend:latest
# open http://localhost:8080
```

Or via Compose:

```bash
docker-compose up
```

### Export for cluster loading

The cluster loads this image from a `.tar` rather than a registry pull
(`imagePullPolicy: IfNotPresent` in [`k8s-frontend.yaml`](k8s-frontend.yaml)):

```bash
docker save -o astra-frontend.tar astra-frontend:latest
```

---

## ☸️ Kubernetes (EKS)

1. **Build & export the image** — see [Docker](#-docker) above. Make sure it's built for
   `linux/arm64` to match the cluster's node architecture.

2. **Load the tar onto the target node(s) / into the cluster's container runtime**
   (mechanism depends on your cluster access — e.g. `ctr -n k8s.io images import`,
   `crictl`, or your node-provisioning process — ask your cluster admin if unsure).

3. **Apply the manifest:**
   ```bash
   kubectl apply -f k8s-frontend.yaml
   ```
   This creates:
   - `Deployment/astra-frontend-deployment` — 1 replica, serves on container port `80`
   - `Service/astra-frontend-service` — `LoadBalancer`, exposes port `8080` → `80`

4. **Verify:**
   ```bash
   kubectl get pods -l app=astra-frontend
   kubectl get svc astra-frontend-service
   ```

5. **Roll out a new build** (after rebuilding & re-saving the tar):
   ```bash
   kubectl rollout restart deployment/astra-frontend-deployment
   ```

---

## 🛠 Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Bad state: API_BASE_URL is not set` at runtime | Ran/built without `--dart-define-from-file=dart_defines.json` | Always pass the flag; see [Environment Configuration](#-environment-configuration-dart_definesjson) |
| Docker build fails: `dart_defines.json not found in build context` | File is gitignored and doesn't exist yet | `cp dart_defines.example.json dart_defines.json` and fill in real values before building |
| App can't reach the backend at all (hangs/times out) | `API_BASE_URL` points at an internal-only ELB (private IP) and the caller isn't inside that VPC | Use a public URL for anything accessed from outside the cluster/VPC |
| Voice input (mic) fails instantly on web | Historical bug — fixed in `speech_provider.dart`, which now uses the platform-adaptive `WebSocketChannel.connect` instead of the `dart:io`-only `IOWebSocketChannel` | Already fixed; if it regresses, check that no code re-imports `package:web_socket_channel/io.dart` |
| `docker buildx build --platform linux/arm64` is very slow | Building arm64 on a non-arm64 host emulates via QEMU | Expected — budget 20–40 minutes; consider a native arm64 builder for CI |

---

## 📂 Where things live

```text
lib/
├── core/                   # Shared utilities, themes, constants, base widgets
├── features/               # Domain-specific feature modules
│   ├── auth/               # OTP, PAN verification, MF Central linking
│   ├── chat/               # AI assistant UI, speech input/output
│   ├── mf/                 # Mutual fund holdings & aggregation
│   ├── navigation/         # App shell, bottom nav, routing
│   └── portfolio_analysis/ # Discipline, Allocation, Performance tabs
└── main.dart               # App entry point

dart_defines.example.json   # Template — copy to dart_defines.json and fill in
dart_defines.json           # Your real config (gitignored, never commit)
Dockerfile                  # Two-stage build: Flutter -> nginx
docker-compose.yml          # Local container run
k8s-frontend.yaml           # Deployment + Service manifest for the cluster
build_android_release.sh    # Guarded Play Store release build
```
