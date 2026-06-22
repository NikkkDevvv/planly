import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // Added for rootBundle
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FaceService {
  Interpreter? _interpreter;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: false,
      enableLandmarks: false,
      enableTracking: false,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  FaceDetector get faceDetector => _faceDetector;
  bool _isModelLoaded = false;

  FaceService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // Fallback 1: Try standard 'models/mobilefacenet.tflite' (tflite_flutter prepends 'assets/')
      _interpreter = await Interpreter.fromAsset('models/mobilefacenet.tflite');
      _isModelLoaded = true;
      debugPrint('TFLite model loaded successfully from models/mobilefacenet.tflite');
    } catch (e) {
      debugPrint('Failed to load from models/mobilefacenet.tflite: $e');
      try {
        // Fallback 2: Try original path 'assets/models/mobilefacenet.tflite'
        _interpreter = await Interpreter.fromAsset('assets/models/mobilefacenet.tflite');
        _isModelLoaded = true;
        debugPrint('TFLite model loaded successfully from assets/models/mobilefacenet.tflite');
      } catch (e2) {
        debugPrint('Failed to load from assets/models/mobilefacenet.tflite: $e2');
        try {
          // Fallback 3: Load via rootBundle and copy to system temp directory to load via fromFile
          final byteData = await rootBundle.load('assets/models/mobilefacenet.tflite');
          final file = File('${Directory.systemTemp.path}/mobilefacenet.tflite');
          await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
          _interpreter = Interpreter.fromFile(file);
          _isModelLoaded = true;
          debugPrint('TFLite model loaded successfully from system temp directory fallback');
        } catch (e3) {
          debugPrint('All TFLite model loading strategies failed: $e3');
        }
      }
    }
  }

  void dispose() {
    _faceDetector.close();
    _interpreter?.close();
  }

  /// Memotong wajah dari gambar dan melakukan kompresi ke 112x112
  img.Image? _cropFace(img.Image image, Face face) {
    final x = face.boundingBox.left.toInt().clamp(0, image.width);
    final y = face.boundingBox.top.toInt().clamp(0, image.height);
    final w = face.boundingBox.width.toInt().clamp(0, image.width - x);
    final h = face.boundingBox.height.toInt().clamp(0, image.height - y);
    
    if (w <= 0 || h <= 0) return null;

    img.Image cropped = img.copyCrop(image, x: x, y: y, width: w, height: h);
    return img.copyResize(cropped, width: 112, height: 112);
  }

  /// Ekstraksi descriptor 192-float dari gambar menggunakan TFLite MobileFaceNet
  Future<List<double>> extractFaceDescriptor(String imagePath) async {
    if (!_isModelLoaded || _interpreter == null) {
      await _loadModel();
      if (!_isModelLoaded) throw Exception('TFLite model not loaded');
    }

    // Load image
    final bytes = await File(imagePath).readAsBytes();
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) throw Exception('Failed to decode image');

    // Detect face
    final inputImage = InputImage.fromFilePath(imagePath);
    final faces = await _faceDetector.processImage(inputImage);
    if (faces.isEmpty) throw Exception('No face detected');

    // Crop to face
    final faceImg = _cropFace(originalImage, faces.first);
    if (faceImg == null) throw Exception('Failed to crop face');

    // Pre-process: normalize to [-1, 1] as expected by MobileFaceNet
    var input = List.generate(1, (i) => List.generate(112, (y) => List.generate(112, (x) => List.filled(3, 0.0))));
    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        final pixel = faceImg.getPixel(x, y);
        input[0][y][x][0] = (pixel.r - 127.5) / 128.0;
        input[0][y][x][1] = (pixel.g - 127.5) / 128.0;
        input[0][y][x][2] = (pixel.b - 127.5) / 128.0;
      }
    }

    // Inference (output is [1, 192])
    var output = List.generate(1, (i) => List.filled(192, 0.0));
    _interpreter!.run(input, output);

    // L2 Normalize the vector
    List<double> descriptor = output[0];
    double sum = 0.0;
    for (var val in descriptor) {
      sum += val * val;
    }
    double norm = sqrt(sum);
    if (norm > 0) {
      for (int i = 0; i < descriptor.length; i++) {
        descriptor[i] /= norm;
      }
    }

    return descriptor;
  }

  /// Mendeteksi apakah ada wajah dalam file gambar
  Future<bool> detectFace(String filePath) async {
    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      return faces.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
