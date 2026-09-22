# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .

# API_BASE_URL (and any other dart-defines) must be baked in at build time,
# same as the local/Android/Netlify builds — a build without this compiles
# with an empty API_BASE_URL, which throws StateError on first API call at
# runtime instead of failing the build.
RUN test -f dart_defines.json || (echo "ERROR: dart_defines.json not found in build context. Copy dart_defines.example.json to dart_defines.json and fill in real values before building the image." && exit 1)
RUN grep -q '"API_BASE_URL"' dart_defines.json || (echo "ERROR: API_BASE_URL is missing from dart_defines.json." && exit 1)

RUN flutter build web --release --dart-define-from-file=dart_defines.json


# Serve stage
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
