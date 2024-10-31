class SubJobModel {
  final String jobId;
  final String userId;
  final String name;
  final String status;
  final String details;
  final DateTime startTimeGoal;
  final DateTime lastTimeGoal;
  final DateTime startDate;
  final DateTime lastDate;
  final String frequency;
  final int frequencyDay;
  final List<String> frequencyWeek;
  final List<int> frequencyMonth;
  final String headSubJobId;
  final int percentProgress;
  final int totalDayPass;

  SubJobModel({
    required this.jobId,
    required this.userId,
    required this.name,
    required this.status,
    required this.details,
    required this.startTimeGoal,
    required this.lastTimeGoal,
    required this.startDate,
    required this.lastDate,
    required this.frequency,
    required this.frequencyDay,
    required this.frequencyWeek,
    required this.frequencyMonth,
    required this.headSubJobId,
    required this.percentProgress,
    required this.totalDayPass,
  });

  factory SubJobModel.fromJson(Map<String, dynamic> json) {
    final startDateJson = json['StartDate'];
    final lastDateJson = json['LastDate'];

    return SubJobModel(
      jobId: json['JobID'],
      userId: json['UserID'],
      name: json['Name'],
      status: json['Status'],
      details: json['Details'],
      startTimeGoal: DateTime(0, 1, 1, json['StartTimeGoal']['hour'] ?? 0,
          json['StartTimeGoal']['minute'] ?? 0),
      lastTimeGoal: DateTime(0, 1, 1, json['LastTimeGoal']['hour'] ?? 0,
          json['LastTimeGoal']['minute'] ?? 0),
      startDate: DateTime.parse(
        '${startDateJson['year']}-${startDateJson['month'].toString().padLeft(2, '0')}-${startDateJson['day'].toString().padLeft(2, '0')}',
      ),
      lastDate: DateTime.parse(
        '${lastDateJson['year']}-${lastDateJson['month'].toString().padLeft(2, '0')}-${lastDateJson['day'].toString().padLeft(2, '0')}',
      ),
      frequency: json['Frequency'],
      frequencyDay: json['FrequencyDay'],
      frequencyWeek: List<String>.from(json['FrequencyWeek']),
      frequencyMonth: List<int>.from(json['FrequencyMonth']),
      headSubJobId: json['HeadSubJobID'],
      percentProgress: json['PercentProgress'],
      totalDayPass: json['TotalDayPass'],
    );
  }
}