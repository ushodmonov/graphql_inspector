import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../graphql_inspector.dart';
import 'graphql_log_components.dart';

class GraphQLLogScreen extends StatelessWidget {
  const GraphQLLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = GQLLogger().getLogs();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('GraphQL Inspector'),
        centerTitle: true,
        elevation: 0,
      ),
      body: logs.isEmpty
          ? const GraphQLEmptyLogsView()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return GraphQLLogCard(
                  log: log,
                  title: _extractOperationName(log['query']) ?? 'GraphQL Query',
                  curlBuilder: _buildCurlCommand,
                  onShareCurl: _shareCurlCommand,
                  prettyJson: _prettyJson,
                  colorizeJson: _colorizeJson,
                );
              },
            ),
    );
  }

  String _buildCurlCommand(
    String url,
    dynamic headers,
    Map<String, dynamic> log,
  ) {
    final normalizedUrl = url.trim().isEmpty
        ? 'https://example.com/graphql'
        : url;
    final normalizedHeaders = headers is Map ? headers : <String, dynamic>{};
    final payload = {'query': log['query'], 'variables': log['variables']};

    final headerString = normalizedHeaders.entries
        .map((e) => "-H '${e.key}: ${e.value}'")
        .join(' ');

    final dataString = jsonEncode(payload).replaceAll("'", r"'\''");

    return "curl -X POST $headerString -d '$dataString' '$normalizedUrl'";
  }

  TextSpan _colorizeJson(String input) {
    final regex = RegExp(
      r'("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|[0-9.+-eE]+|true|false|null)',
      multiLine: true,
    );

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(input)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: input.substring(lastMatchEnd, match.start)));
      }

      final matchText = match.group(0)!;
      TextStyle style;

      if (matchText.startsWith('"')) {
        if (matchText.endsWith(':')) {
          style = const TextStyle(color: Colors.purple); // Keys
        } else {
          style = const TextStyle(color: Colors.teal); // String values
        }
      } else if (matchText == 'true' || matchText == 'false') {
        style = const TextStyle(color: Colors.orange); //booleans
      } else if (matchText == 'null') {
        style = const TextStyle(color: Colors.grey); // null
      } else {
        style = const TextStyle(color: Colors.blue); // Numbers
      }

      spans.add(TextSpan(text: matchText, style: style));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < input.length) {
      spans.add(TextSpan(text: input.substring(lastMatchEnd)));
    }

    return TextSpan(children: spans);
  }

  String? _extractOperationName(String? query) {
    if (query == null) return null;
    final match = RegExp(r'(query|mutation)\s+(\w+)').firstMatch(query);
    return match?.group(2);
  }

  String _prettyJson(dynamic input) {
    try {
      return const JsonEncoder.withIndent('  ').convert(input);
    } catch (_) {
      return input.toString();
    }
  }

  void _shareCurlCommand(BuildContext context, String curl) {
    Clipboard.setData(ClipboardData(text: curl));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('cURL copied to clipboard')));
  }
}
