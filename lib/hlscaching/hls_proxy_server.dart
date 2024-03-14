import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

class HLSProxyServer {
  factory HLSProxyServer() {
    instance ??= HLSProxyServer._();
    instance!._init();
    return instance!;
  }

  HLSProxyServer._();

  static HLSProxyServer? instance;
  final cache = DefaultCacheManager();
  HttpServer? webServer;
  Handler? pipelineHandler;
  final String originURLKey = "__hls_origin_url";
  final String contentType = "application/x-mpegurl";
  static const int _port = 1234;
  final m3u8File = RegExp(r'^.*\.m3u8$');
  final m3u8Segment = RegExp(r'^.*\.ts$');

  Future<void> _init() async {
    try {
      pipelineHandler ??= const Pipeline()
          .addMiddleware(logRequests())
          .addHandler(requestHandler);
      webServer ??= await shelf_io.serve(pipelineHandler!, '127.0.0.1', _port);
      webServer!.autoCompress = true;
    }
    catch (e){
      print(e.toString());
    }
  }

  String proxyURL(String originUrl) {
    final localURL = Uri.parse(originUrl);
    final proxyURI = Uri(
        scheme: 'http',
        host: '127.0.0.1',
        port: _port,
        path: localURL.path,
        queryParameters: {
          originURLKey: '${localURL.scheme}://${localURL.host}'
        });
    return proxyURI.toString();
  }

  Future<void> testAPICall()async {
    final uri = Uri.parse('http://127.0.0.1:1234/sampleTest');
    uri.replace(port: 1234);
    http.Response response = await http.get(uri);
    print(response.statusCode);
  }

  Future<void> clearCache() async {
    await cache.emptyCache();
  }

  Future<Response> requestHandler(Request request) async {
    print('Janak got request ${request.url}');
    try {
      switch (request.method) {
        case 'GET':
          return handleGETRequest(request);
        case 'POST':
        default:
          return Future.value(Response.ok('Request successful'));
      }
    } catch (e) {
      return Future.value(Response.internalServerError(body: e));
    }
  }

  Future<Response> handleGETRequest(Request request) async {
    final path = request.url.path;
    if (m3u8File.hasMatch(path)) {
      return handlePlaylist(request);
    } else if (m3u8Segment.hasMatch(path)) {
      return handleSegment(request);
    } else {
      return Response.notFound('No such path');
    }
  }

  Future<Response> handlePlaylist(Request request) async {
    final path = request.url.path;
    final cachedData = await cacheData(path);
    if (cachedData != null) {
      // TODO(janak): check for the response data type
      return Response(200,
          body: cachedData.file.readAsBytesSync(),
          headers: {'Content-Type': contentType});
    } else {
      print('---------- Made network API call ------------');
      final originURL = request.url.queryParameters[originURLKey];
      final originURI = Uri.parse('$originURL/$path');
      if (originURL == null) return Response.notFound('No url fount in query');
      http.Response response = await http.get(originURI);
      print('Playlist response ${response.body}');
      // TODO(janak): check for the response data type
      if (response.statusCode >= 200 && response.statusCode <= 300) {
        // TODO(janak): Save data to cache
        //
        final playlistData =
            proxyPlaylist(response.body, Uri.parse('$originURL/$path'));
        saveCacheData(response.bodyBytes, path.toString(), 'm3u8');
        return Response(200, body: playlistData);
      } else {
        return Response(response.statusCode);
      }
    }
  }

  // TODO(janak): Implement for video segment handling.
  Future<Response> handleSegment(Request request) async {
    final path = request.url.path;
    final cachedData = await cacheData(path);
    if (cachedData != null) {
      // TODO(janak): check for the response data type
      return Response(200,
          body: cachedData.file.readAsBytesSync(),
          headers: {'Content-Type': 'video/mp2t'});
    } else {
      final originURL = request.url.queryParameters[originURLKey];
      if (originURL == null) return Response.notFound('No url found in query');
      print('---------- Made network API call ------------');
      http.Response response = await http.get(Uri.parse('$originURL/$path'),
          headers: {'Content-Type': 'video/mp2t'});
      // TODO(janak): check for the response data type
      if (response.statusCode >= 200 && response.statusCode <= 300) {
        saveCacheData(response.bodyBytes, path.toString(), 'ts');
        return Response(200,
            body: response.bodyBytes, headers: {'Content-Type': 'video/mp2t'});
      } else {
        return Response(response.statusCode);
      }
    }
  }

  /// Manipulating playlist
  String proxyPlaylist(String data, Uri url) {
    final lines = LineSplitter.split(data);
    //TODO(janak): In case if m3u8 file contain URI in file itself used below
    // line
    //final processedLines = lines.map((e) => processPlaylistLine(e, url));
    final processedLines = lines.map((e) {
      if (e.trim().endsWith('.m3u8') || e.trim().endsWith('.ts')) return createProxySubURI(e, url);
      return e;
    }).toList();
    final joinedString = processedLines.join('\n');
    return joinedString;
  }

  String createProxySubURI(String filename, Uri url) {
    print('path : ${url.path}');
    final path = url.path.split('/')..removeLast();
    return 'http://127.0.0.1:$_port${path.join('/')}/$filename?$originURLKey=${url.scheme}://${url.host}';
  }

  String processPlaylistLine(String line, Uri originURL) {
    if (line.isEmpty) {
      return line;
    }
    if (line.startsWith('#')) {
      return lineByReplacingURI(line, originURL);
    }
    return '';
  }

  String lineByReplacingURI(String line, Uri originUrl) {
    final uriPattern = RegExp(r'URI="(.*)"');
    final match = uriPattern.firstMatch(line);
    if (match == null) {
      return line;
    }
    final uri = match.group(1);
    if (uri == null) {
      return line;
    }

    final absoluteURL = absoluteUrlFromLine(uri, originUrl);
    if (absoluteURL == null) {
      return line;
    }

    final reverseProxyURL = proxyURL(absoluteURL.toString());
    return line.replaceFirst(uri, reverseProxyURL);
  }

  Uri? absoluteUrlFromLine(String line, Uri originUrl) {
    if (!['m3u8', 'ts'].contains(originUrl.pathSegments.last)) {
      return null;
    }
    if (line.startsWith('http://') || line.startsWith('https://')) {
      return Uri.parse(line);
    }
    final scheme = originUrl.scheme;
    final host = originUrl.host;
    final parentPath = originUrl.pathSegments
        .take(originUrl.pathSegments.length - 1)
        .join('/');
    final path = line.startsWith('/') ? line : '$parentPath/$line';
    return Uri.parse('$scheme://$host$path').normalizePath();
  }

  Future<FileInfo?> cacheData(String originUrl) async {
    return await cache.getFileFromCache(originUrl);
  }

  void saveCacheData(Uint8List data, String resourceUrl,String extension) {
    cache.putFile(resourceUrl, data,fileExtension: extension);
  }
}
