part of 'todo_cubit.dart';

@immutable
abstract class TodoState {}

class TodoInitial extends TodoState {}

class TodoChangeBottomNavBarState extends TodoState {}

class TodoCreateDataBaseState extends TodoState {}

class TodoInsertToDataBaseState extends TodoState {}

class TodoGetDataFromDatabaseState extends TodoState {}

class TodoUpDataDatabaseState extends TodoState {}

class TodoDeleteDataState extends TodoState {}

class TodoChangeBottomSheetState extends TodoState {}

class TodoGetDatabaseLoadingState extends TodoState {}
