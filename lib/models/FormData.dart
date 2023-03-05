import 'package:auto_lubumbashi/models/form_item.dart';
class FormData {
  int formId;
  int inputId;
  List<FormItem> formItems;

  FormData({
    required this.formId,
    required this.inputId,
    required this.formItems,
  });

  factory FormData.fromJson(Map<String, dynamic> json) {
    List<FormItem> items = [];
    if (json['formItems'] != null) {
      items = List<FormItem>.from(
          json['formItems'].map((item) => FormItem.fromJson(item)));
    }
    return FormData(
      formId: json['formId'] as int,
      inputId: json['inputId'] as int,
      formItems: items,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['formId'] = formId;
    data['inputId'] = inputId;
    data['formItems'] = formItems.map((item) => item.toJson()).toList();
    return data;
  }
}

