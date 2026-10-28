import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceCheckScreen extends StatefulWidget {
  const FaceCheckScreen({super.key});

  @override
  State<FaceCheckScreen> createState() => _FaceCheckScreenState();
}

class _FaceCheckScreenState extends State<FaceCheckScreen> {
  final ImagePicker _picker = ImagePicker();
  late final FaceDetector _faceDetector;

  bool _isProcessing = false;
  bool _isFaceVerified = false;
  String _statusMessage = 'Tap Capture to verify your face';

  @override
  void initState() {
    super.initState();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: false,
        enableClassification: false,
        enableContours: false,
        enableTracking: false,
      ),
    );
  }

  Future<void> _captureAndVerify() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Opening camera...';
    });

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (photo == null) {
        if (!mounted) return;
        setState(() => _statusMessage = 'No photo captured');
        return;
      }

      if (!mounted) return;
      setState(() => _statusMessage = 'Checking face...');

      final inputImage = InputImage.fromFilePath(photo.path);
      final faces = await _faceDetector.processImage(inputImage);

      debugPrint('Photo path: ${photo.path}');
      debugPrint('Faces detected: ${faces.length}');

      if (!mounted) return;

      setState(() {
        if (faces.length == 1) {
          _isFaceVerified = true;
          _statusMessage = 'Face Verified Successfully!';
        } else if (faces.length > 1) {
          _isFaceVerified = false;
          _statusMessage = 'Multiple faces detected!';
        } else {
          _isFaceVerified = false;
          _statusMessage = 'No face detected. Try again.';
        }
      });
    } catch (e) {
      debugPrint('Face verification error: $e');

      if (!mounted) return;
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Verification')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isFaceVerified ? Colors.green : Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              if (_isProcessing)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _captureAndVerify,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Capture & Verify Face'),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isFaceVerified
                    ? () => Navigator.pop(context, true)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Complete Verification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}