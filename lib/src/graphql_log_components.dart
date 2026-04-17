import 'package:flutter/material.dart';

class GraphQLEmptyLogsView extends StatelessWidget {
  const GraphQLEmptyLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.monitor_heart_outlined,
              size: 44,
              color: colorScheme.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 10),
            Text(
              'No GraphQL logs yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Run a query or mutation, then open this screen again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class GraphQLNoSearchResultsView extends StatelessWidget {
  const GraphQLNoSearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Text(
        'No requests match your search.',
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class GraphQLInspectorOverview extends StatelessWidget {
  final int totalCount;
  final int queryCount;
  final int mutationCount;
  final int failedCount;

  const GraphQLInspectorOverview({
    super.key,
    required this.totalCount,
    required this.queryCount,
    required this.mutationCount,
    required this.failedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          GraphQLMetricChip(
            label: 'Total',
            value: totalCount.toString(),
            icon: Icons.stacked_line_chart_rounded,
          ),
          GraphQLMetricChip(
            label: 'Queries',
            value: queryCount.toString(),
            icon: Icons.search_rounded,
          ),
          GraphQLMetricChip(
            label: 'Mutations',
            value: mutationCount.toString(),
            icon: Icons.edit_note_rounded,
          ),
          GraphQLMetricChip(
            label: 'Failed',
            value: failedCount.toString(),
            icon: Icons.error_outline_rounded,
            isWarning: failedCount > 0,
          ),
        ],
      ),
    );
  }
}

class GraphQLMetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isWarning;

  const GraphQLMetricChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isWarning
        ? colorScheme.errorContainer
        : colorScheme.secondaryContainer;
    final foregroundColor = isWarning
        ? colorScheme.onErrorContainer
        : colorScheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              color: foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class GraphQLSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const GraphQLSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search by operation or request content',
          prefixIcon: const Icon(Icons.search_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
      ),
    );
  }
}

class GraphQLLogListTile extends StatelessWidget {
  final Map<String, dynamic> log;
  final String title;
  final bool isFailed;
  final bool isQuery;
  final VoidCallback onTap;

