import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

import 'model.dart';

class DropdownEff extends StatefulWidget {
  const DropdownEff({super.key});

  @override
  State<DropdownEff> createState() => _DropdownEffState();
}

Future<List<Suggestion>> getData(int page, int size) async {
  final response = await http
      .get(Uri.parse('http://10.0.2.2:8080/api/suggest?page=0 & size=38'));
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    print(data['content']);

    List<Suggestion> result = data['content']
        .map((json) => Suggestion.fromJson(json))
        .toList()
        .cast<Suggestion>();
    return result;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<void> postData({
  required String date,
  required String dropdownValue,
  required String searchData,
}) async {
  const apiUrl = 'http://10.0.2.2:8080/api/mealdata';

  final Map<String, dynamic> data = {
    'date': date,
    'dropdownValue': dropdownValue,
    'searchData': searchData,
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Successfully posted data
      print('Data submitted successfully');
      // You can add further handling based on your API response
    } else {
      // Handle error or unsuccessful response
      print('Error submitting data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    // Handle exceptions
    print('Exception occurred: $e');
  }
}

class _DropdownEffState extends State<DropdownEff> {
  String selectedValue = "Breakfast";
  String selectedIcon = "";
  TextEditingController textEditingController = TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  final TextEditingController _dateContoller = TextEditingController();
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

  int currpage = 0;
  int pagesize = 38;
  bool isloadingMore = false;
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
            height: 2,
          ),
          const SizedBox(height: 2),
          // Add the TextField in the center of the screen
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: TextField(
                controller: _dateContoller,
                decoration: InputDecoration(
                  labelText: 'Date...',
                  filled: true,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(15),
                ),
                readOnly: true,
                onTap: () {
                  selectDate();
                },
              ),
            ),
          ),
          const SizedBox(height: 3),
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
            height: 2,
          ),
          const SizedBox(height: 2),
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

          const SizedBox(height: 3),

          FutureBuilder<List<Suggestion>>(
            future: getData(0, 10),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                suggestions = snapshot.data!;
                print("Suggestions: $suggestions");

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TypeAheadField<Suggestion>(
                    builder: (
                      context,
                      controller,
                      focusnode,
                    ) {
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusnode,
                        decoration: InputDecoration(
                          labelText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.all(15),
                        ),
                      );
                    },
                    suggestionsCallback: (pattern) async {
                      final filteredSuggestions = suggestions
                          .where((suggestion) => suggestion.name
                              .toLowerCase()
                              .startsWith(pattern.toLowerCase()))
                          .toList();
                      return filteredSuggestions;
                    },
                    itemBuilder: (context, Suggestion suggestion) {
                      return ListTile(
                        title: Text(suggestion.name),
                      );
                    },
                    onSelected: (suggestion) {
                      setState(() {
                        textEditingController.text = suggestion.name;
                      });
                    },
                  ),
                );
              } else {
                return Container(); // Placeholder for other states
              }
            },
          ),

          const SizedBox(height: 2),
          ElevatedButton(
            onPressed: () {
              postData(
                date: _dateContoller.text,
                dropdownValue: selectedValue,
                searchData: textEditingController.text,
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateContoller.text = picked.toString().split(" ")[0];
      });
    }
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

  Future<void> loadMoreData() async {
    setState(() {
      isloadingMore = true;
    });

    List<Suggestion> moreData = await getData(currpage + 1, pagesize);

    setState(() {
      suggestions.addAll(moreData);
      currpage++;
      isloadingMore = false;
    });
  }
}

void main() {
  runApp(const MaterialApp(
    home: DropdownEff(),
  ));
}
