import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

// Minimum required version of the Flutter app
// If desired, load this from an environment variable for each flavor
// https://api.dart.dev/stable/3.5.1/dart-io/Platform/environment.html
const kRequiredVersion = '2.0.0';

Future<Response> handleRequest(Request request) async {
  // Handle incoming requests based on the URL path
  // If the path is 'required_version', call the requiredVersion function
  // For any other path, return a 404 Not Found response
  return switch (request.url.path) {
    'required_version' => Future.value(requiredVersion(request)),
    _ => Future.value(Response.notFound('Not found')),
  };
}

Response requiredVersion(Request request) {
  return Response.ok(kRequiredVersion);
}

void main() async {
  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(handleRequest);

  final server = await io.serve(
    handler,
    InternetAddress.anyIPv4,
    int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080,
  );
  print('Serving at http://${server.address.host}:${server.port}');
}
