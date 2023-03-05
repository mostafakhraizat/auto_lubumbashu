import 'package:auto_lubumbashi/utils/custom_text_eiditing_controller.dart';

import '../utils/data.dart';

class FormItem {
  final List<String> listErrorTexts = [];
  final List<String> listTexts = [];
  String? oldImagePath;
  String? newImagePath;
  String? description;
  CustomTextEdittingController controller = CustomTextEdittingController();
  Function? handleTextEdit;

  FormItem.item(
    this.oldImagePath,
    this.newImagePath,
    this.description,
  ) {
    controller = CustomTextEdittingController(listErrorTexts: listErrorTexts);
    handleTextEdit = _handleOnChange(controller.text);
  }

  FormItem({
    required this.description,
    required this.oldImagePath,
    required this.newImagePath,
  });

  factory FormItem.fromJson(Map<String, dynamic> json) {
    return FormItem(
      oldImagePath: json['oldImagePath'] as String?,
      newImagePath: json['newImagePath'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['oldImagePath'] = oldImagePath;
    data['newImagePath'] = newImagePath;
    data['description'] = description;
    return data;
  }

  _handleOnChange(String text) {
    _handleSpellCheck(text, true);
  }

  void _handleSpellCheck(String text, bool ignoreLastWord) {
    if (!text.contains(' ')) {
      return;
    }
    final List<String> arr = text.split(' ');
    if (ignoreLastWord) {
      arr.removeLast();
    }
    for (var word in arr) {
      if (word.isEmpty) {
        continue;
      } else if (_isWordHasNumberOrBracket(word)) {
        continue;
      }
      final wordToCheck = word.replaceAll(RegExp(r"[^\s\w]"), '');
      final wordToCheckInLowercase = wordToCheck.toLowerCase();
      if (!listTexts.contains(wordToCheckInLowercase)) {
        listTexts.add(wordToCheckInLowercase);
        if (!listEnglishWords.contains(wordToCheckInLowercase)) {
          listErrorTexts.add(wordToCheck);
        }
      }
    }
  }

  bool _isWordHasNumberOrBracket(String s) {
    return s.contains(RegExp(r'[0-9\()]'));
  }
}
