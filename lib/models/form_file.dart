import 'FormData.dart';

class FormFile {
  List<FormData> allForms;

  FormFile({required this.allForms});

  factory FormFile.fromJson(Map<String, dynamic> json) {
    List<FormData> forms = [];
    if (json['allForms'] != null) {
      forms = List<FormData>.from(
          json['allForms'].map((form) => FormData.fromJson(form)));
    }
    return FormFile(allForms: forms);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['allForms'] = allForms.map((form) => form.toJson()).toList();
    return data;
  }
}
