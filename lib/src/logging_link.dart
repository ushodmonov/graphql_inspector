import 'dart:convert';

import 'package:gql/language.dart' show printNode;
import 'package:graphql_flutter/graphql_flutter.dart';

class GQLLogger {
  static final GQLLogger _instance = GQLLogger._internal();
  final List<Map<String, dynamic>> logs = [];
  factory GQLLogger() => _instance;

  GQLLogger._internal();

  List<Map<String, dynamic>> getLogs() => logs.reversed.toList();

  void log(
    String query,
    Map<String, dynamic> variables,
    String url,
    dynamic headers,
  ) {
    logs.add({
      'query': query,
      'variables': variables,
      'url': url,
      'headers': headers,
      'response': null,
      'time': DateTime.now(),
    });
  }

  void updateLastResponse(dynamic response) {
    if (logs.isNotEmpty) {
      logs.last['response'] = response;
    }
  }
}

class LoggingLink extends Link {
  final Link innerLink;
  final String url;
  final dynamic headers;

  LoggingLink({
    required this.innerLink,
    required this.url,
    required this.headers,
  });

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    final query = request.operation.document;
    final rawQuery = printNode(query);
    final variables = request.variables;

    // Optional: Save logs
    GQLLogger().log(rawQuery, variables, url, headers);
    final stream = innerLink.request(request, forward);

    return stream.map((response) {
      GQLLogger().updateLastResponse(_prettyJson(response.data));
      return response;
    });
  }

  String _prettyJson(dynamic input) {
    try {
      return const JsonEncoder.withIndent('  ').convert(input);
    } catch (_) {
      return input.toString();
    }
  }
}
