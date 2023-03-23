import 'dart:convert';
import 'dart:io';
import 'package:auto_lubumbashi/ui/forms/screens/create_form_screen.dart';
import 'package:auto_lubumbashi/utils/constants.dart';
import 'package:auto_lubumbashi/models/FormInput.dart';
import 'package:auto_lubumbashi/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FormInputScreen extends StatefulWidget {
  const FormInputScreen({Key? key}) : super(key: key);

  @override
  State<FormInputScreen> createState() => _FormInputScreenState();
}

class _FormInputScreenState extends State<FormInputScreen> {
  GlobalKey<FormState> key = GlobalKey();

  TextEditingController hoseAssemblerController = TextEditingController();
  TextEditingController customerName = TextEditingController();
  TextEditingController requisitionNbController = TextEditingController();
  TextEditingController deliveryNoteNumber = TextEditingController();
  TextEditingController siteNameController = TextEditingController();
  TextEditingController dateText = TextEditingController();
  String? siteName;
  String? customer;
  String? dateSelectedString;
  DateTime? selectedDate;
  List<String>siteNames = [];
  List<String> customers = [];
  @override
  void initState() {
    siteNames = siteNamesCustomers.keys.toList();
    super.initState();
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(

      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2040),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateText.text = picked.toString().substring(0,10);
      });
    }
  }
  bool addOtherField = false;
  bool addSiteNameField = false;
  bool hideCustomer = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Report Input"),
      ),
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height - 40,
        child: SingleChildScrollView(
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                            contentPadding: const EdgeInsets.only(left: 12),
                            hintStyle: const TextStyle(color: Colors.grey),
                            hintText: 'Deliver Note Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
                        child: DropdownButtonFormField(
                          items: siteNames.map((e) => DropdownMenuItem(value: e,child: Text(e.toString()),)).toList(),
                          hint: const Text("Site Name"),
                          onChanged: (value) {
                            setState(() {
                              siteName = value.toString();
                              customer = null;
                              customers = siteNamesCustomers["$siteName"]!.toList();
                              addSiteNameField = value == "Other";
                              hideCustomer = value == "Other";
                              addOtherField = value == "Other";
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
                      Builder(
                        builder: (context) {
                          if(addSiteNameField){
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
                                  contentPadding: const EdgeInsets.only(left: 12),
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  hintText: 'Site Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Container() ;
                        }
                      ),
                      hideCustomer? Container():   Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
                        child: DropdownButtonFormField(
                           items: customers.map((e) => DropdownMenuItem(value: e,child: Text(e.toString()),)).toList(),
                          hint: const Text("Customer"),
                          onChanged: (value) {
                            setState(() {
                              customer = value.toString();
                            });
                            //
                            setState(() {
                              addOtherField = customer == "Other";
                              hideCustomer = false;
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


                      Builder(
                        builder: (context) {
                          if(addOtherField){
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
                                  contentPadding: const EdgeInsets.only(left: 12),
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  hintText: 'Customer Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            );
                          }return Container();
                        }
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
                            contentPadding: const EdgeInsets.only(left: 12),
                            hintStyle: const TextStyle(color: Colors.grey),
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
                            contentPadding: const EdgeInsets.only(left: 12),
                            hintStyle: const TextStyle(color: Colors.grey),
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
                          onTap: (){
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
                            contentPadding: const EdgeInsets.only(left: 12),
                            hintStyle: const TextStyle(color: Colors.grey),
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
                            if(key.currentState!.validate()){
                              var rootPath = await getApplicationDocumentsDirectory();
                              File file = File("${rootPath.path}/inputs.json");
                              String jsonData = file.readAsStringSync();
                              Iterable iterData = jsonDecode(jsonData);
                              List<FormInput> inputsList = List<FormInput>.from(
                                  iterData.map((model) => FormInput.fromJson(model)));
                              int id =
                              DateTime.now().millisecondsSinceEpoch;
                              FormInput input = FormInput(
                                addSiteName: addSiteNameField,
                                addCustomerName: addOtherField,
                                siteName:addSiteNameField?siteNameController.text: siteName,
                                customer:addSiteNameField?customerName.text :(addOtherField?customerName.text:customer),
                                date: dateText.text,
                                inputId: id,
                                dnn: deliveryNoteNumber.text,
                                requisitionNb: requisitionNbController.text,
                                hoseAssembler: hoseAssemblerController.text,
                              );
                              setState(() {
                                inputsList.add(input);
                              });
                              file.writeAsString(jsonEncode(inputsList));
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (c) =>   CreateFormScreen(input: input,form: null,)));
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
                              'Next',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              width: 22,
                            ),
                            Icon(
                              Icons.arrow_right_alt,
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
        ),
      ),
    );
  }

}
