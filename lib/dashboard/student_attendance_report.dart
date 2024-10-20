import 'package:attendence_app/dashboard/student_daily_attendance_table.dart';
import 'package:flutter/material.dart';

class StudentAttendanceReport extends StatefulWidget {
  final String? classId;
  final String? studentId;
  const StudentAttendanceReport(
      {required this.classId, required this.studentId});

  @override
  State<StudentAttendanceReport> createState() => _StudentAttendanceReportState(
        classId: classId!,
        studentId: studentId!,
      );
}

class _StudentAttendanceReportState extends State<StudentAttendanceReport> {
  final String classId;
  final String studentId;

  int _selectedView = 0;

  _StudentAttendanceReportState({
    required this.classId,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: Text(
          "Student Attendance Daily View",
          style: TextStyle(
              color: Color(0xFF081A52),
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Daily View',
                style: TextStyle(
                    color: Color(0xFF081A52),
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 15),
            StudentDailyAttendanceTable(
                classId: classId, studentId: studentId, year: 2024, month: 10)
          ],
        ),
      ),
    );
  }
}
