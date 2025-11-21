import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/content_provider.dart';

class CommunityHub extends StatelessWidget {
  const CommunityHub({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentProvider = Provider.of<ContentProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Hub',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...contentProvider.communityPosts
              .take(2)
              .map(
                (post) => Column(
                  children: [
                    _buildForumPost(
                      context,
                      post['title'] ?? '',
                      post['user'] ?? '',
                      post['timeAgo'] ?? '',
                      post['replies'] ?? '',
                    ),
                    if (contentProvider.communityPosts.indexOf(post) < 1)
                      const Divider(),
                  ],
                ),
              ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, child: Text('Visit Community')),
        ],
      ),
    );
  }

  Widget _buildForumPost(
    BuildContext context,
    String title,
    String user,
    String time,
    String replies,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text('by $user • $time'),
      trailing: Text(replies),
      onTap: () {},
    );
  }
}
