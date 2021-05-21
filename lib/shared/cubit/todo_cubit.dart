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
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
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
        getDataFromDatabase(database);
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
        getDataFromDatabase(database);
        emit(TodoInsertToDataBaseState());
      }).catchError(
        (error) => print("Error when inserting ${error.toString()}"),
      ),
    );
  }

  void updateDataBase({
    @required String status,
    @required int id,
  }) async {
    await database.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {
      getDataFromDatabase(database);
      emit(TodoUpDataDatabaseState());
    });
  }

  void deleteData({
    @required int id,
  }) async {
    await database
        .rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database);
      emit(TodoDeleteDataState());
    });
  }

  void getDataFromDatabase(Database db) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(TodoGetDatabaseLoadingState());
    db.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'New') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      emit(TodoGetDataFromDatabaseState());
    });
  }

  void changeIndex(int index) {
    indexPage = index;
    emit(TodoChangeBottomNavBarState());
  }
}
