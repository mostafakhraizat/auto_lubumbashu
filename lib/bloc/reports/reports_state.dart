part of 'reports_bloc.dart';

@immutable
abstract class ReportsState {}

class ReportsInitial extends ReportsState {}
class ReportsListSuccessState extends ReportsState {
  List<Report> reports;
  ReportsListSuccessState(this.reports);
}
