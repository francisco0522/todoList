import 'package:flutter/material.dart';
import 'package:amplify_api/amplify_api.dart';
import 'amplifyconfiguration.dart';
import 'package:amplify_core/amplify_core.dart';
import 'dart:convert';

class TodoListStatePage extends StatefulWidget {
  @override
  _TodoListStatePage createState() => _TodoListStatePage();
}

class _TodoListStatePage extends State<TodoListStatePage> {
  List<String> _todoItems = [];
  List<String> _todoItemsStatus = [];
  List<String> _todoItemsId = [];

  Amplify amplifyInstance = Amplify();

  @override
  void initState() {
    super.initState();

    //amplify is configured on startup and start the plugin API appSync
    AmplifyAPI api = AmplifyAPI();
    amplifyInstance.addPlugin(apiPlugins: [api]);
    amplifyInstance.configure(amplifyconfig);

    getList();
  }

  //Get all documents of the DataBase
  getList() async {
    try {
      String graphQLDocument = '''query ListTodos {
      listTodos {
        items {
          id
          name
          description
        }
        nextToken
      }
    }''';

      var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
        document: graphQLDocument,
      ));

      var response = await operation.response;
      var data = response.data;
      Map result = json.decode(response.data);

      for (int i = 0; i < result["listTodos"]["items"].length; i++) {
        _addTodoItem(
            result["listTodos"]["items"][i]["name"],
            result["listTodos"]["items"][i]["description"],
            result["listTodos"]["items"][i]["id"]);
      }

      print('Query result: ' + data);
      print('Data lenght: ' + result["listTodos"]["items"].length.toString());
    } catch (e) {
      print(e);
    }
  }

  // Add the tasks in a list to show in the interface
  void _addTodoItem(String task, String status, String id) {
    // Only add the task if the user actually entered something
    if (task.length > 0) {
      setState(() => _todoItems.add(task));
      setState(() => _todoItemsStatus.add(status));
      setState(() => _todoItemsId.add(id));
    }
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Todo List')),
      body: _buildTodoList(),
      floatingActionButton: new FloatingActionButton(
          onPressed:
              _pushAddTodoScreen, 
          tooltip: 'Add task',
          child: new Icon(Icons.add)),
    );
  }

  void _pushAddTodoScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(

        new MaterialPageRoute(builder: (context) {
      return new Scaffold(
          appBar: new AppBar(title: new Text('Add a new task')),
          body: new TextField(
            autofocus: true,
            onSubmitted: (val) async {
              try {
                String graphQLDocument =
                    '''mutation CreateTodo(\$name: String!, \$description: String) {
              createTodo(input: {name: \$name, description: \$description}) {
                id
                name
                description
              }
        }''';
                var variables = {
                  "name": val,
                  "description": "Pending",
                };
                var request = GraphQLRequest<String>(
                    document: graphQLDocument, variables: variables);

                var operation = Amplify.API.mutate(request: request);
                var response = await operation.response;

                var data = response.data;
                Map result = json.decode(response.data);

                print('Mutation result: ' + data);

                _addTodoItem(val, result["createTodo"]["description"],
                    result["createTodo"]["id"]);
              } catch (error) {
                print('Mutation failed: $error');
              }
              Navigator.pop(context); // Close the add todo screen
            },
            decoration: new InputDecoration(
                hintText: 'Enter something to do...',
                contentPadding: const EdgeInsets.all(16.0)),
          ));
    }));
  }

  //Update the status of the tasks to Done or Pending
  _changeTodoItemsStatus(int index) async {
    if (_todoItemsStatus[index] == "Pending") {
      print(_todoItemsId[index]);
      setState(() => _todoItemsStatus[index] = "Done");
    } else if (_todoItemsStatus[index] == "Done") {
      setState(() => _todoItemsStatus[index] = "Pending");
    }
    try {
      String graphQLDocument =
          '''mutation UpdateTodo(\$description: String, \$id: ID!, \$name: String!) {
  updateTodo(input: {description: \$description, id: \$id, name: \$name, }) {
    id
  }
}''';
      var variables = {
        "id": _todoItemsId[index],
        "name": _todoItems[index],
        "description": _todoItemsStatus[index],
      };
      var request = GraphQLRequest<String>(
          document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data;

      print('Mutation result: ' + data);
    } catch (error) {
      print('Mutation failed: $error');
    }
  }

// remove the item from the list and the database
  void _removeTodoItem(int index) async {
    setState(() => _todoItems.removeAt(index));
    setState(() => _todoItemsStatus.removeAt(index));
    try {
      String graphQLDocument =
          '''mutation DeleteTodo(\$id: ID!) {
  deleteTodo(input: {id: \$id }) {
    id
  }
}''';
      var variables = {
        "id": _todoItemsId[index],
      };
      var request = GraphQLRequest<String>(
          document: graphQLDocument, variables: variables);

      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;

      var data = response.data;

      print('Mutation result: ' + data);
    } catch (error) {
      print('Mutation failed: $error');
    }
  }

// Show an alert dialog asking the user to confirm that the task is done or to delete
  void _promptRemoveTodoItem(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: _todoItemsStatus[index] == "Pending"
                  ? new Text('Mark "${_todoItems[index]}" as done?')
                  : new Text('Mark "${_todoItems[index]}" as pending?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop()),
                if (_todoItemsStatus[index] == "Pending")
                  new FlatButton(
                      child: new Text('MARK AS DONE'),
                      onPressed: () {
                        _changeTodoItemsStatus(index);
                        Navigator.of(context).pop();
                      }),
                if (_todoItemsStatus[index] == "Done")
                  new FlatButton(
                      child: new Text('MARK AS PENDING'),
                      onPressed: () {
                        _changeTodoItemsStatus(index);
                        Navigator.of(context).pop();
                      }),
                new FlatButton(
                    child: new Text('DELETE'),
                    onPressed: () {
                      _removeTodoItem(index);
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  Widget _buildTodoList() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        if (index < _todoItems.length) {
          return _buildTodoItem(
              _todoItems[index], _todoItemsStatus[index], index);
        }
      },
    );
  }

  Widget _buildTodoItem(String todoText, String todoStatus, int index) {
    return new ListTile(
      title: new Text(todoText),
      onTap: () => _promptRemoveTodoItem(index),
      trailing: todoStatus == "Pending"
          ? Icon(Icons.check_box_outline_blank)
          : Icon(Icons.check_box),
    );
  }
}
