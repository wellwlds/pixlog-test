import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TranslateService {
  getResources(context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? resources = prefs.getString('resources');

    if (resources.toString() != "null") {
      return jsonDecode(resources!);
    }
    var client = http.Client();
    try {
      var response = await http.get(
        Uri.parse('http://portal.greenmilesoftware.com/get_resources_since'),
      );
      prefs.setString('resources', utf8.decode(response.bodyBytes));
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Ops"),
          content: const Text(
              'Não foi possivel acessar a lista de traduções, tente mais tarde'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ok",style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
          ],
        ),
      );
      return [];
    } finally {
      client.close();
    }
  }

  cleanLocalResources() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('resources');
  }

  searchResource(resources,searchName,filterName) {
    var filteredResources = [];
    for(int i=0;i<resources.length;i++){
      if(resources[i]["resource"][filterName].toLowerCase().contains(searchName.toLowerCase())) {
        filteredResources.add(resources[i]);
      }
    }
    return filteredResources;
  }

  organizeFilters(resources) {
    List<String> languageList = ["Selecione"];
    List<String> moduleList = ["Selecione"];
    for(int i=0;i<resources.length;i++){
      languageList.add(resources[i]["resource"]["language_id"].toUpperCase());
      moduleList.add(resources[i]["resource"]["module_id"]);
    }
    return {
      "languageList": languageList.toSet().toList(),
      "moduleList": moduleList.toSet().toList()
    };
  }
}