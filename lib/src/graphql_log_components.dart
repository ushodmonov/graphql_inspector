import 'package:flutter/material.dart';

class GraphQLContentContainer extends StatelessWidget {
  final String content;
  final bool isJson;
  final TextSpan Function(String input) colorizeJson;

  const GraphQLContentContainer({
    super.key,
    required this.content,
    required this.isJson,
    required this.colorizeJson,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            constraints: const BoxConstraints(maxHeight: 220),
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: isJson
                      ? SelectableText.rich(
                          colorizeJson(content),
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 12,
                            color: colorScheme.onSurface,
                            height: 1.35,
                          ),
                        )
                      : SelectableText(
                          content,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 12,
                            color: colorScheme.onSurface,
                            height: 1.35,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

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
              Icons.graphic_eq_rounded,
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

class GraphQLLogCard extends StatelessWidget {
  final Map<String, dynamic> log;
  final String title;
  final String Function(String url, dynamic headers, Map<String, dynamic> log)
  curlBuilder;
  final void Function(BuildContext context, String curl) onShareCurl;
  final String Function(dynamic input) prettyJson;
  final TextSpan Function(String input) colorizeJson;

  const GraphQLLogCard({
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
    final colorScheme = Theme.of(context).colorScheme;
    final url = (log['url'] ?? '').toString();
    final headers = log['headers'];
    final time = log['time']?.toString() ?? '';
    final query = (log['query'] ?? '').toString();
    final operationType = query.trimLeft().startsWith('mutation')
        ? 'Mutation'
        : 'Query';

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 10),
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(operationType),
                  visualDensity: VisualDensity.compact,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  backgroundColor: colorScheme.secondaryContainer,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          children: [
            GraphQLSectionBlock(
              title: 'URL',
              icon: Icons.public,
              content: url.isEmpty ? 'N/A' : url,
              isJson: false,
              colorizeJson: colorizeJson,
            ),
            GraphQLSectionBlock(
              title: 'Query',
              icon: Icons.code,
              content: (log['query'] ?? '').toString(),
              isJson: false,
              colorizeJson: colorizeJson,
            ),
            GraphQLSectionBlock(
              title: 'Headers',
              icon: Icons.badge_outlined,
              content: prettyJson(log['headers']),
              isJson: false,
              colorizeJson: colorizeJson,
            ),
            GraphQLSectionBlock(
              title: 'Variables',
              icon: Icons.tune,
              content: prettyJson(log['variables']),
              isJson: true,
              colorizeJson: colorizeJson,
            ),
            GraphQLSectionBlock(
              title: 'Response',
              icon: Icons.data_object,
              content: prettyJson(log['response']),
              isJson: true,
              colorizeJson: colorizeJson,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  final curl = curlBuilder(url, headers, log);
                  onShareCurl(context, curl);
                },
                icon: const Icon(Icons.copy_all_outlined, size: 18),
                label: const Text('Copy cURL'),
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
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            dense: true,
            minLeadingWidth: 20,
            minTileHeight: 24,
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, size: 16, color: colorScheme.primary),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          GraphQLContentContainer(
            content: value,
            isJson: isJson,
            colorizeJson: colorizeJson,
          ),
        ],
      ),
    );
  }
}
