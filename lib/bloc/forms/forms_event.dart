part of 'forms_bloc.dart';

@immutable
abstract class FormsEvent {}
class SavedFormsInitialEvent extends FormsEvent{

}class DeleteFormEvent extends FormsEvent{
  final int formId;
  final BuildContext context;
  DeleteFormEvent(this.formId,this.context);

}