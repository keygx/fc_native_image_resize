import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fc_native_image_resize_platform_interface.dart';

/// An implementation of [FcNativeImageResizePlatform] that uses method channels.
class MethodChannelFcNativeImageResize extends FcNativeImageResizePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fc_native_image_resize');

  @override
  Future<void> resizeFile(
      {required String srcFile,
      required String destFile,
      required int width,
      required int height,
      required bool keepAspectRatio,
      required String format,
      int? quality}) async {
    await methodChannel.invokeMethod<void>('resizeFile', {
      'srcFile': srcFile,
      'destFile': destFile,
      'width': width,
      'height': height,
      'keepAspectRatio': keepAspectRatio,
      'type': format,
      'quality': quality,
    });
  }

  @override
  Future<Uint8List> resizeData({
    required Uint8List data,
    required int width,
    required int height,
    required bool keepAspectRatio,
    required String format,
    int? quality,
  }) async {
    return await methodChannel.invokeMethod('resizeData', {
      'data': data,
      'width': width,
      'height': height,
      'keepAspectRatio': keepAspectRatio,
      'type': format,
      'quality': quality,
    });
  }
}