  const GraphQLLogListTile({
    super.key,
    required this.log,
    required this.title,
    required this.isFailed,
    required this.isQuery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final time = (log['time']?.toString() ?? '')
        .replaceFirst('.000', '')
        .replaceFirst('T', ' ');
    final url = (log['url'] ?? '').toString();

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              _OperationMarker(isQuery: isQuery, isFailed: isFailed),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _TypeBadge(isQuery: isQuery),
                        const SizedBox(width: 6),
                        _StatusBadge(isFailed: isFailed),
                        const Spacer(),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GraphQLLogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> log;
  final String title;
  final String Function(String url, dynamic headers, Map<String, dynamic> log)
  curlBuilder;
  final void Function(BuildContext context, String curl) onShareCurl;
  final String Function(dynamic input) prettyJson;
  final TextSpan Function(String input) colorizeJson;

  const GraphQLLogDetailScreen({
    super.key,
    required this.log,
    required this.title,
    required this.curlBuilder,
    required this.onShareCurl,
    required this.prettyJson,
    required this.colorizeJson,
  });

  @override
  Widget build(BuildContext context) {
    final url = (log['url'] ?? '').toString();
    final headers = log['headers'];
    final isFailed = (log['response'] ?? '').toString().toLowerCase().contains(
      '"errors"',
    );
    final isQuery = (log['query'] ?? '')
        .toString()
        .trimLeft()
        .toLowerCase()
        .startsWith('query');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              tooltip: 'Copy cURL',
              onPressed: () {
                onShareCurl(context, curlBuilder(url, headers, log));
              },
              icon: const Icon(Icons.copy_all_outlined),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Request'),
              Tab(text: 'Response'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              children: [
                Row(
                  children: [
                    _TypeBadge(isQuery: isQuery),
                    const SizedBox(width: 8),
                    _StatusBadge(isFailed: isFailed),
                  ],
                ),
                const SizedBox(height: 12),
                GraphQLSectionBlock(
                  title: 'Endpoint',
                  icon: Icons.public_rounded,
                  content: url,
                  isJson: false,
                  colorizeJson: colorizeJson,
                ),
                GraphQLSectionBlock(
                  title: 'Timestamp',
                  icon: Icons.schedule_rounded,
                  content: (log['time'] ?? '').toString(),
                  isJson: false,
                  colorizeJson: colorizeJson,
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              children: [
                GraphQLSectionBlock(
                  title: 'Query',
                  icon: Icons.code_rounded,
                  content: (log['query'] ?? '').toString(),
                  isJson: false,
                  colorizeJson: colorizeJson,
                ),
                GraphQLSectionBlock(
                  title: 'Headers',
                  icon: Icons.badge_outlined,
                  content: prettyJson(log['headers']),
                  isJson: true,
                  colorizeJson: colorizeJson,
                ),
                GraphQLSectionBlock(
                  title: 'Variables',
                  icon: Icons.tune_rounded,
                  content: prettyJson(log['variables']),
                  isJson: true,
                  colorizeJson: colorizeJson,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              child: GraphQLSectionBlock(
                title: 'Response Body',
                icon: Icons.data_object_rounded,
                content: prettyJson(log['response']),
                isJson: true,
                colorizeJson: colorizeJson,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GraphQLSectionBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final bool isJson;
  final TextSpan Function(String input) colorizeJson;

  const GraphQLSectionBlock({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    required this.isJson,
    required this.colorizeJson,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final value = content.isEmpty ? 'N/A' : content;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GraphQLContentContainer(
            content: value,
            isJson: isJson,
            colorizeJson: colorizeJson,
            maxHeight: 360,
          ),
        ],
      ),
    );
  }
}

class GraphQLContentContainer extends StatelessWidget {
  final String content;
  final bool isJson;
  final TextSpan Function(String input) colorizeJson;
  final double maxHeight;

  const GraphQLContentContainer({
    super.key,
    required this.content,
    required this.isJson,
    required this.colorizeJson,
    this.maxHeight = 220,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shouldHighlightJson = isJson && content.length <= 60000;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: _buildContentText(
                    colorScheme: colorScheme,
                    shouldHighlightJson: shouldHighlightJson,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentText({
    required ColorScheme colorScheme,
    required bool shouldHighlightJson,
  }) {
    final textStyle = TextStyle(
      fontFamily: 'Courier',
      fontSize: 12,
      color: colorScheme.onSurface,
      height: 1.35,
    );

    if (!shouldHighlightJson) {
      return SelectableText(content, style: textStyle);
    }

    try {
      return SelectableText.rich(colorizeJson(content), style: textStyle);
    } catch (_) {
      // Fallback for malformed or very large JSON chunks.
      return SelectableText(content, style: textStyle);
    }
  }
}

class _OperationMarker extends StatelessWidget {
  final bool isQuery;
  final bool isFailed;

  const _OperationMarker({required this.isQuery, required this.isFailed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isFailed
        ? colorScheme.error
        : isQuery
        ? Colors.blue
        : Colors.orange;
    return Container(
      width: 4,
      height: 46,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final bool isQuery;

  const _TypeBadge({required this.isQuery});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _RoundedBadge(
      label: isQuery ? 'Query' : 'Mutation',
      textColor: colorScheme.onSecondaryContainer,
      backgroundColor: colorScheme.secondaryContainer,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isFailed;

  const _StatusBadge({required this.isFailed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _RoundedBadge(
      label: isFailed ? 'Failed' : 'Success',
      textColor: isFailed
          ? colorScheme.onErrorContainer
          : Colors.green.shade900,
      backgroundColor: isFailed
          ? colorScheme.errorContainer
          : Colors.green.shade100,
    );
  }
}

class _RoundedBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;

  const _RoundedBadge({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
