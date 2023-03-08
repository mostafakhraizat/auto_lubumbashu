import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_lubumbashi/bloc/reports/reports_bloc.dart';
import 'package:auto_lubumbashi/models/FormData.dart';
import 'package:auto_lubumbashi/models/FormInput.dart';
import 'package:auto_lubumbashi/models/form_item.dart';
import 'package:auto_lubumbashi/themes/app_theme.dart';
import 'package:auto_lubumbashi/ui/forms/screens/saved_forms.dart';
import 'package:auto_lubumbashi/ui/forms/widgets/data_input_widget.dart';
import 'package:auto_lubumbashi/ui/forms/widgets/edit_input.dart';
import 'package:auto_lubumbashi/ui/forms/widgets/image_screen.dart';
import 'package:auto_lubumbashi/utils/constants.dart';
import 'package:auto_lubumbashi/utils/custom_text_eiditing_controller.dart';
import 'package:auto_lubumbashi/utils/data.dart';
import 'package:auto_lubumbashi/view_models/form_input_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CreateFormScreen extends StatefulWidget {
  CreateFormScreen({Key? key, required this.input, required this.form})
      : super(key: key);
  FormInput input;
  FormData? form;

  @override
  _CreateFormScreenState createState() => _CreateFormScreenState();
}

class _CreateFormScreenState extends State<CreateFormScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  GlobalKey<FormState> key = GlobalKey();
  TextEditingController hoseAssemblerController = TextEditingController();
  TextEditingController requisitionNbController = TextEditingController();
  TextEditingController deliveryNoteNumber = TextEditingController();
  TextEditingController dateText = TextEditingController();
  String? siteName;
  String? customer;
  String? dateSelectedString;
  List<String> siteNames = [];
  List<String> customers = [];
  List<FormItem> formDataList = [];

  late int formId;

  @override
  void initState() {
    if (widget.form != null) {
      formDataList = widget.form!.formItems;
      formId = widget.form!.formId;

      if (formDataList.isEmpty) {
        pressedItems = List.generate(1, (index) => index == 0);
        formDataList.add(
          FormItem(
            description: "",
            oldImagePath: "",
            newImagePath: "",
          ),
        );
      } else {
        pressedItems =
            List.generate(widget.form!.formItems.length, (index) => index == 0);
      }
    } else {
      formId = DateTime.now().millisecondsSinceEpoch;
      pressedItems = List.generate(1, (index) => index == 0);
      formDataList.add(
        FormItem(
          description: "",
          oldImagePath: "",
          newImagePath: "",
        ),
      );
    }

    _tabController = TabController(length: 2, vsync: this);
    siteNames = siteNamesCustomers.keys.toList();
    // set values
    hoseAssemblerController.text = widget.input.hoseAssembler.toString();
    requisitionNbController.text = widget.input.requisitionNb.toString();
    deliveryNoteNumber.text = widget.input.dnn.toString();
    dateText.text = widget.input.date.toString();
    siteName = widget.input.siteName;
    customer = widget.input.customer;
    selectedDate = DateTime.parse(dateText.text.toString());

    super.initState();
  }

  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateText.text = picked.toString().substring(0, 10);
      });
    }
  }

  List<String> titles = [];
  TextEditingController controller = TextEditingController();
  List<bool> pressedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  formDataList.add(FormItem(
                      description: "", oldImagePath: "", newImagePath: ""));
                  pressedItems.fillRange(0, pressedItems.length, false);
                  pressedItems.add(true);
                });
              },
              backgroundColor: MyAppTheme.primaryRed,
              tooltip: "Add Form Item",
              child: const Icon(Icons.add),
            )
          : null,
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.form == null ? "Create Form" : "Edit Form"),
        actions: [
          // TextButton(
          //     onPressed: () {
          //       showMenu(
          //           context: context,
          //           position: const RelativeRect.fromLTRB(100, 0, 0, 0),
          //           items: widget.form == null
          //               ? [
          //                   PopupMenuItem(
          //                     child: const Text('Forms History'),
          //                     onTap: () async {
          //                       Navigator.of(context).push(MaterialPageRoute(
          //                           builder: (c) => const SavedFormsScreen()));
          //                     },
          //                   ),
          //                   PopupMenuItem(
          //                     child: Row(
          //                       mainAxisAlignment:
          //                           MainAxisAlignment.spaceBetween,
          //                       children: const [
          //                         Text(
          //                           "Save Form",
          //                           style: TextStyle(),
          //                         ),
          //                       ],
          //                     ),
          //                     onTap: () async {
          //                       try {
          //                         var rootPath =
          //                             await getApplicationDocumentsDirectory();
          //                         //get forms file
          //                         File forms =
          //                             File("${rootPath.path}/forms.json");
          //                         //read forms in string var
          //                         String formsDataString =
          //                             forms.readAsStringSync();
          //                         log(formsDataString);
          //                         //convert the json list into FormData List
          //                         Iterable iter = jsonDecode(formsDataString);
          //                         //data list is all forms in forms.json
          //                         List<FormData> formsDataList =
          //                             List<FormData>.from(iter.map(
          //                                 (model) => FormData.fromJson(model)));
          //                         //saved data is the current formData item
          //                         FormData savedData = FormData(
          //                             formId: formId,
          //                             inputId: int.parse(
          //                                 widget.input.inputId.toString()),
          //                             formItems: formDataList);
          //
          //                         //check existing data item
          //                         var existingItem = formsDataList.where(
          //                             (element) => element.formId == formId);
          //                         if (existingItem.isNotEmpty) {
          //                           savedData = existingItem.first;
          //
          //                           savedData.formItems = formDataList;
          //
          //                           forms.writeAsString(
          //                               jsonEncode(formsDataList));
          //                         } else {
          //                           formsDataList.add(savedData);
          //                           forms.writeAsString(
          //                               jsonEncode(formsDataList));
          //                         }
          //                         //save inputs
          //
          //                         File inputs =
          //                             File("${rootPath.path}/inputs.json");
          //                         //read forms in string var
          //                         String inputsString =
          //                             inputs.readAsStringSync();
          //                         log(inputsString);
          //                         //convert the json list into FormData List
          //                         Iterable inputIter = jsonDecode(inputsString);
          //                         //data list is all forms in forms.json
          //                         List<FormInput> allInputs =
          //                             List<FormInput>.from(inputIter.map(
          //                                 (model) =>
          //                                     FormInput.fromJson(model)));
          //                         FormInput input = allInputs
          //                             .where((element) =>
          //                                 element.inputId ==
          //                                 widget.input.inputId)
          //                             .first;
          //                         input.customer = customer;
          //                         input.siteName = siteName;
          //                         input.dnn = deliveryNoteNumber.text;
          //                         input.hoseAssembler =
          //                             hoseAssemblerController.text;
          //                         input.requisitionNb =
          //                             requisitionNbController.text;
          //                         input.date = dateText.text;
          //                         inputs.writeAsString(jsonEncode(allInputs));
          //
          //                         ScaffoldMessenger.of(context)
          //                             .showSnackBar(const SnackBar(
          //                                 backgroundColor: Colors.green,
          //                                 content: Text(
          //                                   "Form saved successfully",
          //                                   style:
          //                                       TextStyle(color: Colors.white),
          //                                 )));
          //                       } on Exception catch (e, s) {
          //                         print(s);
          //                         ScaffoldMessenger.of(context).showSnackBar(
          //                             SnackBar(content: Text(e.toString())));
          //                       }
          //                     },
          //                   ),
          //                 ]
          //               : [
          //                   PopupMenuItem(
          //                     child: Row(
          //                       mainAxisAlignment:
          //                           MainAxisAlignment.spaceBetween,
          //                       children: const [
          //                         Text(
          //                           "Save Form",
          //                           style: TextStyle(),
          //                         ),
          //                       ],
          //                     ),
          //                     onTap: () async {
          //
          //                     },
          //                   ),
          //                 ]);
          //     },
          //     child: const Icon(
          //       Icons.more_vert,
          //       color: Colors.white,
          //     )),

         widget.form==null? TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (c) => const SavedFormsScreen()));
              },
              child: Text(
                "All Forms",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )):Container(),
          widget.form==null? Center(
            child: Text(
              " |",
              style: TextStyle(
                  color: Colors.grey.shade200, fontWeight: FontWeight.bold),
            ),
          ):Container(),
          TextButton(
              onPressed: () async {
                try {
                  var rootPath = await getApplicationDocumentsDirectory();
                  //get forms file
                  File forms = File("${rootPath.path}/forms.json");
                  //read forms in string var
                  String formsDataString = forms.readAsStringSync();
                  log(formsDataString);
                  //convert the json list into FormData List
                  Iterable iter = jsonDecode(formsDataString);
                  //data list is all forms in forms.json
                  List<FormData> formsDataList = List<FormData>.from(
                      iter.map((model) => FormData.fromJson(model)));
                  //saved data is the current formData item
                  FormData savedData = FormData(
                      formId: formId,
                      inputId: int.parse(widget.input.inputId.toString()),
                      formItems: formDataList);

                  //check existing data item
                  var existingItem = formsDataList
                      .where((element) => element.formId == formId);
                  if (existingItem.isNotEmpty) {
                    savedData = existingItem.first;

                    savedData.formItems = formDataList;

                    forms.writeAsString(jsonEncode(formsDataList));
                  } else {
                    formsDataList.add(savedData);
                    forms.writeAsString(jsonEncode(formsDataList));
                  }
                  //save inputs

                  File inputs = File("${rootPath.path}/inputs.json");
                  //read forms in string var
                  String inputsString = inputs.readAsStringSync();
                  log(inputsString);
                  //convert the json list into FormData List
                  Iterable inputIter = jsonDecode(inputsString);
                  //data list is all forms in forms.json
                  List<FormInput> allInputs = List<FormInput>.from(
                      inputIter.map((model) => FormInput.fromJson(model)));
                  FormInput input = allInputs
                      .where(
                          (element) => element.inputId == widget.input.inputId)
                      .first;
                  input.customer = customer;
                  input.siteName = siteName;
                  input.dnn = deliveryNoteNumber.text;
                  input.hoseAssembler = hoseAssemblerController.text;
                  input.requisitionNb = requisitionNbController.text;
                  input.date = dateText.text;
                  inputs.writeAsString(jsonEncode(allInputs));

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(
                        "Form saved successfully",
                        style: TextStyle(color: Colors.white),
                      )));
                } on Exception catch (e, s) {
                  print(s);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: Text(
                "Save",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
        ],
        bottom: TabBar(
            onTap: (index) {
              setState(() {
                _tabController.index = index;
              });
            },
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 4,
            controller: _tabController,
            tabs: const [
              SizedBox(height: 42, child: Center(child: Text('Form'))),
              SizedBox(height: 42, child: Center(child: Text('Generate PDF'))),
            ]),
      ),
      body: TabBarView(controller: _tabController, children: [
        Padding(
            padding: EdgeInsets.all(0),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              child: Column(
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: const [
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        "Form Information: ",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                pressedItems[index] = !pressedItems[index];
                              });
                            },
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 36,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 22,
                                      ),
                                      Builder(builder: (context) {
                                        if (formDataList
                                                .elementAt(index)
                                                .newImagePath
                                                .toString()
                                                .isEmpty &&
                                            formDataList
                                                .elementAt(index)
                                                .description
                                                .toString()
                                                .isEmpty) {
                                          return Container(
                                            height: 32,
                                            width: 32,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: Colors.black),
                                            child: Center(
                                                child: Text(
                                              "${index + 1}",
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            )),
                                          );
                                        } else if ((formDataList
                                                    .elementAt(index)
                                                    .newImagePath
                                                    .toString()
                                                    .isEmpty &&
                                                formDataList
                                                    .elementAt(index)
                                                    .description
                                                    .toString()
                                                    .isNotEmpty) ||
                                            (formDataList
                                                    .elementAt(index)
                                                    .newImagePath
                                                    .toString()
                                                    .isNotEmpty &&
                                                formDataList
                                                    .elementAt(index)
                                                    .description
                                                    .toString()
                                                    .isEmpty)) {
                                          return Container(
                                            height: 32,
                                            width: 32,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                color: Colors.blue),
                                            child: const Center(
                                              child: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        } else {
                                          return Container(
                                            height: 32,
                                            width: 32,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                color: Colors.green),
                                            child: const Center(
                                              child: Icon(
                                                Icons.check,
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      const Expanded(child: SizedBox()),
                                      Text(
                                        "#${index + 1}",
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      pressedItems.elementAt(index)
                                          ? InkWell(
                                              onTap: () {
                                                setState(() {
                                                  formDataList.removeAt(index);
                                                });
                                              },
                                              child: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ))
                                          : Container(),
                                      const SizedBox(
                                        width: 18,
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 38,
                                    ),
                                    index == 37
                                        ? Container()
                                        : Container(
                                            height:
                                                pressedItems[index] ? 0 : 38,
                                            width: 0.5,
                                            color: Colors.grey,
                                          )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          pressedItems[index]
                              ? Builder(builder: (context) {
                                  FormItem item = formDataList.elementAt(index);
                                  return SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 12, right: 20),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: TextFormField(
                                              initialValue: item.description,
                                              onChanged: (text) {
                                                item.handleTextEdit;
                                                setState(() {
                                                  item.description = text;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Description',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),

                                        //old image
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: const [
                                                SizedBox(
                                                  width: 22,
                                                ),
                                                Text(
                                                  "Please select a old image",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Builder(builder: (context) {
                                              if (item.oldImagePath
                                                      .toString()
                                                      .isEmpty ||
                                                  item.oldImagePath == null) {
                                                return Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        selectImages("gallery",
                                                            "old", item);
                                                      },
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Icon(
                                                          Icons.image,
                                                          color: MyAppTheme
                                                              .primaryRed,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        selectImages("camera",
                                                            "old", item);
                                                      },
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Icon(
                                                          Icons.camera_alt,
                                                          color: MyAppTheme
                                                              .primaryRed,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            selectImages(
                                                                "gallery",
                                                                "old",
                                                                item);
                                                          },
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Icon(
                                                              Icons.image,
                                                              color: MyAppTheme
                                                                  .primaryRed,
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            selectImages(
                                                                "camera",
                                                                "old",
                                                                item);
                                                          },
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Icon(
                                                              Icons.camera_alt,
                                                              color: MyAppTheme
                                                                  .primaryRed,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          item.oldImagePath =
                                                              "";
                                                        });
                                                      },
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Icon(
                                                          Icons.delete,
                                                          color: MyAppTheme
                                                              .primaryRed,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              }
                                            })
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        Builder(builder: (context) {
                                          if (item.oldImagePath == null ||
                                              item.oldImagePath
                                                  .toString()
                                                  .isEmpty) {
                                            return Container();
                                          }
                                          return Center(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (c) =>
                                                            ImageScreen(
                                                                image:
                                                                    Image.file(
                                                                  File(item
                                                                      .oldImagePath
                                                                      .toString()),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder:
                                                                      (a, b,
                                                                          c) {
                                                                    return Container();
                                                                  },
                                                                ),
                                                                index: 0)));
                                              },
                                              child: SizedBox(
                                                height: 120,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    30,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.file(
                                                    File(item.oldImagePath
                                                        .toString()),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (a, b, c) {
                                                      return Container();
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),

                                        ///
                                        ///
                                        const Divider(),
                                        //new image

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: const [
                                                SizedBox(
                                                  width: 22,
                                                ),
                                                Text(
                                                  "Please select a new image",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Builder(builder: (context) {
                                              if (item.newImagePath
                                                      .toString()
                                                      .isEmpty ||
                                                  item.newImagePath == null) {
                                                return Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        selectImages("gallery",
                                                            "new", item);
                                                      },
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Icon(
                                                          Icons.image,
                                                          color: MyAppTheme
                                                              .primaryRed,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        selectImages("camera",
                                                            "new", item);
                                                      },
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Icon(
                                                          Icons.camera_alt,
                                                          color: MyAppTheme
                                                              .primaryRed,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            selectImages(
                                                                "gallery",
                                                                "new",
                                                                item);
                                                          },
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Icon(
                                                              Icons.image,
                                                              color: MyAppTheme
                                                                  .primaryRed,
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            selectImages(
                                                                "camera",
                                                                "new",
                                                                item);
                                                          },
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Icon(
                                                              Icons.camera_alt,
                                                              color: MyAppTheme
                                                                  .primaryRed,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          item.newImagePath =
                                                              "";
                                                        });
                                                      },
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Icon(
                                                          Icons.delete,
                                                          color: MyAppTheme
                                                              .primaryRed,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              }
                                            })
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        Builder(builder: (context) {
                                          if (item.newImagePath == null ||
                                              item.newImagePath
                                                  .toString()
                                                  .isEmpty) {
                                            return Container();
                                          }
                                          return Center(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (c) =>
                                                            ImageScreen(
                                                                image:
                                                                    Image.file(
                                                                  File(item
                                                                      .newImagePath
                                                                      .toString()),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder:
                                                                      (a, b,
                                                                          c) {
                                                                    return Container();
                                                                  },
                                                                ),
                                                                index: 0)));
                                              },
                                              child: SizedBox(
                                                height: 120,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    30,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.file(
                                                    File(item.newImagePath
                                                        .toString()),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (a, b, c) {
                                                      return Container();
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                })
                              : Container(),
                          const SizedBox(
                            height: 12,
                          ),
                          pressedItems[index]
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            pressedItems[index] = false;
                                          });

                                          if (index != 37) {
                                            setState(() {
                                              pressedItems[index + 1] = true;
                                            });
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                            foregroundColor:
                                                Colors.amber.shade400,
                                            padding: EdgeInsets.zero,
                                            backgroundColor: Colors.black),
                                        child: const Text(
                                          "     \t\t\tNext\t\t\t      ",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 42,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            pressedItems[index] = false;
                                          });

                                          if (index != 0) {
                                            setState(() {
                                              pressedItems[index - 1] = true;
                                            });
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor:
                                              Colors.black.withOpacity(0.5),
                                        ),
                                        child: const Text("back"),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      );
                    },
                    itemCount: formDataList.length,
                  ),
                ],
              ),
            )),
        BlocProvider(
          create: (context) => ReportsBloc(),
          child: BlocConsumer<ReportsBloc, ReportsState>(
            listener: (context, state) {
              // TODO: implement listener
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 22,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Flexible(
                            child: Text(
                              'You can update from inputs before generating',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          Icon(
                            Icons.list,
                            color: MyAppTheme.primaryRed,
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    Form(
                      key: key,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: deliveryNoteNumber,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Deliver Note Number';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 12),
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  hintText: 'Deliver Note Number',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              child: DropdownButtonFormField(
                                items: siteNames
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e.toString()),
                                        ))
                                    .toList(),
                                hint: const Text("Site Name"),
                                onChanged: (value) {
                                  setState(() {
                                    siteName = value.toString();
                                    customer = null;
                                    customers = siteNamesCustomers["$siteName"]!
                                        .toList();
                                  });
                                },
                                value: siteName,
                                validator: (value) {
                                  if (value == null) {
                                    return "Please select site name";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              child: DropdownButtonFormField(
                                items: customers
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e.toString()),
                                        ))
                                    .toList(),
                                hint: const Text("Customer"),
                                onChanged: (value) {
                                  setState(() {
                                    customer = value.toString();
                                  });
                                },
                                value: customer,
                                validator: (value) {
                                  if (value == null) {
                                    return "Please select customer";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Hose Assembler';
                                  }
                                  return null;
                                },
                                controller: hoseAssemblerController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 12),
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  hintText: 'Hose Assembler',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: requisitionNbController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Requisition Number';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 12),
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  hintText: 'Requisition NO:',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                readOnly: true,
                                onTap: () {
                                  _selectDate(context);
                                },
                                controller: dateText,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Select Date';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  contentPadding:
                                      const EdgeInsets.only(left: 12),
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  hintText: 'Select Date',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                            FormData data = FormData(
                                formId: formId,
                                inputId: widget.input.inputId!,
                                formItems: formDataList);
                            FormInputViewModel formInputViewModel =
                                FormInputViewModel(
                                    formData: data, formInput: widget.input);
                            ReportsBloc.instance(context).add(
                                GenerateReportEvent(
                                    formInputViewModel: formInputViewModel,
                                    context: context));
                          },
                          child: Container(
                            height: 62,
                            width: 320,
                            decoration: BoxDecoration(
                                color: MyAppTheme.primaryRed,
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Generate PDF',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 22,
                                  ),
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 22,
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  void selectImages(String type, String condition, FormItem item) async {
    final ImagePicker imagePicker = ImagePicker();

    final XFile? selectedImage = await imagePicker.pickImage(
      source: type == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 20,
    );

    if (selectedImage != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: selectedImage.path,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Image Cropper',
            toolbarColor: MyAppTheme.primaryRed,
            lockAspectRatio: false,
            activeControlsWidgetColor: MyAppTheme.primaryRed,
            toolbarWidgetColor: Colors.white,
          ),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      if (croppedFile != null) {
        if (condition == "new") {
          setState(() {
            item.newImagePath = croppedFile.path;
          });
        } else {
          setState(() {
            item.oldImagePath = croppedFile.path;
          });
        }
      }
    }
  }
}

class PDFItemImages {
  Uint8List imagesData;
  int height;
  int width;

  PDFItemImages(
      {required this.imagesData, required this.height, required this.width});
}

class ItemWidgets {
  String title;
  String description;
  List<String> images;

  ItemWidgets(this.title, this.description, this.images);
}
