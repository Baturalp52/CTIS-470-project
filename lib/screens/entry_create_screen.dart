import 'package:flutter/material.dart';

class EntryCreateScreen extends StatefulWidget {
  const EntryCreateScreen({super.key});

  @override
  State<EntryCreateScreen> createState() => _EntryCreateScreenState();
}

class _EntryCreateScreenState extends State<EntryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _entryController = TextEditingController();

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _submitEntry() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _entryController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Add New Entry'),
        actions: [
          TextButton(
            onPressed: _submitEntry,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _entryController,
                decoration: const InputDecoration(
                  labelText: 'Your Entry',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                minLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your entry';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
