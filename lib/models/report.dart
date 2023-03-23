class Report {
  String dnn;
  String date;
  String path;
  String siteName;

  Report({required this.dnn, required this.date, required this.path, required this.siteName});

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      dnn: json['dnn'] as String,
      date: json['date'] as String,
      path: json['path'] as String,
      siteName: json['siteName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dnn': dnn,
      'date': date,
      'path': path,
      'siteName': siteName,
    };
  }
}
