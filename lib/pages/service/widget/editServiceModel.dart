import 'package:admin_panel/api_calls/models/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEditServicePage extends StatefulWidget {
  final bool isEditing;
  final ServiceModel? service;
  final Function(String name, String offerto, XFile? imageFile) onSave;
  
  const AddEditServicePage({
    super.key,
    this.isEditing = false,
    this.service,
    required this.onSave,
  });
  
  @override
  State<AddEditServicePage> createState() => _AddEditServicePageState();
}

class _AddEditServicePageState extends State<AddEditServicePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _offertoController;
  XFile? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _offertoController = TextEditingController(text: widget.service?.offerto ?? '');
    _existingImageUrl = widget.service?.imageUrl;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _offertoController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }
  
  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await widget.onSave(
          _nameController.text.trim(),
          _offertoController.text.trim(), // Now accepts format like "30-40%"
          _selectedImage,
        );
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEditing ? 'Service updated successfully' : 'Service added successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Service' : 'Add Service'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImagePlaceholder();
                                  },
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildImagePlaceholder();
                                  },
                                ),
                        )
                      : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _existingImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildImagePlaceholder();
                                },
                              ),
                            )
                          : _buildImagePlaceholder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build),
                  hintText: 'e.g., Speaker Service, Screen Repair',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Offer field - Updated for range format like "30-40%"
              TextFormField(
                controller: _offertoController,
                decoration: const InputDecoration(
                  labelText: 'Offer Range',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                  suffixText: '%',
                  hintText: 'e.g., 30-40, 50-60',
                  helperText: 'Enter offer range as min-max (e.g., 30-40)',
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter offer range';
                  }
                  
                  // Validate format: should be like "30-40" or "30-40%"
                  String trimmed = value.trim().replaceAll('%', '');
                  final RegExp rangeRegex = RegExp(r'^\d+-\d+$');
                  
                  if (!rangeRegex.hasMatch(trimmed)) {
                    return 'Please enter valid format: min-max (e.g., 30-40)';
                  }
                  
                  // Validate that min <= max
                  final parts = trimmed.split('-');
                  final min = int.parse(parts[0]);
                  final max = int.parse(parts[1]);
                  
                  if (min >= max) {
                    return 'Minimum value should be less than maximum value';
                  }
                  
                  if (min < 0 || max > 100) {
                    return 'Values should be between 0 and 100';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.isEditing ? 'Update Service' : 'Add Service'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildImagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Tap to select image'),
        ],
      ),
    );
  }
}