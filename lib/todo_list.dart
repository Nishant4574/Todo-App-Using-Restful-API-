import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'AddTodoPage.dart';

class todolist_page extends StatefulWidget {
  const todolist_page({super.key});

  @override
  State<todolist_page> createState() => _todolist_pageState();
}

class _todolist_pageState extends State<todolist_page> {
  bool isloading = true;
  List items = [];

  @override
  void initState() {
    fetchTodo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: Center(
            child: Text(
              "Todo List",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
      ),
      body:
      RefreshIndicator(
        onRefresh: fetchTodo,
        child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map;
              final id = item['_id'];
              return ListTile(
                leading: CircleAvatar(child: Text('${1 + index}')),
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(onSelected: (value) {
                  if (value == 'edit') {
                    navigateToEditAdd(item);
                  } else if (value == 'delete') {
                    deleteByid(id);
                  }
                }, itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text('Edit'),
                      value: 'edit',
                    ),
                    PopupMenuItem(
                      child: Text('Delete'),
                      value: 'delete',
                    )
                  ];
                }),
              );
            }),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigateToAdd();
        },
        label: Text('Add Todo', style: TextStyle()),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Future<void> navigateToEditAdd(Map item) async {
    final route = MaterialPageRoute(builder: (context) => AddTodoPage(todo: item, fetchTodoCallback: fetchTodo,));
    await Navigator.push(context, route);
    fetchTodo(); // Refresh the list after returning from AddTodoPage
  }

  Future<void> navigateToAdd() async {
    final route = MaterialPageRoute(builder: (context) => AddTodoPage(fetchTodoCallback: fetchTodo));
    await Navigator.push(context, route);
    fetchTodo(); // Refresh the list after returning from AddTodoPage
  }

  Future<void> deleteByid(String id) async {
    final url ='https://api.nstack.in/v1/todos/$id';
    final uri =  Uri.parse(url);
    final response  = await http.delete(uri);
    if(response.statusCode == 200){
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    }
  }

  Future<void> fetchTodo() async {
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
  }
}
