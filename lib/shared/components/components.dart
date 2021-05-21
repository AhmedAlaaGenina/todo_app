import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/todo_cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  bool isUpperCase = true,
  double radius = 3.0,
  @required Function function,
  @required String text,
}) =>
    Container(
      width: width,
      height: 50.0,
      child: MaterialButton(
        onPressed: function,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          radius,
        ),
        color: background,
      ),
    );

Widget defaultFormField({
  @required TextEditingController controller,
  @required TextInputType type,
  Function onSubmit,
  Function onChange,
  Function onTap,
  bool isPassword = false,
  @required Function validate,
  @required String label,
  @required IconData prefix,
  IconData suffix,
  bool isClickable = true,
}) =>
    TextFormField(
      enabled: isClickable,
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      validator: validate,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
        suffixIcon: suffix != null
            ? Icon(
                suffix,
              )
            : null,
        border: OutlineInputBorder(),
      ),
    );

class BuildTaskItem extends StatelessWidget {
  final Map model;

  const BuildTaskItem(this.model);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(model['id'].toString()),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (directions) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Are you sure?"),
          content: Text("Do you Want to remove it?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("NO"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Yes"),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        TodoCubit.get(context).deleteData(id: model['id']);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text('${model['time']}'),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${model['title']}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${model['date']}",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            IconButton(
              onPressed: () {
                TodoCubit.get(context)
                    .updateDataBase(status: "done", id: model['id']);
              },
              icon: Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
            IconButton(
              onPressed: () {
                TodoCubit.get(context)
                    .updateDataBase(status: "archived", id: model['id']);
              },
              icon: Icon(
                Icons.archive_outlined,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TasksBuilder extends StatelessWidget {
  const TasksBuilder({
    Key key,
    @required this.tasks,
  }) : super(key: key);

  final List<Map> tasks;

  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
      condition: tasks.length > 0,
      builder: (context) {
        return ListView.separated(
          itemBuilder: (context, index) => BuildTaskItem(tasks[index]),
          itemCount: tasks.length,
          separatorBuilder: (context, index) => Divider(),
        );
      },
      fallback: (context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu,
                size: 100,
                color: Colors.grey,
              ),
              Text(
                "No Tasks Yet, please Add Tasks",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
