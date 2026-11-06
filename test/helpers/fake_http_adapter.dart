import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Produces the answer of the fake server for one request.
typedef FakeHandler = Future<ResponseBody> Function(RequestOptions options);

/// [HttpClientAdapter] that answers from memory and records every request.
class FakeHttpAdapter implements HttpClientAdapter {
  new(this.handler);

  FakeHandler handler;

  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

/// Builds a JSON response with the given [status].
ResponseBody jsonResponse(Object? body, {int status = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
