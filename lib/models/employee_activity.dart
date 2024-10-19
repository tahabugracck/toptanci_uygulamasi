class EmployeeActivity {
  final String employeeName;
  final String activityType;
  final DateTime activityDate;
  final int duration; // in minutes

  EmployeeActivity({
    required this.employeeName,
    required this.activityType,
    required this.activityDate,
    required this.duration,
  });
}
