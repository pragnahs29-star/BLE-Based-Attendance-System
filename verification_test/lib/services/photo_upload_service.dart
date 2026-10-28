import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PhotoUploadService {
  // Replace YOUR_CLOUD_NAME with your real Cloudinary Cloud Name from Step 1
  final String cloudName = 'y8wu02nh';
  final String uploadPreset = 'attendance_photos';

  Future<String> uploadPhoto(File photoFile) async {
    final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          photoFile.path,
        ),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Upload failed: $responseBody');
    }

    final responseData = jsonDecode(responseBody);
    return responseData['secure_url'];
  }
}