import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_number_corrector/colors.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'dart:io';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        //primarySwatch: secondaryColor,
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: NumberCorrector(),
    );
  }
}

class NumberCorrector extends StatefulWidget {
  NumberCorrector({Key? key}) : super(key: key);

  @override
  _NumberCorrectorState createState() => _NumberCorrectorState();
}

class _NumberCorrectorState extends State<NumberCorrector> {
  var numberController = TextEditingController();
  String correctNumber = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Center(
            child: Column(
              children: [
                const Text(
                  'Phone Number Corrector',
                  style: TextStyle(fontSize: 24, color: mainText),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    maxLength: 15,
                    controller: numberController,
                    decoration: const InputDecoration(
                        labelText: "Enter Phone Number",
                        labelStyle: TextStyle(color: outlineText)),
                    style: const TextStyle(color: mainText),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          correctNumber = showNumber(numberController.text);
                        });
                      },
                      child: const Text("Correct Number")),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    correctNumber,
                    style: const TextStyle(color: mainText, fontSize: 26),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: (() => readExcelFile("test.xlsx")),
                      child: const Text("Get values from excel")),
                ),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () {
                        var x = "+92 3305342368";
                        x = x.replaceAll(" ", "");
                        x.replaceAll("+", "");
                        //debugPrint(x.replaceAll(" ", ""));
                        debugPrint(x);
                      },
                      child: const Text("Remove unwanted characters")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> readExcelFile(String fileName) async {
  List<String> names = [];
  List<String> numbers = [];
  List<String> countries = [];
  List<String> otherNames = [];
  List<String> otherNumbers = [];
  List<String> otherCountries = [];

  ByteData data = await rootBundle.load("assets/test.xlsx");
  var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  var excel = Excel.decodeBytes(bytes);

  for (var table in excel.tables.keys) {
    debugPrint(table); //sheet Name
    debugPrint(excel.tables[table]!.maxCols.toString());
    debugPrint(excel.tables[table]!.maxRows.toString());
    for (var row in excel.tables[table]!.rows) {
      //1st value
      var x = row[0]!.value.toString();

      ///debugPrint(x);
      names.add(x);

      //2nd value
      var y = row[1]!.value.toString();
      //debugPrint(y);
      numbers.add(y);

      //3rd value
      var z = row[2]!.value.toString();
      //debugPrint(z);
      countries.add(z);
    }
  }

  //debugPrint("name: " + names.toString());
  //debugPrint("number: " + numbers.toString());
  //debugPrint("country: " + countries.toString());

  //format phone numbers
  formatPhoneNumbers(
      names, numbers, countries, otherNames, otherNumbers, otherCountries);

  //save in new sheet
  Sheet sheetObject = excel['formatdata'];
  sheetObject.insertRowIterables(
      [names[0], numbers[0], countries[0], "WAPI Format"], 0);

  //insert row by row - formatted numbers
  for (int i = 1; i < numbers.length; i++) {
    var wtspFormat = names[i] + ", " + numbers[i];
    sheetObject.insertRowIterables(
        [names[i], numbers[i], countries[i], wtspFormat], i);
  }

  Sheet otherSheet = excel['otherData'];
  otherSheet.insertRowIterables(
      [names[0], numbers[0], countries[0], "WAPI Format"], 0);
  //insert row by row - other numbers
  for (int j = 1; j < otherNumbers.length; j++) {
    //debugPrint("name j: " + otherNames[j]);
    // var wtspFormat = otherNames[j] + ", " + otherNumbers[j];

    // otherSheet.insertRowIterables(
    //     [otherNames[j], otherNumbers[j], otherCountries[j], wtspFormat], j);
  }

  // Save the Changes in file
  var fileBytes = excel.save(fileName: "testformat.xlsx");

  debugPrint('new data saved in excel');
}

