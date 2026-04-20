import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/incident_model.dart';
import '../../services/storage_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/custom_inputs.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class CreateIncidentScreen extends ConsumerStatefulWidget {
  const CreateIncidentScreen({super.key});

  @override
  ConsumerState<CreateIncidentScreen> createState() => _CreateIncidentScreenState();
}

class _CreateIncidentScreenState extends ConsumerState<CreateIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  IncidentPriority _priority = IncidentPriority.medium;
  IncidentType _type = IncidentType.security;
  File? _image;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await ref.read(storageServiceProvider).uploadIncidentImage(_image!);
      }

      final userId = ref.read(authServiceProvider).currentUser?.uid ?? 'unknown';

      final incident = IncidentModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _priority,
        type: _type,
        location: _locationController.text.trim(),
        imageUrl: imageUrl,
        createdBy: userId,
        createdAt: DateTime.now(),
        status: IncidentStatus.open,
      );

      await ref.read(firestoreServiceProvider).createIncident(incident);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incident reported successfully!'), backgroundColor: Colors.green),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descController.clear();
    _locationController.clear();
    setState(() {
      _image = null;
      _priority = IncidentPriority.medium;
      _type = IncidentType.security;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Color _getPriorityColor(IncidentPriority p) {
    switch (p) {
      case IncidentPriority.critical:
        return Colors.red[900]!;
      case IncidentPriority.high:
        return Colors.red;
      case IncidentPriority.medium:
        return Colors.orange;
      case IncidentPriority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Title',
                controller: _titleController,
                prefixIcon: Icons.title,
                validator: (val) => val == null || val.isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Description',
                controller: _descController,
                maxLines: 3,
                prefixIcon: Icons.description_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Description required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Location',
                controller: _locationController,
                prefixIcon: Icons.map_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Location required' : null,
              ),
              const SizedBox(height: 24),
              const Text('Incident Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: IncidentType.values.where((t) => t != IncidentType.sos).map((t) {
                  return ChoiceChip(
                    label: Text(t.name.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    selected: _type == t,
                    onSelected: (val) => setState(() => _type = t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: IncidentPriority.values.map((p) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            p.name.toUpperCase(), 
                            style: TextStyle(
                              fontSize: 10, 
                              color: _priority == p ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        selected: _priority == p,
                        selectedColor: _getPriorityColor(p),
                        onSelected: (val) => setState(() => _priority = p),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Attachment', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Add an image', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'REPORT INCIDENT',
                isLoading: _isUploading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
