import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/components/constants.dart';
import 'package:todo_app/shared/cubit/todo_cubit.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodoCubit>(
      create: (context) => TodoCubit()..createDataBase(),
      child: BlocConsumer<TodoCubit, TodoState>(
        listener: (context, state) {},
        builder: (context, state) {
          TodoCubit cubit = TodoCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.indexPage]),
            ),
            body: ConditionalBuilder(
              builder: (context) => cubit.screens[cubit.indexPage],
              condition: state is! TodoGetDatabaseLoadingState,
              fallback: (context) => Center(
                child: CircularProgressIndicator(),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState.validate()) {
                    cubit
                        .insertToDataBase(
                      time: timeController.text,
                      date: dateController.text,
                      title: titleController.text,
                    )
                        .then((value) {
                      Navigator.pop(context);
                    });
                  }
                } else {
                  scaffoldKey.currentState
                      .showBottomSheet(
                        (context) => Container(
                          // height: MediaQuery.of(context).size.height * 0.3,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  defaultFormField(
                                    controller: titleController,
                                    type: TextInputType.text,
                                    validate: (String value) {
                                      if (value.isEmpty) {
                                        return 'title must not be empty';
                                      }
                                    },
                                    label: 'Task Title',
                                    prefix: Icons.title,
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  defaultFormField(
                                    controller: timeController,
                                    onTap: () {
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then(
                                        (value) => timeController.text =
                                            value.format(context),
                                      );
                                    },
                                    type: TextInputType.datetime,
                                    validate: (String value) {
                                      if (value.isEmpty) {
                                        return 'time must not be empty';
                                      }
                                    },
                                    label: 'Task Time',
                                    prefix: Icons.watch_later_outlined,
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  defaultFormField(
                                    controller: dateController,
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.parse("2021-12-29"),
                                      ).then((value) => dateController.text =
                                          DateFormat.yMMMd().format(value));
                                    },
                                    type: TextInputType.datetime,
                                    validate: (String value) {
                                      if (value.isEmpty) {
                                        return 'date must not be empty';
                                      }
                                    },
                                    label: 'Task date',
                                    prefix: Icons.calendar_today,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetShown(
                        isShow: false, icon: Icons.edit);

                    timeController.text = '';
                    titleController.text = '';
                    dateController.text = '';
                  });
                  cubit.changeBottomSheetShown(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.indexPage,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_circle_outline,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_outlined,
                  ),
                  label: 'Archived',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
