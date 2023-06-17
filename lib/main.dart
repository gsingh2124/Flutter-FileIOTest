import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final TextEditingController _textEditingController = TextEditingController();
  List<String> names = [];
  File? selectedFile;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> saveNames(BuildContext context) async {
    if (selectedFile == null) return;

    final namesText = names.join('\n');
    await selectedFile!.writeAsString(namesText);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('File Saved'),
          content: Text('File saved successfully at ${selectedFile!.path}'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> loadNames(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      setState(() {
        selectedFile = file;
      });
      final loadedNames = await file.readAsLines();
      setState(() {
        names = loadedNames;
      });
    }
  }

  Future<void> saveFile(BuildContext context) async {
    if (names.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No names to save.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save File As',
      fileName: 'names.txt',
      initialDirectory: '/',
      allowedExtensions: ['.txt'],
    );

    if (result != null) {
      final file = File(result);
      setState(() {
        selectedFile = file;
      });
      saveNames(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter your name',
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    names.add(_textEditingController.text);
                    _textEditingController.clear();
                  });
                },
                child: const Text('Outlined Button'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => saveFile(context),
                child: const Text('Save'),
              ),
              ElevatedButton(
                onPressed: () => loadNames(context),
                child: const Text('Load'),
              ),
              const SizedBox(height: 16.0),
              const Text('Past Names:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              ListView.builder(
                shrinkWrap: true,
                itemCount: names.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(names[index]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
