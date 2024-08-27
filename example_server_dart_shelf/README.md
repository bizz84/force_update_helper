A simple server-side Dart implementing a `required_version` endpoint.

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
final dio = Dio();
// TODO: Replace with production URL on staging / prod flavors
const baseUrl = 'http://0.0.0.0:8080';
final response = await dio.get('$baseUrl/required_version');
final requiredVersionStr = response.data;
if (requiredVersionStr.isEmpty) {
  log('Remote Config: required_version not set. Ignoring.', name: _name);
  return false;
}
// TODO: Compare this with the app version from package_info_plus
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