import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    return await _picker.pickImage(source: source);
  }
}