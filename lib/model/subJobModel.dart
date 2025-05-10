class SubJobModel {
  final String jobId;
  final String subJobId;
  final String name;
  final String status;
  final String details;
  final DateTime startTimeGoal;
  final DateTime lastTimeGoal;
  final DateTime startDate;
  final DateTime lastDate;
  final String frequency;
  final int frequencyDay;
  final String frequencyWeek;
  final int frequencyMonth;
  final String headSubJobId;
  final String userId;
  final DateTime lastDateShow;
  final int percentProgress;
  final int totalDayPass;

  SubJobModel({
    required this.jobId,
    required this.subJobId,
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
    required this.userId,
    required this.lastDateShow,
    required this.percentProgress,
    required this.totalDayPass,
  });

  factory SubJobModel.fromJson(Map<String, dynamic> json) {
    return SubJobModel(
      jobId: json['JobID'] ?? '', // ใช้ 'JobID' แทน 'job_id'
      subJobId: json['SubJobID'] ?? '', // ใช้ 'SubJobID' แทน 'sub_job_id'
      name: json['Name'] ?? '', // ใช้ 'Name' แทน 'name'
      status: json['Status'] ?? '', // ใช้ 'Status' แทน 'status'
      details: json['Details'] ?? '', // ใช้ 'Details' แทน 'details'
      startTimeGoal: DateTime.parse(json['StartTimeGoal'] ?? '1970-01-01T00:00:00Z'), // ใช้ 'StartTimeGoal' แทน 'start_time_goal'
      lastTimeGoal: DateTime.parse(json['LastTimeGoal'] ?? '1970-01-01T00:00:00Z'), // ใช้ 'LastTimeGoal' แทน 'last_time_goal'
      startDate: DateTime.parse(json['StartDate'] ?? '1970-01-01T00:00:00Z'), // ใช้ 'StartDate' แทน 'start_date'
      lastDate: DateTime.parse(json['LastDate'] ?? '1970-01-01T00:00:00Z'), // ใช้ 'LastDate' แทน 'last_date'
      frequency: json['Frequency'] ?? '', // ใช้ 'Frequency' แทน 'frequency'
      frequencyDay: json['FrequencyDay'] ?? 0, // ใช้ 'FrequencyDay' แทน 'frequency_day'
      frequencyWeek: json['FrequencyWeek'] ?? '', // ใช้ 'FrequencyWeek' แทน 'frequency_week'
      frequencyMonth: json['FrequencyMonth'] ?? 0, // ใช้ 'FrequencyMonth' แทน 'frequency_month'
      headSubJobId: json['HeadSubJobID'] ?? '', // ใช้ 'HeadSubJobID' แทน 'head_sub_job_id'
      userId: json['UserID'] ?? '', // ใช้ 'UserID' แทน 'user_id'
      lastDateShow: DateTime.parse(json['LastDateShow'] ?? '1970-01-01T00:00:00Z'), // ใช้ 'LastDateShow' แทน 'last_date_show'
      percentProgress: json['PercentProgress'] ?? 0, // ใช้ 'PercentProgress' แทน 'percent_progress'
      totalDayPass: json['TotalDayPass'] ?? 0, // ใช้ 'TotalDayPass' แทน 'total_day_pass'
    );
  }
}
