# Force Update Helper - Example Dart Shelf App

A simple server-side app that implements a `required_version` endpoint using [Dart Shelf](https://pub.dev/packages/shelf).

This can be used as part of the force update logic in your Flutter apps.

## Running the server (localhost)

To run locally:

```zsh
dart run lib/server.dart 
```

To call the endpoint:

```zsh
curl http://0.0.0.0:8080/required_version
```

Example usage in the Flutter app:

```dart
ForceUpdateClient(
  fetchRequiredVersion: () async {
    // TODO: Replace with production URL on staging / prod flavors
    const baseUrl = 'http://0.0.0.0:8080';
    final dio = Dio();
    final response = await dio.get('$baseUrl/required_version');
    final requiredVersionStr = response.data;
    return requiredVersionStr;
  },
  ...
)
```

## Deploying the server

Many options are available for deploying the server:

- Docker Image
- Virtual machine (VM) or virtual private server (VPS)
- Dedicated Server
- Global Edge Network

For more details and a full tutorial, read:

- [How to Build and Deploy a Dart Shelf App on Globe.dev](https://codewithandrea.com/articles/build-deploy-dart-shelf-app-globe/)

### [LICENSE: MIT](LICENSE.md)