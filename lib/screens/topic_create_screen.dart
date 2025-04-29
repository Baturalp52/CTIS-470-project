import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../models/topic_model.dart';
import '../providers/topic_provider.dart';

class TopicCreateScreen extends StatefulWidget {
  final TopicModel? topic;

  const TopicCreateScreen({super.key, this.topic});

  @override
  State<TopicCreateScreen> createState() => _TopicCreateScreenState();
}

class _TopicCreateScreenState extends State<TopicCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _imageBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.topic?.title);
    _descriptionController =
        TextEditingController(text: widget.topic?.description);
    _imageBase64 = widget.topic?.imageBase64;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);

        setState(() {
          _imageBase64 = base64String;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final topicProvider = Provider.of<TopicProvider>(context, listen: false);
      final title = _titleController.text;
      final description = _descriptionController.text;

      if (widget.topic != null) {
        // Update existing topic
        final success = await topicProvider.updateTopic(
          widget.topic!,
          title,
          description,
          imageBase64: _imageBase64,
        );
        if (success) {
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(topicProvider.error ?? 'Failed to update topic')),
            );
          }
        }
      } else {
        // Create new topic
        final success = await topicProvider.createTopic(
          title,
          description,
          imageBase64: _imageBase64,
        );
        if (success) {
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(topicProvider.error ?? 'Failed to create topic')),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.topic != null ? 'Edit Topic' : 'Create New Topic',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Topic Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_imageBase64 != null)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(_imageBase64!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.image),
                label:
                    Text(_imageBase64 != null ? 'Change Image' : 'Add Image'),
              ),
              const SizedBox(height: 24),
              Consumer<TopicProvider>(
                builder: (context, topicProvider, child) {
                  return ElevatedButton(
                    onPressed: topicProvider.isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: topicProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.topic != null
                                ? 'Update Topic'
                                : 'Create Topic',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
