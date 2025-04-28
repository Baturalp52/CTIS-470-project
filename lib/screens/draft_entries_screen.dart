import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/draft_entry_model.dart';
import '../providers/draft_entry_provider.dart';
import '../providers/auth_provider.dart';
import 'entry_create_screen.dart';

class DraftEntriesScreen extends StatefulWidget {
  const DraftEntriesScreen({super.key});

  @override
  State<DraftEntriesScreen> createState() => _DraftEntriesScreenState();
}

class _DraftEntriesScreenState extends State<DraftEntriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DraftEntryProvider>(context, listen: false).loadDrafts();
    });
  }

  Future<void> _deleteDraft(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Draft'),
        content: const Text('Are you sure you want to delete this draft?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<DraftEntryProvider>(context, listen: false)
          .deleteDraft(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draftProvider = Provider.of<DraftEntryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Draft Entries'),
      ),
      body: draftProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : draftProvider.error != null
              ? Center(child: Text(draftProvider.error!))
              : draftProvider.drafts.isEmpty
                  ? const Center(
                      child: Text(
                        'No draft entries found',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: draftProvider.drafts.length,
                      itemBuilder: (context, index) {
                        final draft = draftProvider.drafts[index];
                        final draftId = draft.id ?? 'unknown_id';
                        final draftContent = draft.content ?? 'No content';
                        final createdAt = draft.createdAt
                                ?.toLocal()
                                .toString()
                                .split('.')[0] ??
                            'Unknown date';

                        return Dismissible(
                          key: Key(draftId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) => _deleteDraft(draftId),
                          child: ListTile(
                            title: Text(
                              draftContent,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              'Created: $createdAt',
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EntryCreateScreen(
                                    draft: draft,
                                  ),
                                ),
                              );

                              if (result == true && mounted) {
                                await draftProvider.deleteDraft(draftId);
                              }
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
