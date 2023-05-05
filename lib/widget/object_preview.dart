import 'dart:io';
import 'package:flutter/material.dart';

import '../styles.dart';

class ObjectPreview extends StatelessWidget {
  final File? file;
  const ObjectPreview({super.key, this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      color: kColorGrey,
      child: (file == null)
        ? _buildEmptyPreview()
        : Image.file(file!, fit: BoxFit.contain)
    );
  }

  Widget _buildEmptyPreview() {
    return const Center(
      child: Text(
        'Ambil pisangmu sekarang!',
        style: kEmptyPreviewText,
      ),
    );
  }
}