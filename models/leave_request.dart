class LeaveRequest {
  final String id;
  final String teacherId;
  final String teacherName;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final DateTime requestDate;

  LeaveRequest({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = 'pending',
    required this.requestDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'reason': reason,
    'status': status,
    'requestDate': requestDate.toIso8601String(),
  };

  static LeaveRequest fromJson(Map<String, dynamic> json) => LeaveRequest(
    id: json['id'],
    teacherId: json['teacherId'],
    teacherName: json['teacherName'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    reason: json['reason'],
    status: json['status'],
    requestDate: DateTime.parse(json['requestDate']),
  );
}
