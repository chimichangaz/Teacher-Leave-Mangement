// lib/screens/teacher_profile_screen.dart
import 'package:flutter/material.dart';
import '../models/teacher.dart';

class TeacherProfileScreen extends StatefulWidget {
  final Teacher teacher;

  const TeacherProfileScreen({
    Key? key,
    required this.teacher,
  }) : super(key: key);

  @override
  _TeacherProfileScreenState createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${widget.teacher.name}'),
            SizedBox(height: 8),
            Text('Email: ${widget.teacher.email}'),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leave Balance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text('Total Leaves: ${widget.teacher.totalLeaves}'),
                    Text('Used Leaves: ${widget.teacher.usedLeaves}'),
                    Text(
                      'Remaining Leaves: ${widget.teacher.totalLeaves - widget.teacher.usedLeaves}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to leave request screen
          // Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveRequestScreen()));
        },
        child: Icon(Icons.add),
        tooltip: 'Request Leave',
      ),
    );
  }
}