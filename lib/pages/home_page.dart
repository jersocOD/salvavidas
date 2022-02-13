// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:report_child/controllers/geolocator.dart';
import 'package:report_child/models/case_model.dart';
import 'package:report_child/pages/form_send_page.dart';
import 'package:report_child/widgets/bottom_light_button.dart';
import 'package:report_child/widgets/bottom_open_file_button.dart';
import 'package:report_child/widgets/record_button.dart';
import 'package:report_child/widgets/timer.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as VidThumb;

Function? disposeCamera;
Function? reinitCamera;
CameraDescription? currentCamera;
bool cameraIsDisposed = false;
typedef positionStreamListener = void Function(Position? position);
positionStreamListener? onPositionChanged;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

void logError(String code, String? message) {
  if (message != null) {
    debugPrint('Error: $code\nError Message: $message');
  } else {
    debugPrint('Error: $code');
  }
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  CameraController? controller;
  late AnimationController _flashModeControlRowAnimationController;
  late GeolocalizationManager geolocalizationManager;
  late AnimationController _exposureModeControlRowAnimationController;
  late AnimationController _focusModeControlRowAnimationController;
  late TimerController timerController;
/*   double locationLatitude = 0.0;
  double locationLongitude = 0.0; */

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  bool nocamera = false;

  CameraDescription? getCamera() {
    if (cameras.length == 1) return cameras[0];

    for (var cameraDesc in cameras) {
      if (cameraDesc.lensDirection == CameraLensDirection.back) {
        return cameraDesc;
      }
    }
    for (var cameraDesc in cameras) {
      if (cameraDesc.lensDirection == CameraLensDirection.external) {
        return cameraDesc;
      }
    }
    if (cameras.isEmpty) {
      return null;
    }
    return cameras[0];
  }

  @override
  void initState() {
    super.initState();
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    timerController = TimerController(this);
/* 
    onPositionChanged = (position) {
      if (position == null) {
        showInSnackBar(
            "Error al obtener localización. Por favor, intente más tarde.");
        return;
      }
      locationLatitude = position.latitude;
      locationLongitude = position.longitude;

      Provider.of<CaseModel>(this.context, listen: false).position = position;
      if (mounted) setState(() {});
    }; */
    geolocalizationManager = GeolocalizationManager();
    geolocalizationManager.initGeolocator().then((success) {
      if (success) {
        geolocalizationManager.getCurrentLocation(context);
        if (mounted) setState(() {});
        /*  geolocalizationManager.startStreaming(onPositionChanged!); */
      }
    });

    if (controller != null && controller!.value.isRecordingVideo) {
    } else {
      var camera = getCamera();
      if (camera != null) {
        onNewCameraSelected(camera);
      }
      disposeCamera = controller!.dispose;
      reinitCamera = onNewCameraSelected;
      currentCamera = camera;
    }
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    timerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(controller!.description);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final pos = Provider.of<CaseModel>(context).position;

    final CameraController? cameraController = controller;
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _cameraPreviewWidget(),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 40,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Text(
                        "Lat: ${pos!.latitude}, Long: ${pos.longitude}",
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: VideoTimer(
                      timerController: timerController,
                      duration: const Duration(seconds: 30),
                    ),
                  ),
                ],
              ),
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: 95,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      translate('HomePage.OrientationMessage'),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  color: Colors.black.withOpacity(0.6),
                ),
                Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: RecordButton(
              startRecording: cameraController != null &&
                      cameraController.value.isInitialized &&
                      !cameraController.value.isRecordingVideo
                  ? onVideoRecordButtonPressed
                  : () {},
              stopRecording: cameraController != null &&
                      cameraController.value.isInitialized &&
                      cameraController.value.isRecordingVideo
                  ? onStopButtonPressed
                  : () {},
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: BottomLightButton(
                turnOn: controller != null
                    ? () => onSetFlashModeButtonPressed(FlashMode.torch)
                    : () {},
                turnOff: controller != null
                    ? () => onSetFlashModeButtonPressed(FlashMode.off)
                    : () {}),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: BottomOpenFileButton(
              goToForm: goToForm,
            ),
          ),

          /*  _captureControlRowWidget(), */
          /*  _modeControlRowWidget(), */
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;
    if (cameras.isEmpty) {
      return const Text(
        'No Camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else if (cameraController == null ||
        !cameraController.value.isInitialized) {
      return Container();
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
/*           child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onTapDown: (details) => onViewFinderTap(details, constraints),
            );
          }), */
        ),
      );
    }
  }

/* 
  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }
 */
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    controller = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // If the controller is updated then update the UI.
    controller!.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        showInSnackBar('Camera error ${controller!.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
      await Future.wait([
        // The exposure mode is currently not supported on the web.

        controller!
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        controller!
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) setState(() {});
      /* showInSnackBar('Flash mode set to ${mode.toString().split('.').last}'); */
    });
  }

  Future<void> onVideoRecordButtonPressed() async {
    startVideoRecording();
    timerController.start();
    if (mounted) setState(() {});

    await Future.delayed(const Duration(seconds: 30));
    timerController.stop();
    onStopButtonPressed();
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((file) async {
      if (mounted) setState(() {});
      if (file != null) {
        // showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        //_startVideoPlayer();

        Provider.of<CaseModel>(context, listen: false).videoPath = file.path;
        Provider.of<CaseModel>(context, listen: false).videoBytes =
            await file.readAsBytes();
        Provider.of<CaseModel>(context, listen: false).videoThumbnailBytes =
            await VidThumb.VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: VidThumb.ImageFormat.JPEG,
          maxWidth: MediaQuery.of(context).size.width.truncate(),
          quality: 100,
        );
        goToForm();
      }
    });
  }

  Future<void> goToForm() async {
    timerController.pause();
    await geolocalizationManager.getCurrentLocation(context);

    //await disposeCamera!();
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => FormSendPage()));

    //reinitCamera!(currentCamera);

    timerController.reset();
    if (mounted) setState(() {});
  }

  Future<void> onPausePreviewButtonPressed() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isPreviewPaused) {
      await cameraController.resumePreview();
    } else {
      await cameraController.pausePreview();
    }

    if (mounted) setState(() {});
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      // showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      // showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await cameraController.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

List<CameraDescription> cameras = [];

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
// TODO(ianh): Remove this once we roll stable in late 2021.
T? _ambiguate<T>(T? value) => value;
