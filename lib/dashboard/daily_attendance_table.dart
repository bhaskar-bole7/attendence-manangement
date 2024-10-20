import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DailyAttendanceTable extends StatelessWidget {
  final String classId;
  final String subjectId;
  final int year;
  final int month;

  DailyAttendanceTable(
      {required this.classId,
      required this.subjectId,
      required this.year,
      required this.month});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Map<String, bool>>>(
      future: getDailyAttendance(classId, subjectId, year, month),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No attendance data available.');
        }

        Map<String, Map<String, bool>> attendanceData = snapshot.data!;

        List<String> dates = List.generate(31, (index) {
          String date =
              '${year}${month.toString().padLeft(2, '0')}${(index + 1).toString().padLeft(2, '0')}'; // YYYYMMDD format
          return date;
        }).where((date) => DateTime.tryParse(date) != null).toList();

        List<DataRow> rows = attendanceData.entries.map((entry) {
          String studentId = entry.key;
          Map<String, bool> studentAttendance = entry.value;

          List<DataCell> cells = [
            DataCell(Text(studentId)),
          ];

          cells.addAll(dates.map((date) {
            bool isPresent = studentAttendance[date] ?? false;
            return DataCell(Text(isPresent ? 'Present' : 'Absent'));
          }).toList());

          return DataRow(cells: cells);
        }).toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Date / Student')),
              ...dates
                  .map((date) => DataColumn(label: Text(date.substring(6)))),
            ],
            rows: rows,
          ),
        );
      },
    );
  }

  Future<Map<String, Map<String, bool>>> getDailyAttendance(
      String classId, String subjectId, int year, int month) async {
    final attendanceCollection =
        FirebaseFirestore.instance.collection('attendance-sheet');

    // Query for attendance records in the specified class and subject for the specified month
    QuerySnapshot querySnapshot = await attendanceCollection
        .where('class', isEqualTo: classId)
        .where('subject', isEqualTo: subjectId)
        .where('dailyDate',
            isGreaterThanOrEqualTo:
                int.parse('$year$month' + '01')) // YYYYMMDD format
        .where('dailyDate',
            isLessThan:
                int.parse('$year$month' + '32')) // To get all days of the month
        .get();

    // Initialize a map to store attendance by student and date
    Map<String, Map<String, bool>> attendanceMap = {};

    // Iterate over the query results and populate the map
    for (var doc in querySnapshot.docs) {
      String studentId = doc['studentName'];
      int dailyDate = doc['dailyDate'];
      bool isPresent = doc['present'];

      // Extract the date as YYYYMMDD format
      String date = dailyDate.toString();
      String formattedDate =
          '${date.substring(0, 4)}${date.substring(4, 6)}${date.substring(6, 8)}'; // YYYYMMDD

      // Initialize student entry if not present
      if (!attendanceMap.containsKey(studentId)) {
        attendanceMap[studentId] = {};
      }

      // Store the attendance status (present or absent)
      attendanceMap[studentId]![formattedDate] = isPresent;
    }

    return attendanceMap; // Map of studentId -> (Map of date -> present status)
  }
}
