import 'dart:io';

import 'package:path/path.dart';

Future<void> main(List<String> arguments) async {
  // Default host and port
  const host = 'localhost';
  const port = 8080;

  // Get the current working directory
  final directoryPath = join(Directory.current.path, "doc", "api");

  print('Serving files from $directoryPath on http://$host:$port/index.html');

  final server = await HttpServer.bind(host, port);

  await for (HttpRequest request in server) {
    final filePath = '$directoryPath${request.uri.path}';
    final file = File(filePath);

    if (await file.exists()) {
      try {
        final mimeType = _getMimeType(filePath);
        request.response.headers.contentType = ContentType.parse(mimeType);
        await request.response.addStream(file.openRead());
        await request.response.close();
      } catch (e) {
        print('Error serving file: $e');
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      }
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('404: Not Found');
      await request.response.close();
    }
  }
}

String _getMimeType(String path) {
  if (path.endsWith('.html')) return 'text/html';
  if (path.endsWith('.css')) return 'text/css';
  if (path.endsWith('.js')) return 'application/javascript';
  if (path.endsWith('.png')) return 'image/png';
  if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
  return 'application/octet-stream';
}
