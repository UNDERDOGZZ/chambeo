import 'package:flutter/material.dart';

class JobOffersScreen extends StatelessWidget {
  const JobOffersScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Job Offers: $jobId'),
      ),
    );
  }
}
