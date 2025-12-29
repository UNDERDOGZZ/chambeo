import 'package:flutter/material.dart';

class JobRoomScreen extends StatelessWidget {
  const JobRoomScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Job Room: $jobId'),
      ),
    );
  }
}
