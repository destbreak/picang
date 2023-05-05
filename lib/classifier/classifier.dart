import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'classifier_category.dart';
import 'classifier_model.dart';

typedef ClassifierLabels = List<String>;

class Classifier {
  final ClassifierLabels _labels;
  final ClassifierModel _model;

  Classifier._({
    required ClassifierLabels labels,
    required ClassifierModel model,
  })
  : _labels = labels,
    _model = model;

  static Future<Classifier?> loadWith({
    required String labelsFileName,
    required String modelFileName,
  }) async {
    try {
      final labels = await _loadLabels(labelsFileName);
      final model = await _loadModel(modelFileName);

      return Classifier._(labels: labels, model: model);
    } catch (e) {
      debugPrint('Can\'t initialize Classifier: ${e.toString()}');

      if (e is Error) {
        debugPrintStack(stackTrace: e.stackTrace);
      }

      return null;
    }
  }

  static Future<ClassifierLabels> _loadLabels(String labelsFileName) async {
    final rawLabels = await FileUtil.loadLabels(labelsFileName);
    final labels = rawLabels
      .map((label) => label.substring(label.indexOf(' ')).trim())
      .toList();
    debugPrint('Labels: $labels');

    return labels;
  }

  static Future<ClassifierModel> _loadModel(String modelFileName) async {
    final interpreter = await Interpreter.fromAsset(modelFileName);

    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;
    debugPrint('Input shape: $inputShape');
    debugPrint('Output shape: $outputShape');

    final inputType = interpreter.getInputTensor(0).type;
    final outputType = interpreter.getOutputTensor(0).type;
    debugPrint('Input type: $inputType');
    debugPrint('Output type: $outputType');

    return ClassifierModel(
      interpreter: interpreter,
      inputShape: inputShape,
      outputShape: outputShape,
      inputType: inputType,
      outputType: outputType,
    );
  }

  void close() {
    _model.interpreter.close();
  }

  ClassifierCategory predict(Image image) {
    debugPrint(
      'Image: ${image.width}x${image.height}, '
      'size: ${image.length} bytes',
    );

    final inputImage = _preProcessInput(image);
    debugPrint(
      'Pre-processed image: ${inputImage.width}x${inputImage.height}, '
      'size: ${inputImage.buffer.lengthInBytes} bytes',
    );

    final outputBuffer = TensorBuffer.createFixedSize(
      _model.outputShape,
      _model.outputType,
    );

    _model.interpreter.run(inputImage.buffer, outputBuffer.buffer);
    debugPrint('Output Buffer: ${outputBuffer.getDoubleList()}');

    final resultCategories = _postProcessOutput(outputBuffer);
    final topResult = resultCategories.first;
    debugPrint('Top category: $topResult');

    return topResult;
  }

  TensorImage _preProcessInput(Image image) {
    final inputTensor = TensorImage(_model.inputType);
    inputTensor.loadImage(image);

    final minLength = min(inputTensor.height, inputTensor.width);
    final cropOp = ResizeWithCropOrPadOp(minLength, minLength);

    final shapeLength = _model.inputShape[1];
    final resizeOp = ResizeOp(shapeLength, shapeLength, ResizeMethod.BILINEAR);

    final normalizeOp = NormalizeOp(127.5, 127.5);

    final imageProcessor = ImageProcessorBuilder()
      .add(cropOp)
      .add(resizeOp)
      .add(normalizeOp)
      .build();

    imageProcessor.process(inputTensor);

    return inputTensor;
  }

  List<ClassifierCategory> _postProcessOutput(TensorBuffer outputBuffer) {
    final probabilityProcessor = TensorProcessorBuilder().build();
    probabilityProcessor.process(outputBuffer);

    final labelledResult = TensorLabel.fromList(_labels, outputBuffer);
    final categoryList = <ClassifierCategory>[];

    labelledResult.getMapWithFloatValue().forEach((key, value) {
      final category = ClassifierCategory(key, value);

      categoryList.add(category);
      debugPrint('label: ${category.label}, score: ${category.score}');
    });

    categoryList.sort((a, b) => (b.score > a.score ? 1 : -1));

    return categoryList;
  }
}