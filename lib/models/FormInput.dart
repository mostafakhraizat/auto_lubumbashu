class FormInput {
  int? inputId;
  String? dnn;
  String? hoseAssembler;
  String? requisitionNb;
  String? siteName;
  String? customer;
  String? date;

  FormInput(
      {required this.dnn,
      required this.inputId,
      required this.hoseAssembler,
      required this.customer,
      required this.date,
      required this.siteName,
      required this.requisitionNb});

  FormInput.fromJson(Map<String, dynamic> json) {
    inputId = json['inputId'] as int;
    dnn = json['dnn'];
    hoseAssembler = json['hoseAssembler'];
    requisitionNb = json['requisitionNb'];
    siteName = json['siteName'];
    customer = json['customer'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['inputId'] = inputId;
    data['dnn'] = dnn;
    data['hoseAssembler'] = hoseAssembler;
    data['requisitionNb'] = requisitionNb;
    data['siteName'] = siteName;
    data['customer'] = customer;
    data['date'] = date;

    return data;
  }
}
