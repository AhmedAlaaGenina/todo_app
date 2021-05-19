import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(TodoInitial());
  Database database;
  List<Map> tasks = [];
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  static TodoCubit get(context) => BlocProvider.of(context);

  int indexPage = 0;
  void changeBottomSheetShown(
      {@required bool isShow, @required IconData icon}) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(TodoChangeBottomSheetState());
  }

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = [
    'Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void createDataBase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) async {
        print('database created');
        await database.execute(
            'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT,status TEXT)');
      },
      onOpen: (database) {
        print('database Opened');
        getDataFromDatabase(database).then((value) {
          tasks = value;
          print(tasks);
          emit(TodoGetDataFromDatabaseState());
        });
      },
    ).then((value) {
      database = value;
      emit(TodoCreateDataBaseState());
    });
  }

  insertToDataBase({
    @required String title,
    @required String date,
    @required String time,
  }) async {
    await database.transaction(
      (txn) => txn
          .rawInsert(
              'INSERT INTO tasks(title,date,time,status) VALUES("$title","$date","$time","New")')
          .then((value) {
        print("$value insert successfully");
        getDataFromDatabase(database).then((value) {
          tasks = value;
          print(tasks);
          emit(TodoGetDataFromDatabaseState());
        });
        emit(TodoInsertToDataBaseState());
      }).catchError(
        (error) => print("Error when inserting ${error.toString()}"),
      ),
    );
  }

  Future<List<Map>> getDataFromDatabase(Database db) async {
    emit(TodoGetDatabaseLoadingState());
    return await db.rawQuery('SELECT * FROM tasks');
  }

  void changeIndex(int index) {
    indexPage = index;
    emit(TodoChangeBottomNavBarState());
  }
}
