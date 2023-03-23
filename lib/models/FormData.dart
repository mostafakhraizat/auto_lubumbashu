import 'package:auto_lubumbashi/models/form_item.dart';

class FormData {
  int formId;
  int inputId;
  List<FormItem> formItems;
  List<String> requisitionImages = []; // use a nullable List<String>
  List<String> testsProjectImages = []; // use a nullable List<String>
  String? deliverNoteNumber;
  FormData({
    required this.formId,
    required this.deliverNoteNumber,
    required this.inputId,
    required this.formItems,
    required this.requisitionImages,
    required this.testsProjectImages,
  });

  factory FormData.fromJson(Map<String, dynamic> json) {
    return FormData(
      formId: json['formId'] as int,
      deliverNoteNumber: json['deliverNoteNumber'] .toString(),
      inputId: json['inputId'] as int,
      formItems: (json['formItems'] as List<dynamic>)
          .map((item) => FormItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      requisitionImages:
      (json['requisitionImages'] as List<dynamic>).cast<String>(),
      testsProjectImages:
      (json['testsProjectImages'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formId': formId,
      'deliverNoteNumber': deliverNoteNumber,
      'inputId': inputId,
      'formItems': formItems.map((item) => item.toJson()).toList(),
      'requisitionImages': requisitionImages,
      'testsProjectImages': testsProjectImages,
    };
  }
}
