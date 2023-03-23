import 'dart:async';
import  'dart:convert';
import 'dart:io';
import 'package:auto_lubumbashi/models/FormData.dart';
import 'package:auto_lubumbashi/models/FormInput.dart';
import 'package:auto_lubumbashi/view_models/form_input_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
part 'forms_event.dart';

part 'forms_state.dart';

class FormsBloc extends Bloc<FormsEvent, FormsState> {
  FormsBloc() : super(FormsInitial()) {
    on<SavedFormsInitialEvent>((event, emit) async {
      List<FormData> forms = await allForms();
      List<FormInput> inputs = await allInputs();
      List<FormInputViewModel> formsInputs = [];


      for(var form in forms){

        FormInput input = inputs.where((element) => element.inputId == form.inputId).first;

        FormInputViewModel viewModel = FormInputViewModel(formData: form, formInput: input);
        formsInputs.add(viewModel);
      }
      emit(SavedFormsSuccessState(formsInputs: formsInputs.reversed.toList()));

    });



    on<DeleteFormEvent>((event, emit) async {
        List<FormData> forms = await allForms();
        forms.removeWhere((element) => element.formId == event.formId);
        if(await writeForms(forms)){
          ScaffoldMessenger.of(event.context).showSnackBar(const SnackBar(

          backgroundColor: Colors.green
          ,content: Text("Deleted Successfully",style: TextStyle(color: Colors.white),)));
        }else{
          ScaffoldMessenger.of(event.context).showSnackBar(const SnackBar(

              backgroundColor: Colors.red
              ,content: Text("Delete Failed, please try again.",style: TextStyle(color: Colors.white),)));
        }
        add(SavedFormsInitialEvent());

    });
  }

  static FormsBloc instance(context) => BlocProvider.of(context);

  Future<List<FormData>> allForms() async {
    var rootPath = await getApplicationDocumentsDirectory();
    File forms = File("${rootPath.path}/forms.json");
    //read forms in string var
    String formsDataString = forms.readAsStringSync();
    //convert the json list into FormData List
    Iterable iter = jsonDecode(formsDataString);
    //data list is all forms in forms.json
    List<FormData> formsDataList =
        List<FormData>.from(iter.map((model) => FormData.fromJson(model)));
    return formsDataList;
  }

  Future<List<FormInput>> allInputs() async {
    var rootPath = await getApplicationDocumentsDirectory();
    File file = File("${rootPath.path}/inputs.json");
    String jsonData = file.readAsStringSync();
    Iterable iterData = jsonDecode(jsonData);
    List<FormInput> inputsList = List<FormInput>.from(
        iterData.map((model) => FormInput.fromJson(model)));
    return inputsList;
  }
  Future<bool> writeForms(List<FormData> forms) async {
    try{
      var rootPath = await getApplicationDocumentsDirectory();
      File file = File("${rootPath.path}/forms.json");
      file.writeAsString(jsonEncode(forms));
      return true;
    }catch(e,s){
      print( s);
      return false;
    }


  }
}
