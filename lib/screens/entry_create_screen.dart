import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entry_model.dart';
import '../models/draft_entry_model.dart';
import '../providers/auth_provider.dart';
import '../providers/draft_entry_provider.dart';
import 'draft_entries_screen.dart';

class EntryCreateScreen extends StatefulWidget {
  final EntryModel? entry;
  final DraftEntryModel? draft;
  final String? topicId;

  const EntryCreateScreen({
    super.key,
    this.entry,
    this.draft,
    this.topicId,
  });

  @override
  State<EntryCreateScreen> createState() => _EntryCreateScreenState();
}

class _EntryCreateScreenState extends State<EntryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _contentController.text = widget.entry!.content;
    } else if (widget.draft != null) {
      _contentController.text = widget.draft!.content;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveAsDraft() async {
    if (_contentController.text.isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
    if (currentUserId == null) return;

    final draftProvider =
        Provider.of<DraftEntryProvider>(context, listen: false);
    final draft = DraftEntryModel(
      id: widget.draft?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: _contentController.text,
      topicId: widget.entry?.topicId ??
          widget.draft?.topicId ??
          widget.topicId ??
          '',
      createdBy: currentUserId,
    );

    await draftProvider.createDraft(draft);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _showSaveDraftDialog() async {
    if (_contentController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save as Draft?'),
        content: const Text('Would you like to save this entry as a draft?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      await _saveAsDraft();
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _submitEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // If this was a draft, delete it
      if (widget.draft != null) {
        final draftProvider =
            Provider.of<DraftEntryProvider>(context, listen: false);
        await draftProvider.deleteDraft(widget.draft!.id!);
      }

      // Return the result to the previous screen
      if (mounted) {
        // If we came from drafts screen, we need to pop twice to get back to entries screen
        if (widget.draft != null) {
          Navigator.pop(context); // Pop draft screen
          Navigator.pop(context); // Pop create entry screen
        }
        Navigator.pop(context, {
          'content': _contentController.text,
          'isEdit': widget.entry != null,
          'entryId': widget.entry?.id,
          'topicId':
              widget.topicId ?? widget.draft?.topicId ?? widget.entry?.topicId,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_contentController.text.isNotEmpty) {
          await _showSaveDraftDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(widget.entry != null ? 'Edit Entry' : 'Create Entry'),
          actions: [
            IconButton(
              icon: const Icon(Icons.drafts),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DraftEntriesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Entry Content',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      minLines: 5,
                      enabled: !_isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your entry content';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitEntry,
                      child: Text(widget.entry != null ? 'Update' : 'Submit'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _isLoading ? null : _saveAsDraft,
                      child: const Text('Save as Draft'),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withAlpha(77),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
