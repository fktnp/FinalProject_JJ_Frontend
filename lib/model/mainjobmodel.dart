class MainJobModel {
  final String jobId;
  final String userId;
  final String name;
  final String status;
  final String category;
  final String details;
  final DateTime startTimeGoal;
  final DateTime lastTimeGoal;
  final int percentProgress;

  MainJobModel({
    required this.jobId,
    required this.userId,
    required this.name,
    required this.status,
    required this.category,
    required this.details,
    required this.startTimeGoal,
    required this.lastTimeGoal,
    required this.percentProgress,
  });

  factory MainJobModel.fromJson(Map<String, dynamic> json) {
    final startTimeGoalJson = json['StartTimeGoal'];
    final lastTimeGoalJson = json['LastTimeGoal'];

    return MainJobModel(
      jobId: json['JobID'],
      userId: json['UserID'],
      name: json['Name'],
      status: json['Status'],
      category: json['Category'],
      details: json['Details'],
      startTimeGoal: DateTime.parse(
        '${startTimeGoalJson['year']}-${startTimeGoalJson['month'].toString().padLeft(2, '0')}-${startTimeGoalJson['day'].toString().padLeft(2, '0')}',
      ),
      lastTimeGoal: DateTime.parse(
        '${lastTimeGoalJson['year']}-${lastTimeGoalJson['month'].toString().padLeft(2, '0')}-${lastTimeGoalJson['day'].toString().padLeft(2, '0')}',
      ),
      percentProgress: json['PercentProgress'],
    );
  }
}
