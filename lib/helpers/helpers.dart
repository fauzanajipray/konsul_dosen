import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

String formatTimestampToTime(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return DateFormat('HH:mm').format(dateTime);
}

Future<File?> getImage(
    BuildContext context, ImageSource imageSource, ImagePicker picker) async {
  try {
    var permission = PermissionStatus.granted;
    if (Platform.isAndroid) {
      if (imageSource == ImageSource.camera) {
        permission = await requestCameraPermissions(context);
      }
    }
    XFile? imageFile;
    if (permission.isGranted) {
      imageFile = await picker.pickImage(source: imageSource, imageQuality: 80);
      if (imageFile != null) {
        if (!context.mounted) return null;
        CroppedFile? croppedImage = await cropImage(context, imageFile);
        if (croppedImage != null) {
          return File(croppedImage.path);
        }
      } else {
        print('Image null');
      }
    } else {
      print('Something went wrong! , $permission');
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    if (!context.mounted) return null;
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Allow access to gallery and photos'),
          actions: [
            CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop()),
            CupertinoDialogAction(
                onPressed: () => openAppSettings(),
                isDefaultAction: true,
                child: const Text('Settings')),
          ],
        ),
      );
    }
  }
  return null;
}

Future<CroppedFile?> cropImage(BuildContext context, XFile file) async {
  if (!context.mounted) return null; // Check if the widget is still mounted
  final localContext = context; // Store the context locally
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: file.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressFormat: ImageCompressFormat.png,
    maxWidth: 800,
    maxHeight: 800,
    compressQuality: 80,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop the image',
        toolbarColor: Theme.of(localContext).colorScheme.primary,
        toolbarWidgetColor: Theme.of(localContext).colorScheme.onPrimary,
      ),
      IOSUiSettings(
        title: 'Crop the image',
        aspectRatioPickerButtonHidden: true,
        resetButtonHidden: true,
        aspectRatioLockDimensionSwapEnabled: true,
        aspectRatioLockEnabled: true,
      ),
      WebUiSettings(
        context: localContext,
      ),
    ],
  );

  if (!context.mounted) return null; // Check again after the async operation

  return croppedFile;
}

Future<PermissionStatus> requestCameraPermissions(BuildContext context) async {
  final status = await Permission.camera.request();
  if (status.isPermanentlyDenied || status.isDenied) {
    if (context.mounted) {
      showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Permission Required"),
            content: const Text(
                "To use this feature, please enable the camera permission in your device's settings."),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  openAppSettings(); // Open app settings
                },
              ),
            ],
          );
        },
      );
    }
  }
  return status;
}
