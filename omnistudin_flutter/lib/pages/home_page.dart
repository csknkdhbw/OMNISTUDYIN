import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';
import '../register/login.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

String jwtToken =
    'your_initial_token'; // Replace 'your_initial_token' with the actual JWT token

Future<List<AdGroup>> fetchAdGroups() async {
  final response =
      await http.get(Uri.parse('http://localhost:8000/get_adgroups/'));

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<AdGroup> adGroups =
        List<AdGroup>.from(l.map((model) => AdGroup.fromJson(model)));
    return adGroups;
  } else {
    throw Exception('Failed to load AdGroups');
  }
}

Future<AdGroup> createAdGroup(String name, String description) async {
  final response = await http.post(
    Uri.parse('http://localhost:8000/create_adgroup/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken',
    },
    body: jsonEncode(<String, String>{
      'name': name,
      'description': description,
    }),
  );

  if (response.statusCode == 200) {
    return AdGroup.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create AdGroup');
  }
}

Future<void> updateAdGroup(
    String oldName, String newName, String description) async {
  final response = await http.put(
    Uri.parse('http://localhost:8000/change_adgroup/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken',
    },
    body: jsonEncode(<String, String>{
      'old_name': oldName,
      'new_name': newName,
      'description': description,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update AdGroup');
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showSearchBar = false;
  List<AdGroup> _adGroups = [];

  @override
  void initState() {
    super.initState();
    fetchAdGroups().then((value) => setState(() {
          _adGroups = value;
        }));
  }

  void _addNewAdGroup(String name, String description) async {
    print('Adding new ad group');
    var token = await FrontendToBackendConnection.getToken();
    print('Got token: $token');
    await FrontendToBackendConnection.addNewAdGroup(name, description, token);
    print('Added new ad group');
    await Future.delayed(Duration(seconds: 2)); // Wait for 2 seconds
    List<AdGroup> adGroups =
        await FrontendToBackendConnection.fetchAdGroups(token!);
    print('Fetched ad groups: $adGroups');
    setState(() {
      _adGroups = adGroups;
    });
    print('Updated state with new ad groups');
  }

  void _deleteAdGroup(int index, String name) async {
    var token = await FrontendToBackendConnection.getToken();
    try {
      await FrontendToBackendConnection.deleteAdGroup(context, index, name);
      await Future.delayed(Duration(seconds: 2)); // Wait for 2 seconds
      List<AdGroup> adGroups =
          await FrontendToBackendConnection.fetchAdGroups(token!);
      print('Fetched ad groups: $adGroups');
      setState(() {
        _adGroups = adGroups;
      });
      print('Updated state with new ad groups');
    } catch (e) {
      print('Error deleting AdGroup: $e');
      if (e is http.ClientException && e.message.contains('<!DOCTYPE html>')) {
        print('Server returned an HTML response: ${e.message}');
      } else if (e is http.ClientException && e.message.contains('404')) {
        // Handle 403 error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('You are not authorized to delete this ad group')),
        );
      } else {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete ad group')),
        );
      }
    }
  }

  void updateAdGroup(
      int index, String oldName, String newName, String description) async {
    var token = await FrontendToBackendConnection.getToken();
    try {
      await FrontendToBackendConnection.getAdGroup(
          index, oldName, newName, description);
      await Future.delayed(Duration(seconds: 2)); // Wait for 2 seconds
      List<AdGroup> adGroups =
          await FrontendToBackendConnection.fetchAdGroups(token!);
      print('Fetched ad groups: $adGroups');
      setState(() {
        _adGroups = adGroups;
      });
      print('Updated state with new ad groups');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update ad group')),
      );
    }
  }

  void clearLocalStorage() async {
    await FrontendToBackendConnection.clearStorage();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar ? TextField() : Text('Home'),
        leading: IconButton(
          icon: Icon(Icons.add),
          onPressed: () async {
            final newAdGroup = await showDialog<AdGroup>(
              context: context,
              builder: (context) => CreateAdGroupDialog(),
            );
            if (newAdGroup != null) {
              _addNewAdGroup(newAdGroup.name, newAdGroup.description);
            }
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _adGroups.length,
        itemBuilder: (context, index) {
          final adGroup = _adGroups[index];
          return Card(
            child: ListTile(
              title: Text(adGroup.name),
              subtitle: Text(adGroup.description),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'Change') {
                    final updatedAdGroup = await showDialog<AdGroup>(
                      context: context,
                      builder: (context) => UpdateAdGroupDialog(
                        oldName: adGroup.name,
                        oldDescription: adGroup.description,
                      ),
                    );
                    if (updatedAdGroup != null) {
                      updateAdGroup(index, adGroup.name, updatedAdGroup.name,
                          updatedAdGroup.description);
                    }
                  } else if (value == 'Delete') {
                    _deleteAdGroup(index, adGroup.name);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'Change',
                    child: Text('Change'),
                  ),
                  PopupMenuItem(
                    value: 'Delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CreateAdGroupDialog extends StatefulWidget {
  @override
  _CreateAdGroupDialogState createState() => _CreateAdGroupDialogState();
}

class _CreateAdGroupDialogState extends State<CreateAdGroupDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Post'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(AdGroup(
              name: _nameController.text,
              description: _descriptionController.text,
            ));
          },
          child: Text('Create'),
        ),
      ],
    );
  }
}

class UpdateAdGroupDialog extends StatefulWidget {
  final String oldName;
  final String oldDescription;

  const UpdateAdGroupDialog({
    required this.oldName,
    required this.oldDescription,
  });

  @override
  _UpdateAdGroupDialogState createState() => _UpdateAdGroupDialogState();
}

class _UpdateAdGroupDialogState extends State<UpdateAdGroupDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.oldName);
    _descriptionController = TextEditingController(text: widget.oldDescription);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Ad Group'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(AdGroup(
              name: _nameController.text,
              description: _descriptionController.text,
            ));
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => FrontendToBackendConnection(),
    child: MaterialApp(
      home: HomePage(),
    ),
  ));
}
