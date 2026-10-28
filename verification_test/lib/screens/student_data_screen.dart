import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/photo_upload_service.dart';

class StudentDataScreen extends StatefulWidget {
  const StudentDataScreen({super.key});

  @override
  State<StudentDataScreen> createState() => _StudentDataScreenState();
}

class _StudentDataScreenState extends State<StudentDataScreen> {
  final ImagePicker _picker = ImagePicker();
  final PhotoUploadService _photoUploadService = PhotoUploadService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();

  XFile? _selectedPhoto;
  bool _isUploading = false;
  String _statusMessage = 'Enter student details and upload photo';

  Future<void> _pickPhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (photo != null) {
      setState(() {
        _selectedPhoto = photo;
        _statusMessage = 'Photo selected. Ready to upload.';
      });
    }
  }

  Future<void> _uploadStudent() async {
    final name = _nameController.text.trim();
    final rollNumber = _rollNumberController.text.trim();

    if (name.isEmpty || rollNumber.isEmpty || _selectedPhoto == null) {
      setState(() {
        _statusMessage = 'Enter name, roll number, and capture a photo';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _statusMessage = 'Uploading student data...';
    });

    try {
      final photoFile = File(_selectedPhoto!.path);
      final photoUrl = await _photoUploadService.uploadPhoto(photoFile);

      await FirebaseFirestore.instance
          .collection('students')
          .doc(rollNumber)
          .set({
        'name': name,
        'rollNumber': rollNumber,
        'photoUrl': photoUrl,
        'faceEnrolled': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _statusMessage = 'Student $rollNumber uploaded successfully!';
        _selectedPhoto = null;
        _nameController.clear();
        _rollNumberController.clear();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _statusMessage = 'Upload failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _rollNumberController,
                decoration: const InputDecoration(
                  labelText: 'Roll Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickPhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Student Photo'),
              ),
              const SizedBox(height: 16),
              if (_selectedPhoto != null)
                Text('Photo captured: ${_selectedPhoto!.name}'),
              const SizedBox(height: 24),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (_isUploading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _uploadStudent,
                  child: const Text('Upload Student'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}