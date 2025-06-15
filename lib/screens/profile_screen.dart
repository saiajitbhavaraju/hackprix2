import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:ecosnap_1/services/snap_state_service.dart'; // Import your service

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // We no longer need to store the score in state variables here,
  // as we will read it directly from the service in the build method.

  @override
  Widget build(BuildContext context) {
    // ** THIS IS THE FIX **
    // Get the latest score directly from the central service every time the screen builds.
    // This ensures the UI is always in sync with the data in shared_preferences.
    final int actions = SnapStateService.instance.ecoActionsCount;
    final int maxActions = SnapStateService.instance.maxEcoActions;
    final int points = actions; // 1 point per action
    final double overallProgress = (maxActions == 0) ? 0 : (actions / maxActions);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Eco Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 10)
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 12.0,
                      percent: overallProgress,
                      center: Text("${(overallProgress * 100).toInt()}%",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      progressColor: Colors.green.shade600,
                      backgroundColor: Colors.grey.shade300,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Eco Actions",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800)),
                        const SizedBox(height: 8),
                        Text("Total Score: $points pts",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade700)),
                        const SizedBox(height: 4),
                        Text("Goal: $actions/$maxActions",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // The Rive animation has been removed to focus on the core logic.
              const Text("Your Plant's Growth",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                    color: Colors.lightBlue.shade50,
                    borderRadius: BorderRadius.circular(20)),
                child: const Center(
                  child: Text(
                    'Plant animation will be here!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
