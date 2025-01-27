import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacialRecognition {
  Future<void> detectFaces(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    XFile? image;

    // Determinar si usar cámara o selector de imágenes
    if (Platform.isWindows) {
      // Asumiendo que windowsCaptureImage() está implementado en algún lugar
      // image = await windowsCaptureImage();
      // Por ahora, usaremos el selector de imágenes para Windows
      image = await picker.pickImage(source: ImageSource.gallery);
    } else {
      image = await picker.pickImage(source: ImageSource.camera);
    }

    if (image != null) {
      String result = await _mobileFaceDetection(image);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Resultado de Detección Facial'),
          content: Text(result),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se seleccionó ninguna imagen')),
      );
    }
  }

  Future<String> _mobileFaceDetection(XFile image) async {
    // Convertir la imagen a InputImage para Google ML Kit
    final inputImage = InputImage.fromFilePath(image.path);
    final options = FaceDetectorOptions(
      enableLandmarks: true,
      enableContours: true,
      enableClassification: true,
    );
    final faceDetector = FaceDetector(options: options);
    final List<Face> faces = await faceDetector.processImage(inputImage);
    String result = '';

    if (faces.isEmpty) {
      result = 'No se han detectado rostros en la imagen.';
    } else {
      for (Face face in faces) {
        result += 'Rostro detectado en: ${face.boundingBox}\n';
        if (face.smilingProbability != null) {
          result += 'Probabilidad de sonrisa: ${face.smilingProbability!.toStringAsFixed(2)}\n';
        }
        if (face.leftEyeOpenProbability != null && face.rightEyeOpenProbability != null) {
          result += 'Ojo izquierdo: ${face.leftEyeOpenProbability!.toStringAsFixed(2)}, Ojo derecho: ${face.rightEyeOpenProbability!.toStringAsFixed(2)}\n';
        }
        result += '\n';
      }
    }

    await faceDetector.close();
    return result;
  }
}














