import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:http/http.dart' as http;

import 'model.dart';

class DropdownEff extends StatefulWidget {
  const DropdownEff({super.key});

  @override
  State<DropdownEff> createState() => _DropdownEffState();
}

Future<List<Suggestion>> getData() async {
  final response =
      await http.get(Uri.parse('http://10.0.2.2:8080/api/suggest'));
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body) as List<dynamic>;
    return data.map((json) => Suggestion.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}

class _DropdownEffState extends State<DropdownEff> {
  String selectedValue = "Breakfast";
  String selectedIcon = "";
  TextEditingController textEditingController = TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();

  List<Suggestion> suggestions = [];

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "Breakfast", child: Text("Breakfast")),
      const DropdownMenuItem(value: "Lunch", child: Text("Lunch")),
      const DropdownMenuItem(value: "Supper", child: Text("Supper")),
      const DropdownMenuItem(value: "Dinner", child: Text("Dinner")),
    ];
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Dropdown",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 100, right: 100),
            child: InputDecorator(
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(15),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  style: const TextStyle(color: Colors.amber, fontSize: 30),
                  dropdownColor: Colors.green,
                  isDense: true,
                  value: selectedValue,
                  isExpanded: true,
                  menuMaxHeight: 250,
                  items: dropdownItems,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue!;
                    });
                    _updateSelectedIcon(newValue);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(
                icon: CupertinoIcons.sunrise,
                backgroundColor:
                    selectedIcon == "Breakfast" ? Colors.orange : Colors.yellow,
                onPressed: () {
                  _handleIconPress("Breakfast");
                },
              ),
              const SizedBox(width: 20),
              _buildIconButton(
                icon: CupertinoIcons.sun_max,
                backgroundColor:
                    selectedIcon == "Lunch" ? Colors.orange : Colors.yellow,
                onPressed: () {
                  _handleIconPress("Lunch");
                },
              ),
              const SizedBox(width: 20),
              _buildIconButton(
                icon: CupertinoIcons.sunset,
                backgroundColor:
                    selectedIcon == "Supper" ? Colors.orange : Colors.yellow,
                onPressed: () {
                  _handleIconPress("Supper");
                },
              ),
              const SizedBox(width: 20),
              _buildIconButton(
                icon: CupertinoIcons.moon,
                backgroundColor:
                    selectedIcon == "Dinner" ? Colors.orange : Colors.yellow,
                onPressed: () {
                  _handleIconPress("Dinner");
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<Suggestion>>(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                suggestions = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AutoCompleteTextField(
                    key: key,
                    controller: textEditingController,
                    suggestions: suggestions
                        .map((suggestion) => suggestion.name)
                        .toList(),
                    clearOnSubmit: false,
                    decoration: InputDecoration(
                      labelText: 'Search...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.all(15),
                    ),
                    itemFilter: (suggestions, query) {
                      return suggestions
                          .toLowerCase()
                          .startsWith(query.toLowerCase());
                    },
                    itemSorter: (a, b) {
                      return a.compareTo(b);
                    },
                    itemSubmitted: (suggestions) {
                      setState(() {
                        textEditingController.text = suggestions;
                      });
                    },
                    itemBuilder: (context, suggestions) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AutoSizeText(suggestions),
                      );
                    },
                  ),
                );
              } else {
                return Container(); // Placeholder for other states
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return CupertinoButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: backgroundColor,
        ),
        child: Icon(icon),
      ),
    );
  }

  void _handleIconPress(String iconName) {
    setState(() {
      selectedIcon = iconName;
    });
    _updateSelectedValue(iconName);
  }

  void _updateSelectedValue(String iconName) {
    switch (iconName) {
      case "Breakfast":
        selectedValue = "Breakfast";
        break;
      case "Lunch":
        selectedValue = "Lunch";
        break;
      case "Supper":
        selectedValue = "Supper";
        break;
      case "Dinner":
        selectedValue = "Dinner";
        break;
    }
  }

  void _updateSelectedIcon(String? selectedDropdownValue) {
    switch (selectedDropdownValue) {
      case "Breakfast":
        selectedIcon = "Breakfast";
        break;
      case "Lunch":
        selectedIcon = "Lunch";
        break;
      case "Supper":
        selectedIcon = "Supper";
        break;
      case "Dinner":
        selectedIcon = "Dinner";
        break;
    }
  }
}

void main() {
  runApp(const MaterialApp(
    home: DropdownEff(),
  ));
}
