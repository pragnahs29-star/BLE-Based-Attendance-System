import 'dart:io';
import 'dart:typed_data';

import 'package:face_detection_tflite/face_detection_tflite.dart';

class FaceService {
  late final FaceDetector _detector;

  Future<void> initialize() async {
    _detector = await FaceDetector.create();
  }

  Future<List<Face>> detectFaces(String imagePath) async {
    final Uint8List imageBytes = await File(imagePath).readAsBytes();

    final faces = await _detector.detectFacesFromBytes(
      imageBytes,
      mode: FaceDetectionMode.full,
    );

    return faces;
  }

  Future<Float32List> getFaceEmbedding({
    required Face face,
    required String imagePath,
  }) async {
    final Uint8List imageBytes = await File(imagePath).readAsBytes();

    final embedding = await _detector.getFaceEmbedding(
      face,
      imageBytes,
    );

    return embedding;
  }

  double compareEmbeddings({
    required Float32List enrolledEmbedding,
    required Float32List liveEmbedding,
  }) {
    return FaceDetector.compareFaces(
      enrolledEmbedding,
      liveEmbedding,
    );
  }

  void dispose() {
    _detector.dispose();
  }
}