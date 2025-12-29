import 'package:flutter/material.dart';

class JobOfferSendScreen extends StatelessWidget {
  const JobOfferSendScreen({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Send Offer: $jobId'),
      ),
    );
  }
}
