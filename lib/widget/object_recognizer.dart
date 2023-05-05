import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';

import 'object_preview.dart';
import '../classifier/classifier.dart';

import '../styles.dart';

const _labelsFileName = 'assets/labels.txt';
const _modelFileName = 'model_unquant.tflite';

class ObjectRecognizer extends StatefulWidget {
  const ObjectRecognizer({super.key});

  @override
  State<ObjectRecognizer> createState() => _ObjectRecognizerState();
}

enum _ResultStatus {
  notStarted,
  notFound,
  found,
}

class _ObjectRecognizerState extends State<ObjectRecognizer> {
  bool _isAnalyzing = false;
  final picker = ImagePicker();
  File? _selectedImageFile;

  _ResultStatus _resultStatus = _ResultStatus.notStarted;
  String _objectLabel = '';
  double _accuracy = 0.0;
  String _takeWith = '';

  late Classifier? _classifier;

  @override
  void initState() {
    super.initState();
    _loadClassifier();
  }

  Future<void> _loadClassifier() async {
    debugPrint(
      'Start loading of Classifier with '
      'labels at $_labelsFileName, '
      'model at $_modelFileName',
    );

    final classifier = await Classifier.loadWith(
      labelsFileName: _labelsFileName,
      modelFileName: _modelFileName,
    );

    _classifier = classifier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picang - Aplikasi Pendeteksi Buah Pisang'),
        backgroundColor: kColorYellow,
      ),
      body: Container(
        color: kColorDarkerWhite,
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Spacer(),
            const SizedBox(height: 20),
            _buildImagePreview(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildResultView(),
            ),
            const Spacer(flex: 5),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                _buildPickImageButton(
                  title: 'Galeri',
                  source: ImageSource.gallery,
                ),
                _buildPickImageButton(
                  title: 'Kamera',
                  source: ImageSource.camera,
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        ObjectPreview(file: _selectedImageFile),
      ],
    );
  }

  Widget _buildResultView() {
    var title = '';

    if (_resultStatus == _ResultStatus.notFound) {
      title = 'Gagal mengenali objek!';
    } else if (_resultStatus == _ResultStatus.found) {
      title = _objectLabel;
    } else {
      title = '';
    }

    var accuracyLabel = '';
    if (_resultStatus == _ResultStatus.found) {
      accuracyLabel = 'Akurasi: ${(_accuracy * 100).toStringAsFixed(2)}%';
    }

    var datetimeLabel = '';
    var date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    var time = DateFormat('hh:mm:ss a').format(DateTime.now());
    if (_resultStatus == _ResultStatus.found) {
      datetimeLabel = 'tanggal $date pukul $time';
    }

    return Column(
      children: [
        Text(title, style: kResultText),
        Text(accuracyLabel, style: kResultRating),
        const SizedBox(height: 20),
        Text(_takeWith, style: kResultDetail),
        Text(datetimeLabel, style: kResultDetail),
      ],
    );
  }

  Widget _buildPickImageButton({
    required String title,
    required ImageSource source,
  }) {
    return SizedBox(
      width: 132.0,
      height: 54.0,
      child: ElevatedButton(
        onPressed: () => _onPickImage(source),
        style: kPickImageButton,
        child: Text(title, style: kPickImageButtonText),
      ),
    );
  }

  void _onPickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      return;
    }

    final imageFile = File(pickedFile.path);

    if (source == ImageSource.camera) {
      GallerySaver.saveImage(imageFile.path);
      _takeWith = 'Diambil dengan Kamera';
    } else {
      _takeWith = 'Diambil dari Galeri';
    }

    setState(() {
      _selectedImageFile = imageFile;
    });

    _analyzeImage(imageFile);
  }

  void _setAnalyzing(bool flag) {
    setState(() {
      _isAnalyzing = flag;
    });
  }

  void _analyzeImage(File image) {
    _setAnalyzing(true);

    final imageInput = img.decodeImage(image.readAsBytesSync())!;
    final resultCategory = _classifier!.predict(imageInput);
    final result = resultCategory.score >= 0.8
      ? _ResultStatus.found
      : _ResultStatus.notFound;
    final objectLabel = resultCategory.label;
    final accuracy = resultCategory.score;

    _setAnalyzing(false);

    setState(() {
      _resultStatus = result;
      _objectLabel = objectLabel;
      _accuracy = accuracy;
    });
  }
}