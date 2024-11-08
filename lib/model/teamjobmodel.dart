class Teamjobmodel {
  final String jobId;
  final String name;
  final String status;
  final String details;
  final DateTime startDate;
  final DateTime lastDate;
  final DateTime startTime;
  final DateTime lastTime;
  final String headUserID;
  final List<String> workByUserID;

  Teamjobmodel({
    required this.jobId,
    required this.name,
    required this.status,
    required this.details,
    required this.startDate,
    required this.lastDate,
    required this.startTime,
    required this.lastTime,
    required this.headUserID,
    required this.workByUserID,
  });

  factory Teamjobmodel.fromJson(Map<String, dynamic> json) {
    final startDateJson = json['StartDate'];
    final lastDateJson = json['LastDate'];
    final startTimeJson = json['StartTime'];
    final lastTimeJson = json['LastTime'];

    return Teamjobmodel(
      jobId: json['JobID'] ?? '',
      name: json['Name'] ?? '',
      status: json['Status'] ?? '',
      details: json['Details'] ?? '',
      startDate: DateTime.parse(
        '${startDateJson['year']}-${startDateJson['month'].toString().padLeft(2, '0')}-${startDateJson['day'].toString().padLeft(2, '0')}',
      ),
      lastDate: DateTime.parse(
        '${lastDateJson['year']}-${lastDateJson['month'].toString().padLeft(2, '0')}-${lastDateJson['day'].toString().padLeft(2, '0')}',
      ),
      startTime: DateTime(
        0,
        1,
        1,
        startTimeJson?['hour'] ?? 0,
        startTimeJson?['minute'] ?? 0,
      ),
      lastTime: DateTime(
        0,
        1,
        1,
        lastTimeJson?['hour'] ?? 0,
        lastTimeJson?['minute'] ?? 0,
      ),
      headUserID: json['HeadUserID'] ?? '',
      workByUserID: List<String>.from(json['WorkByUserID'] ?? []),
    );
  }
}
