import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrTextService {
  Future<String> recognizeTextFromImagePath(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } finally {
      await textRecognizer.close();
    }
  }
}