void formatPhoneNumbers(
    List<String> names,
    List<String> numbers,
    List<String> countries,
    List<String> otherNames,
    List<String> otherNumbers,
    List<String> otherCountries) {
  var numberslength = numbers.length;

  for (int i = 0; i < numberslength; i++) {
    int j = 0;
    //remove unwanted characters
    numbers[i] = numbers[i].replaceAll(" ", "");
    numbers[i] = numbers[i].replaceAll("(", "");
    numbers[i] = numbers[i].replaceAll(")", "");
    numbers[i] = numbers[i].replaceAll("+", "");
    numbers[i] = numbers[i].replaceAll("-", "");
    var num = numbers[i];
    var numlength = num.length;

    if (numlength < 11) {
      // no country code

      if (numlength == 8) {
        if (countries[i].toLowerCase() == "qa" ||
            countries[i].toLowerCase() == "qatar") {
          //qatar number 974
          numbers[i] = "+974" + num;
        } else if (countries[i].toLowerCase() == "lb" ||
            countries[i].toLowerCase() == "lebanon") {
          //lebanon number 961
          numbers[i] = "+961" + num;
        } else if (countries[i].toLowerCase() == "bh" ||
            countries[i].toLowerCase() == "bahrain") {
          //bahrain number 973
          numbers[i] = "+973" + num;
        } else {
          debugPrint("others: " + names[i] + numbers[i] + countries[i]);
          //save in other
          // otherNames[j] = names[i];
          // otherNumbers[j] = names[i];
          // otherCountries[j] = countries[i];
          // j++;
          // debugPrint("sucess");
          //debugPrint(
          //"others: " + otherNames[j] + otherNumbers[j] + otherCountries[j]);
        }
      } else if (numlength == 9) {
        if (countries[i].toLowerCase() == "lk" ||
            countries[i].toLowerCase() == "sri lanka") {
          //sri lankan number 94
          numbers[i] = "+94" + num;
        } else if (countries[i].toLowerCase() == "ua" ||
            countries[i].toLowerCase() == "uae" ||
            countries[i].toLowerCase() == "dubai") {
          //dubai number 971
          numbers[i] = "+971" + num;
        } else {
          debugPrint("others: " + names[i] + numbers[i] + countries[i]);
          //save in other
          // otherNames[j] = names[i];
          // otherNumbers[j] = names[i];
          // otherCountries[j] = countries[i];
          // debugPrint(
          //     "others: " + otherNames[j] + otherNumbers[j] + otherCountries[j]);
          // j++;
          debugPrint("sucess");
        }
      } else if (numlength == 10) {
        if (countries[i].toLowerCase() == "in" ||
            countries[i].toLowerCase() == "india") {
          //indian number 91
          numbers[i] = "+91" + num;
        } else if (countries[i].toLowerCase() == "pk" ||
            countries[i].toLowerCase() == "pakistan") {
          //pakistan number 92
          numbers[i] = "+92" + num;
        } else if (countries[i].toLowerCase() == "ng" ||
            countries[i].toLowerCase() == "nigeria") {
          //nigeria number 234
          numbers[i] = "+234" + num;
        } else if (countries[i].toLowerCase() == "ph" ||
            countries[i].toLowerCase() == "philipines") {
          //philipines number 63
          numbers[i] = "+63" + num;
        } else {
          debugPrint("others: " + names[i] + numbers[i] + countries[i]);
          //save in other
          // otherNames[j] = names[i];
          // otherNumbers[j] = names[i];
          // otherCountries[j] = countries[i];
          // j++;
          // debugPrint(
          //     "others: " + otherNames[j] + otherNumbers[j] + otherCountries[j]);
        }
      } else {
        debugPrint(
            "others less than 8: " + names[i] + numbers[i] + countries[i]);
        //save in other
        // otherNames[j] = names[i];
        // otherNumbers[j] = names[i];
        // otherCountries[j] = countries[i];
        // j++;
        // debugPrint(
        //     "others: " + otherNames[j] + otherNumbers[j] + otherCountries[j]);
      }
    } else {
      numbers[i] = "+" + numbers[i];
    }
  }

  debugPrint("format numbers: " + numbers.toString());
}

String showNumber(String correctNumber) {
  int count = correctNumber.length;

  if (count < 11) {
    //number has no country code

    if (count == 8) {
      //qatar number 974
      return "974" + correctNumber;
    } else if (count == 9) {
      //sri lankan number 94
      return "94" + correctNumber;
    } else if (count == 10) {
      //indian number 91
      return "91" + correctNumber;
    }
  }
  return "invalid";
}
