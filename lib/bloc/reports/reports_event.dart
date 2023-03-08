part of 'reports_bloc.dart';

@immutable
abstract class ReportsEvent {}

class ReportScreenInitialEvent extends ReportsEvent {}

class GenerateReportEvent extends ReportsEvent {
  FormInputViewModel formInputViewModel;
  BuildContext context;
  GenerateReportEvent(
      {required this.formInputViewModel, required this.context});
}
class DeleteReportEvent extends ReportsEvent{
  String reportPath;
  DeleteReportEvent(this.reportPath);
}