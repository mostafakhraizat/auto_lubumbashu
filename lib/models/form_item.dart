import 'package:auto_lubumbashi/utils/custom_text_eiditing_controller.dart';

import '../utils/data.dart';

class FormItem {
  List<String> oldImages;
  List<String> newImages;
  String? description;
  final List<String> listErrorTexts = [];
  final List<String> listTexts = [];

  CustomTextEdittingController controller = CustomTextEdittingController();
  Function? handleTextEdit;

  FormItem.item(
    this.newImages,
    this.oldImages,
    this.description,
  ) {
    controller = CustomTextEdittingController(listErrorTexts: listErrorTexts);
    handleTextEdit = _handleOnChange(controller.text);
  }

  FormItem({
    required this.description,
    required this.oldImages,
    required this.newImages,
  });
  factory FormItem.fromJson(Map<String, dynamic> json) => FormItem(
    oldImages: List<String>.from(json["oldImages"].map((x) => x)),
    newImages: List<String>.from(json["newImages"].map((x) => x)),
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "oldImages": List<dynamic>.from(oldImages.map((x) => x)),
    "newImages": List<dynamic>.from(newImages.map((x) => x)),
    "description": description,
  };

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
