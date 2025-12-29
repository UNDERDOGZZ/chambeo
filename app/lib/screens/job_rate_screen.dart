import 'package:flutter/material.dart';

class JobRateScreen extends StatelessWidget {
  const JobRateScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Job Rate: $jobId'),
      ),
    );
  }
}
