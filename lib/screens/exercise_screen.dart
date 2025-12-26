import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../main.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  late CameraController _cameraController;
  late PoseDetector _poseDetector;

  bool isDown = false;
  bool _isProcessing = false;
  int repetitions = 0;

  @override
  void initState() {
    super.initState();

    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(),
    );

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _cameraController.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _cameraController.startImageStream(_processCameraImage);
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    // ✅ MODERNE Lösung: Bytes direkt zusammenführen
    final Uint8List bytes = _concatenatePlanes(image.planes);

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );

    final poses = await _poseDetector.processImage(inputImage);

    if (poses.isNotEmpty) {
      _analyzePose(poses.first);
    }

    _isProcessing = false;
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final List<int> allBytes = <int>[];
    for (final Plane plane in planes) {
      allBytes.addAll(plane.bytes);
    }
    return Uint8List.fromList(allBytes);
  }

  void _analyzePose(Pose pose) {
    final hip = pose.landmarks[PoseLandmarkType.leftHip];
    final knee = pose.landmarks[PoseLandmarkType.leftKnee];
    final ankle = pose.landmarks[PoseLandmarkType.leftAnkle];

    if (hip == null || knee == null || ankle == null) return;

    final angle = _calculateAngle(hip, knee, ankle);

    if (angle < 90 && !isDown) {
      isDown = true;
    }

    if (angle > 160 && isDown) {
      setState(() {
        repetitions++;
      });
      isDown = false;
    }
  }

  double _calculateAngle(
    PoseLandmark a,
    PoseLandmark b,
    PoseLandmark c,
  ) {
    final ab = Offset(a.x - b.x, a.y - b.y);
    final cb = Offset(c.x - b.x, c.y - b.y);

    final dot = ab.dx * cb.dx + ab.dy * cb.dy;
    final magAB = ab.distance;
    final magCB = cb.distance;

    return acos(dot / (magAB * magCB)) * (180 / pi);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Squats erkennen'),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _cameraController.value.aspectRatio,
            child: CameraPreview(_cameraController),
          ),
          const SizedBox(height: 16),
          Text(
            'Wiederholungen',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Text(
            '$repetitions',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      ),
    );
  }
}
