import 'dart:async';
import 'dart:io';

import 'package:fc_native_image_resize/fc_native_image_resize.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:tmp_path/tmp_path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _destImg;
  String? _err;
  String _imgSizeInfo = '';
  final _nativeImgUtilPlugin = FcNativeImageResize();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: _destImg == null
              ? Text(_err != null
                  ? _err!
                  : 'Click on the + button to select a photo')
              : Column(
                  children: [
                    SelectableText(_destImg!),
                    Text(_imgSizeInfo),
                    Image(image: FileImage(File(_destImg!)))
                  ],
                ),
        ),
        floatingActionButton: FloatingActionButton(
          // onPressed: _resizeImageFile,
          onPressed: _resizeImageData,
          tooltip: 'Select an image',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _resizeImageFile() async {
    try {
      var result = await FilePicker.platform.pickFiles();
      if (result == null) {
        return;
      }
      var src = result.files.single.path!;
      var dest = tmpPath() + p.extension(src);
      setState(() {
        _err = null;
      });
      await _nativeImgUtilPlugin.resizeFile(
          srcFile: src,
          destFile: dest,
          width: 300,
          height: 300,
          keepAspectRatio: true,
          format: 'jpeg');
      var imageFile = File(dest);
      var decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
      setState(() {
        _destImg = dest;
        _imgSizeInfo =
            'Decoded size: ${decodedImage.width}x${decodedImage.height}';
      });
    } catch (err) {
      setState(() {
        _destImg = null;
        _err = err.toString();
      });
    }
  }

  Future<void> _resizeImageData() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null) {
        return;
      }
      final src = result.files.single.path!;
      final dest = tmpPath() + p.extension(src);
      setState(() {
        _err = null;
      });
      final scrImageFile = File(src);
      final bytes = scrImageFile.readAsBytesSync();

      final resized = await _nativeImgUtilPlugin.resizeData(
          data: bytes,
          width: 300,
          height: 300,
          keepAspectRatio: true,
          format: 'png');

      final dstImageFile = File(dest);
      await dstImageFile.writeAsBytes(resized.toList());
      final decodedImage =
          await decodeImageFromList(dstImageFile.readAsBytesSync());

      setState(() {
        _destImg = dest;
        _imgSizeInfo =
            'Decoded size: ${decodedImage.width}x${decodedImage.height}';
      });
    } catch (err) {
      setState(() {
        _destImg = null;
        _err = err.toString();
      });
    }
  }
}
