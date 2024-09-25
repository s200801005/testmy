// Translated from Kotlin to Dart (Flutter framework)

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:your_package_name/your_topic_structure.dart'; // Adjust the path as necessary
import 'package:your_package_name/api.dart'; // Adjust the path as necessary

class TopicFragment extends StatefulWidget {
  @override
  _TopicFragmentState createState() => _TopicFragmentState();
}

class _TopicFragmentState extends State<TopicFragment> {
  int type = 1;
  String apiUrl;

  @override
  void initState() {
    super.initState();
    apiUrl = getApiUrl();
    fetchData();
  }

  String getApiUrl() {
    // Assuming you have a method to get the string resource
    return '${CMApi.myHostApiUrl}/${arguments["path"]}/$type/$offset'; // Define offset appropriately
  }

  void fetchData() async {
    setProgress(5);
    final response = await http.get(Uri.parse(apiUrl));
    
    if (response.statusCode == 200) {
      setProgress(10);
      final data = jsonDecode(response.body);
      TopicStructure topicStructure = TopicStructure.fromJson(data);
      
      if (topicStructure != null) {
        setProgress(15);
        setState(() {
          // Assuming you have a way to set toolbar title
          // Replace with appropriate way to set title in Flutter
          // toolbarTitle = topicStructure.results.title;
          ftttime.text = topicStructure.results.datetimeCreated;
          fttintro.text = topicStructure.results.intro;
          type = topicStructure.results.type;
        });
      }
    }
  }

  void setProgress(int progress) {
    // Implement your progress setting logic here
  }

  @override
  Widget build(BuildContext context) {
    // Build your widget tree here
    return Container(); // Adjust as necessary
  }
}