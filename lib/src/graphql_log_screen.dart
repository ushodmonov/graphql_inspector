import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../graphql_inspector.dart';
import 'graphql_log_components.dart';

class GraphQLLogScreen extends StatefulWidget {
  const GraphQLLogScreen({super.key});

  @override
  State<GraphQLLogScreen> createState() => _GraphQLLogScreenState();
}

class _GraphQLLogScreenState extends State<GraphQLLogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = GQLLogger().getLogs();
    final searchQuery = _searchController.text.trim().toLowerCase();
    final filteredLogs = logs.where((log) {
      if (searchQuery.isEmpty) {
        return true;
      }
      final operationName =
          _extractOperationName(log['query'])?.toLowerCase() ?? '';
      final rawQuery = (log['query'] ?? '').toString().toLowerCase();
      final variables = _prettyJson(log['variables']).toLowerCase();
      return operationName.contains(searchQuery) ||
          rawQuery.contains(searchQuery) ||
          variables.contains(searchQuery);
    }).toList();
    final colorScheme = Theme.of(context).colorScheme;
    final queryCount = logs.where(_isQuery).length;
    final mutationCount = logs.where((log) => !_isQuery(log)).length;
    final failedCount = logs.where(_isFailed).length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('GraphQL Inspector'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Clear logs',
            onPressed: logs.isEmpty
                ? null
                : () {
                    GQLLogger().logs.clear();
                    setState(() {});
                  },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: logs.isEmpty
          ? const GraphQLEmptyLogsView()
          : Column(
              children: [
                GraphQLInspectorOverview(
                  totalCount: logs.length,
                  queryCount: queryCount,
                  mutationCount: mutationCount,
                  failedCount: failedCount,
                ),
                GraphQLSearchBar(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                ),
                Expanded(
                  child: filteredLogs.isEmpty
                      ? const GraphQLNoSearchResultsView()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                          itemCount: filteredLogs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final log = filteredLogs[index];
                            return GraphQLLogListTile(
                              log: log,
                              title:
                                  _extractOperationName(log['query']) ??
                                  'GraphQL Query',
                              isFailed: _isFailed(log),
                              isQuery: _isQuery(log),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GraphQLLogDetailScreen(
                                      log: log,
                                      title:
                                          _extractOperationName(log['query']) ??
                                          'GraphQL Query',
                                      curlBuilder: _buildCurlCommand,
                                      onShareCurl: _shareCurlCommand,
                                      prettyJson: _prettyJson,
                                      colorizeJson: _colorizeJson,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
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
    if (input == null) {
      return '';
    }

    if (input is String) {
      final trimmed = input.trim();
      if (trimmed.isEmpty) {
        return '';
      }
      try {
        final decoded = jsonDecode(trimmed);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (_) {
        return input;
      }
    }

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

  bool _isQuery(Map<String, dynamic> log) {
    final query = (log['query'] ?? '').toString().trimLeft().toLowerCase();
    return query.startsWith('query');
  }

  bool _isFailed(Map<String, dynamic> log) {
    final response = log['response'];
    if (response == null) {
      return false;
    }
    final responseText = response.toString().toLowerCase();
    return responseText.contains('"errors"') || responseText.contains('exception');
  }
}
