part of 'forms_bloc.dart';

@immutable
abstract class FormsState {}

class FormsInitial extends FormsState {}
class FormsLoadingState extends FormsState {}
class FormsEmptyListState extends FormsState {}
class SavedFormsSuccessState extends FormsState {
  List<FormInputViewModel> formsInputs;
  SavedFormsSuccessState({required this.formsInputs});
}
