import 'package:flutter/material.dart';
import '../models/entry_model.dart';

class EntryCreateScreen extends StatefulWidget {
  final EntryModel? entry;

  const EntryCreateScreen({super.key, this.entry});

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
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _submitEntry() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Navigator.pop(context, {
        'content': _contentController.text,
        'isEdit': widget.entry != null,
        'entryId': widget.entry?.id,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.entry == null ? 'Add New Entry' : 'Edit Entry'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _isLoading ? null : _submitEntry,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
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
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
