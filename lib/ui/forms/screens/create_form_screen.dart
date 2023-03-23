import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_lubumbashi/bloc/reports/reports_bloc.dart';
import 'package:auto_lubumbashi/models/FormData.dart';
import 'package:auto_lubumbashi/models/FormInput.dart';
import 'package:auto_lubumbashi/models/form_item.dart';
import 'package:auto_lubumbashi/themes/app_theme.dart';
import 'package:auto_lubumbashi/ui/forms/widgets/image_screen.dart';
import 'package:auto_lubumbashi/utils/constants.dart';
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
  TextEditingController siteNameController = TextEditingController();
  TextEditingController dateText = TextEditingController();
  TextEditingController customerName = TextEditingController();
  String? siteName;
  String? customer;
  String? dateSelectedString;
  String? deliverNoteNumberImage;
  List<String> siteNames = [];
  List<String> customers = [];
  List<FormItem> formDataList = [];
  List<String> requisitionImages = [];
  List<String> testsProjectImages = [];
  late int formId;
  late bool hideCustomer;

  @override
  void initState() {
    addCustomerName = widget.input.addCustomerName ?? false;
    addSiteName = widget.input.addSiteName ?? false;
    hideCustomer = widget.input.addSiteName ?? false;
    if (widget.form != null) {
      deliverNoteNumberImage = widget.form!.deliverNoteNumber;
      formDataList = widget.form!.formItems;
      requisitionImages.addAll(widget.form!.requisitionImages ?? []);
      testsProjectImages.addAll(widget.form!.testsProjectImages ?? []);
      formId = widget.form!.formId;

      if (formDataList.isEmpty) {
        pressedItems = List.generate(1, (index) => index == 0);
        formDataList.add(
          FormItem(
            description: "",
            oldImages: [],
            newImages: [],
          ),
        );
      } else {
        pressedItems =
            List.generate(widget.form!.formItems.length, (index) => index == 0);
      }
    } else {
      formId = DateTime
          .now()
          .millisecondsSinceEpoch;
      pressedItems = List.generate(1, (index) => index == 0);
      formDataList.add(
        FormItem(
          description: "",
          oldImages: [],
          newImages: [],
        ),
      );
    }

    _tabController = TabController(length: 5, vsync: this);
    siteNames = siteNamesCustomers.keys.toList();
    // set values
    hoseAssemblerController.text = widget.input.hoseAssembler.toString();
    requisitionNbController.text = widget.input.requisitionNb.toString();
    deliveryNoteNumber.text = widget.input.dnn.toString();
    customerName.text = widget.input.customer ?? "";

    siteNameController.text = widget.input.siteName ?? "";
    dateText.text = widget.input.date.toString();
    log("SITENAME: ${widget.input.customer}");
    customer = (widget.input.addCustomerName ?? false)
        ? "Other"
        : widget.input.customer;
    log("CUSTOMERSlENGTH: ${customers.length}");

    siteName =
    (widget.input.addSiteName ?? false) ? "Other" : widget.input.siteName;
    selectedDate = DateTime.parse(dateText.text.toString());
    customers = siteNamesCustomers["$siteName"] ?? [];

    log(widget.input.customer.toString());
    log(widget.input.addCustomerName.toString());
    log(customer.toString());
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
  List<String> oldImages = [];
  List<String> newImages = [];
  late bool addCustomerName;

  late bool addSiteName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      floatingActionButton: _tabController.index == 4
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            formDataList.add(FormItem(
              description: "",
              oldImages: [],
              newImages: [],
            ));
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

          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Row(
                children: const [
                  Icon(Icons.home, color: Colors.white),
                  Text(
                    "Home",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
          Center(
            child: Text(
              " |",
              style: TextStyle(
                  color: Colors.grey.shade200, fontWeight: FontWeight.bold),
            ),
          ),
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
                      deliverNoteNumber: deliverNoteNumberImage,
                      formId: formId,
                      inputId: int.parse(widget.input.inputId.toString()),
                      formItems: formDataList,
                      requisitionImages: requisitionImages,
                      testsProjectImages: testsProjectImages);
                  //check existing data item
                  var existingItem = formsDataList
                      .where((element) => element.formId == formId);
                  if (existingItem.isNotEmpty) {
                    savedData = existingItem.first;
                    savedData.formItems = formDataList;
                    savedData.testsProjectImages = testsProjectImages;
                    savedData.requisitionImages = requisitionImages;
                    savedData.deliverNoteNumber = deliverNoteNumberImage;
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
                log(testsProjectImages.length.toString());
              },
              child: const Text(
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
              SizedBox(
                  height: 42,
                  child: Center(child: FittedBox(
                    child: Text('Generate PDF', style: TextStyle(
                    ),),
                  ))),
              SizedBox(
                  height: 42,
                  child: Center(child: Text('DN', style: TextStyle(
                      fontSize: 12
                  ),))),
              SizedBox(
                  height: 42,
                  child: Center(child: FittedBox(child: Text('REQ')))),
              SizedBox(
                  height: 42,
                  child: Center(
                      child: Text('TEST', style: TextStyle(fontSize: 12),))),
              SizedBox(height: 42, child: Center(child: Text('Hoses'))),
            ]),
      ),
      body: TabBarView(controller: _tabController, children: [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        SizedBox(
                          width: 22,
                        ),
                        Icon(Icons.format_list_bulleted),
                        SizedBox(
                          width: 12,
                        ),
                        Text(
                          'Please fill up report inputs',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
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
                                    return 'Please enter Deliver Note Number';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      left: 12),
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
                                    .map((e) =>
                                    DropdownMenuItem(
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
                                    addCustomerName = value == "Other";
                                    hideCustomer = value == "Other";
                                    addSiteName = value == "Other";
                                  });
                                },
                                value: siteName,
                                validator: (value) {
                                  if (value == null) {
                                    return "Please select Site Name";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Builder(builder: (context) {
                              if (addSiteName) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Site Name';
                                      }
                                      return null;
                                    },
                                    controller: siteNameController,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(
                                          left: 12),
                                      hintStyle:
                                      const TextStyle(color: Colors.grey),
                                      hintText: 'Site Name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            }),
                            hideCustomer
                                ? Container()
                                : Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              child: DropdownButtonFormField(
                                items: customers
                                    .map((e) =>
                                    DropdownMenuItem(
                                      value: e,
                                      child: Text(e.toString()),
                                    ))
                                    .toList(),
                                hint: const Text("Customer"),
                                onChanged: (value) {
                                  setState(() {
                                    customer = value.toString();
                                  });
                                  //
                                  setState(() {
                                    addCustomerName = customer == "Other";
                                  });
                                },
                                value: customer,
                                validator: (value) {
                                  if (value == null) {
                                    return "Please select Customer";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Builder(builder: (context) {
                              if (addCustomerName) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Customer Name';
                                      }
                                      return null;
                                    },
                                    controller: customerName,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(
                                          left: 12),
                                      hintStyle:
                                      const TextStyle(color: Colors.grey),
                                      hintText: 'Customer Name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            }),
                            Builder(builder: (context) {
                              if (hideCustomer) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Customer Name';
                                      }
                                      return null;
                                    },
                                    controller: customerName,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(
                                          left: 12),
                                      hintStyle:
                                      const TextStyle(color: Colors.grey),
                                      hintText: 'Customer Name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            }),
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
                                  contentPadding: const EdgeInsets.only(
                                      left: 12),
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
                                  contentPadding: const EdgeInsets.only(
                                      left: 12),
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
                                    return 'Please select Date';
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
                            if (key.currentState!.validate()) {
                              if(!(deliverNoteNumberImage==null||deliverNoteNumberImage!.isEmpty)){
                                FormData data = FormData(
                                    formId: formId,
                                    deliverNoteNumber: deliverNoteNumberImage,
                                    inputId: widget.input.inputId!,
                                    formItems: formDataList,
                                    requisitionImages: requisitionImages,
                                    testsProjectImages: testsProjectImages);
                                FormInput input = FormInput(
                                    addSiteName: addSiteName,
                                    dnn: deliveryNoteNumber.text,
                                    inputId: widget.input.inputId,
                                    hoseAssembler: hoseAssemblerController.text,
                                    customer: addCustomerName
                                        ? customerName.text
                                        : customer,
                                    addCustomerName: widget.input.addCustomerName,
                                    date: dateText.text,
                                    siteName: siteName,
                                    requisitionNb: requisitionNbController.text);

                                FormInputViewModel formInputViewModel =
                                FormInputViewModel(
                                    formData: data, formInput: input);
                                ReportsBloc.instance(context).add(
                                    GenerateReportEvent(
                                        formInputViewModel: formInputViewModel,
                                        context: context));
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: MyAppTheme.primaryRed,
                                        content: Text("Please add Delivery Note")));
                                        _tabController.animateTo(1,curve: Curves.easeInBack);


                              }
                          
                            }
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: const [
                  Text(
                    "● Deliver Note",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Please select Single Image",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            selectDnnImage('camera');
                          },
                          child: Container(
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 32,
                            ),
                          )),
                      const SizedBox(
                        width: 6,
                      ),
                      InkWell(
                          onTap: () {
                            selectDnnImage(
                              'gallery',
                            );
                          },
                          child: Container(
                            child: const Icon(
                              Icons.image,
                              color: Colors.black,
                              size: 32,
                            ),
                          )),
                      const SizedBox(
                        width: 8,
                      ),
                    ],
                  )
                ],
              ),
              Builder(builder: (context) {
                log("Note imageeee:${ deliverNoteNumberImage.toString() ==
                    "null" }");
                if (deliverNoteNumberImage.toString() == "null" ||
                    deliverNoteNumberImage
                        .toString()
                        .isEmpty) {
                  return Container(
                    height: MediaQuery.of(context).size.height-280,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width - 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.image, size: 32, color: Colors.grey,),
                          Text("Delivery Note Image",
                            style: TextStyle(color: Colors.grey),)
                        ],
                      ),
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      SizedBox(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width - 30,
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (c) => ImageScreen(
                                        image: Image.file(File(deliverNoteNumberImage.toString())), index: 0)));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(deliverNoteNumberImage.toString()),
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width - 30,
                                  height: MediaQuery.of(context).size.height-281,
                                  fit: BoxFit.cover,
                                  errorBuilder: (a, b, c) {
                                    return Container();
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    deliverNoteNumberImage = null;
                                  });
                                },
                                child: Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                      color: MyAppTheme.primaryRed,
                                      borderRadius: BorderRadius.circular(4)),
                                  child: const Center(
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider()
                    ],
                  );
                }
              })
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: const [
                  Text(
                    "● Requisition / Work order",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Please select Single Image",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            selectRequisitionImages('camera');
                          },
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                            size: 32,
                          )),
                      const SizedBox(
                        width: 6,
                      ),
                      InkWell(
                          onTap: () {
                            selectRequisitionImages(
                              'gallery',
                            );
                          },
                          child: Container(
                            child: const Icon(
                              Icons.image,
                              color: Colors.black,
                              size: 32,
                            ),
                          )),
                      const SizedBox(
                        width: 8,
                      ),
                    ],
                  )
                ],
              ),

              Builder(builder: (v){
                if(requisitionImages.isEmpty){

                                     return Container(
                    height: MediaQuery.of(context).size.height-280,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width - 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.image, size: 32, color: Colors.grey,),
                          Text("Delivery Note Image",
                            style: TextStyle(color: Colors.grey),)
                        ],
                      ),
                    ),
                  );

                }else{
                 return  SizedBox(
                    height: MediaQuery.of(context).size.height-280,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width - 30,
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (c) => ImageScreen(
                                    image: Image.file(File(requisitionImages.first.toString())), index: 0)));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(requisitionImages.elementAt(0)),
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width -
                                  30,
                              height: MediaQuery.of(context).size.height-280,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                requisitionImages.removeAt(0);
                              });
                            },
                            child: Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                  color: MyAppTheme.primaryRed,
                                  borderRadius:
                                  BorderRadius.circular(4)),
                              child: const Center(
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              })
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: const [
                  Text(
                    "● Test Reports",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Please select Multi Images",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                          onTap: () {
                            selectTestsImages('camera');
                          },
                          child: Container(
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 32,
                            ),
                          )),
                      const SizedBox(
                        width: 6,
                      ),
                      InkWell(
                          onTap: () {
                            selectTestsImages(
                              'gallery',
                            );
                          },
                          child: Container(
                            child: const Icon(
                              Icons.image,
                              color: Colors.black,
                              size: 32,
                            ),
                          )),
                      const SizedBox(
                        width: 8,
                      ),
                    ],
                  )
                ],
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: testsProjectImages.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            SizedBox(
                              height: 220,
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width - 30,
                              child: Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (c) => ImageScreen(
                                              image: Image.file(File(testsProjectImages.elementAt(index).toString())), index: index)));
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(testsProjectImages.elementAt(index)),
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            30,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 8,
                                    top: 8,
                                    child: Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                          BorderRadius.circular(4)),
                                      child: Center(
                                        child: Text(
                                          "${index + 1}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          testsProjectImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        height: 32,
                                        width: 32,
                                        decoration: BoxDecoration(
                                            color: MyAppTheme.primaryRed,
                                            borderRadius:
                                            BorderRadius.circular(4)),
                                        child: const Center(
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                            )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider()
                          ],
                        );
                      }))
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(0),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              child: Column(
                children: [
                  const SizedBox(
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
                  const SizedBox(
                    height: 12,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                                        if ((formDataList
                                            .elementAt(index)
                                            .newImages
                                            .isEmpty ||
                                            formDataList
                                                .elementAt(index)
                                                .oldImages
                                                .isEmpty) &&
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
                                        } else if (((formDataList
                                            .elementAt(index)
                                            .newImages
                                            .isEmpty ||
                                            formDataList
                                                .elementAt(index)
                                                .oldImages
                                                .isEmpty) &&
                                            formDataList
                                                .elementAt(index)
                                                .description
                                                .toString()
                                                .isNotEmpty) ||
                                            ((formDataList
                                                .elementAt(index)
                                                .newImages
                                                .isNotEmpty ||
                                                formDataList
                                                    .elementAt(index)
                                                    .oldImages
                                                    .isNotEmpty) &&
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
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width,
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
                                      width: MediaQuery
                                          .of(context)
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
                                            "Please select old images",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                              onTap: () {
                                                selectOldImages(
                                                    'camera',
                                                    formDataList
                                                        .elementAt(
                                                        index));
                                              },
                                              child: Container(
                                                child: const Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.black,
                                                ),
                                              )),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          InkWell(
                                              onTap: () {
                                                selectOldImages(
                                                    'gallery',
                                                    formDataList
                                                        .elementAt(
                                                        index));
                                              },
                                              child: Container(
                                                child: const Icon(
                                                  Icons.image,
                                                  color: Colors.black,
                                                ),
                                              )),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),

                                  SizedBox(
                                    height: formDataList
                                        .elementAt(index)
                                        .oldImages
                                        .isNotEmpty
                                        ? 80
                                        : 0,
                                    width:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                    child: ListView.builder(
                                      physics:
                                      const AlwaysScrollableScrollPhysics(
                                          parent:
                                          BouncingScrollPhysics()),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: formDataList
                                          .elementAt(index)
                                          .oldImages
                                          .length,
                                      itemBuilder: (BuildContext context,
                                          int ImageIndex) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              right: 6, left: 6),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                child: Container(
                                                    height: 80,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            0),
                                                        color: Colors
                                                            .grey[200]),
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                            MaterialPageRoute(
                                                                builder: (c) =>
                                                                    ImageScreen(
                                                                      index:
                                                                      ImageIndex,
                                                                      image:
                                                                      ClipRRect(
                                                                        borderRadius: BorderRadius
                                                                            .circular(
                                                                            0.0),
                                                                        child: Image
                                                                            .file(
                                                                          File(
                                                                              formDataList
                                                                                  .elementAt(
                                                                                  index)
                                                                                  .oldImages
                                                                                  .elementAt(
                                                                                  ImageIndex)),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    )));
                                                      },
                                                      child: ClipRRect(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            0.0),
                                                        child: Image.file(
                                                          File(formDataList
                                                              .elementAt(
                                                              index)
                                                              .oldImages
                                                              .elementAt(
                                                              ImageIndex)),
                                                          fit: BoxFit
                                                              .cover,
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                              Positioned(
                                                right: -0,
                                                top: -0,
                                                child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        formDataList
                                                            .elementAt(
                                                            index)
                                                            .oldImages
                                                            .removeAt(
                                                            ImageIndex);
                                                      });
                                                    },
                                                    child: const Icon(
                                                      Icons.cancel,
                                                      color: MyAppTheme
                                                          .primaryRed,
                                                    )),
                                              ),
                                              Positioned(
                                                left: 6,
                                                top: 6,
                                                child: InkWell(
                                                    onTap: () {
                                                      if (formDataList
                                                          .elementAt(
                                                          index)
                                                          .oldImages
                                                          .length >
                                                          1) {
                                                        String imagePath =
                                                        formDataList
                                                            .elementAt(
                                                            index)
                                                            .oldImages[ImageIndex];
                                                        setState(() {
                                                          formDataList
                                                              .elementAt(
                                                              index)
                                                              .oldImages
                                                              .removeAt(
                                                              ImageIndex);
                                                          formDataList
                                                              .elementAt(
                                                              index)
                                                              .oldImages
                                                              .insert(0,
                                                              imagePath);
                                                        });
                                                      }
                                                    },
                                                    child: Icon(
                                                      ImageIndex == 0
                                                          ? Icons.star
                                                          : Icons
                                                          .star_border_outlined,
                                                      color: MyAppTheme
                                                          .primaryRed,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

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
                                            "Please select new images",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                              onTap: () {
                                                selectNewImages(
                                                    'camera',
                                                    formDataList
                                                        .elementAt(
                                                        index));
                                              },
                                              child: Container(
                                                child: const Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.black,
                                                ),
                                              )),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          InkWell(
                                              onTap: () {
                                                selectNewImages(
                                                    'gallery',
                                                    formDataList
                                                        .elementAt(
                                                        index));
                                              },
                                              child: Container(
                                                child: const Icon(
                                                  Icons.image,
                                                  color: Colors.black,
                                                ),
                                              )),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: formDataList
                                        .elementAt(index)
                                        .newImages
                                        .isNotEmpty
                                        ? 80
                                        : 0,
                                    width:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                    child: ListView.builder(
                                      physics:
                                      const AlwaysScrollableScrollPhysics(
                                          parent:
                                          BouncingScrollPhysics()),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: formDataList
                                          .elementAt(index)
                                          .newImages
                                          .length,
                                      itemBuilder: (BuildContext context,
                                          int ImageIndex) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              right: 6, left: 6),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                child: Container(
                                                    height: 80,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            0),
                                                        color: Colors
                                                            .grey[200]),
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                            MaterialPageRoute(
                                                                builder: (c) =>
                                                                    ImageScreen(
                                                                      index:
                                                                      ImageIndex,
                                                                      image:
                                                                      ClipRRect(
                                                                        borderRadius: BorderRadius
                                                                            .circular(
                                                                            0.0),
                                                                        child: Image
                                                                            .file(
                                                                          File(
                                                                              formDataList
                                                                                  .elementAt(
                                                                                  index)
                                                                                  .newImages
                                                                                  .elementAt(
                                                                                  ImageIndex)),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    )));
                                                      },
                                                      child: ClipRRect(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            0.0),
                                                        child: Image.file(
                                                          File(formDataList
                                                              .elementAt(
                                                              index)
                                                              .newImages
                                                              .elementAt(
                                                              ImageIndex)),
                                                          fit: BoxFit
                                                              .cover,
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                              Positioned(
                                                right: -0,
                                                top: -0,
                                                child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        formDataList
                                                            .elementAt(
                                                            index)
                                                            .newImages
                                                            .removeAt(
                                                            ImageIndex);
                                                      });
                                                    },
                                                    child: const Icon(
                                                      Icons.cancel,
                                                      color: MyAppTheme
                                                          .primaryRed,
                                                    )),
                                              ),
                                              Positioned(
                                                left: 6,
                                                top: 6,
                                                child: InkWell(
                                                    onTap: () {
                                                      if (formDataList
                                                          .elementAt(
                                                          index)
                                                          .newImages
                                                          .length >
                                                          1) {
                                                        String imagePath =
                                                        formDataList
                                                            .elementAt(
                                                            index)
                                                            .newImages[ImageIndex];
                                                        setState(() {
                                                          formDataList
                                                              .elementAt(
                                                              index)
                                                              .newImages
                                                              .removeAt(
                                                              ImageIndex);
                                                          formDataList
                                                              .elementAt(
                                                              index)
                                                              .newImages
                                                              .insert(0,
                                                              imagePath);
                                                        });
                                                      }
                                                    },
                                                    child: Icon(
                                                      ImageIndex == 0
                                                          ? Icons.star
                                                          : Icons
                                                          .star_border_outlined,
                                                      color: MyAppTheme
                                                          .primaryRed,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
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
                                    setState(() {
                                      pressedItems[index + 1] = true;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                      foregroundColor:
                                      MyAppTheme.primaryRed,
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
      ]),
    );
  }

  void selectOldImages(String type, FormItem item) async {
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
        setState(() {
          item.oldImages.add(croppedFile.path);
        });
      }
    }
  }

  void selectNewImages(String type, FormItem item) async {
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
        setState(() {
          item.newImages.add(croppedFile.path);
        });
      }
    }
  }

  void selectRequisitionImages(String type) async {
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
        setState(() {
          requisitionImages.clear();
          requisitionImages.insert(0,croppedFile.path);
        });
      }
    }
  }

  void selectTestsImages(String type) async {
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
        setState(() {
          testsProjectImages.add(croppedFile.path);
        });
      }
    }
  }

  void selectDnnImage(String type) async {
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
        setState(() {
          deliverNoteNumberImage = croppedFile.path;
        });
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
