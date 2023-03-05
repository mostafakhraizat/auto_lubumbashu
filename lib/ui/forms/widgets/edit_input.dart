import 'package:flutter/material.dart';
class EditInput extends StatefulWidget {
    EditInput({Key? key,required this .inputId}) : super(key: key);
  int inputId;
  @override
  State<EditInput> createState() => _EditInputState();
}

class _EditInputState extends State<EditInput> {
  TextEditingController hoseAssemblerController = TextEditingController();
  TextEditingController requisitionNbController = TextEditingController();
  TextEditingController deliveryNoteNumber = TextEditingController();
  TextEditingController dateText = TextEditingController();
  String? siteName;
  String? customer;
  String? dateSelected;
  List<String>siteNames = [];
  List<String> customers = [];

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
