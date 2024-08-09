import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../componenets/home_screen/carousel_slider.dart';
import '../componenets/home_screen/header.dart';
import '../componenets/home_screen/utils.dart';
import '../componenets/spacers.dart';
import '../componenets/utils.dart';
import '../componenets/bottom_nav.dart';
import '../componenets/drawer.dart';
import '../componenets/floating_action_button.dart';
import 'scan/results.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeChanged;
  final Box box;
  const HomeScreen(
      {super.key,
      required this.currentTheme,
      required this.onThemeChanged,
      required this.box});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _initials = '';
  late String _username = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<bool> isLoadingList = [false, false, false];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map updateAppProps = widget.box.get('appProps', defaultValue: {});

      final dataString = prefs.getString('userInfo');
      if (dataString != null) {
        try {
          final data = jsonDecode(dataString) as Map;
          updateAppProps['userInfo'] = data;
        } catch (e) {
          print('Error decoding JSON: $e');
          updateAppProps['userInfo'] = {};
        }
      } else {
        updateAppProps['userInfo'] = {};
      }

      await widget.box.put('appProps', updateAppProps);
      print('DataString: $dataString');
      print('Updated appProps: $updateAppProps');

      // Call getInitials after initializing data
      getInitials();
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  Future<void> getInitials() async {
    var box = widget.box;
    Map updateAppProps = box.get("appProps");
    var name = updateAppProps['userInfo']['name'].toString();
    print(name);
    var names = name.split(' ');
    String temp = "";
    for (var element in names) {
      temp += element.substring(0, 1);
    }
    setState(() {
      _initials = temp;
      _username = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: ScreenText(
            pageName: 'IPRIS',
          ),
        ),
        actions: [InitialsAvatar(initials: _initials)],
      ),
      drawer: MyDrawer(
        currentDrawerItem: 0,
        currentTheme: widget.currentTheme,
        onThemeChanged: widget.onThemeChanged,
        box: widget.box,
      ),
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeScreenHeader(username: _username),
            const Divider(),
            myHeightSpacer(20),
            titleForSubComponents("Discover the app..."),
            myHeightSpacer(10),
            myCarouselSlider(),
            myHeightSpacer(25),
            const Divider(),
            myHeightSpacer(15),
            titleForSubComponents("Discover featured plants from us"),
            myHeightSpacer(15),
            featuredCards(context, widget.box, widget.currentTheme,
                widget.onThemeChanged),
          ],
        ),
      ),
      floatingActionButton: floatingActionButtonForScanPage(
          context, widget.currentTheme, widget.onThemeChanged, widget.box),
      bottomNavigationBar: myBottomNavBar(
          context, 1, widget.currentTheme, widget.onThemeChanged, widget.box),
    );
  }

  Padding featuredCards(BuildContext context, Box box, ThemeMode currentTheme,
      Function(ThemeMode) onThemeChanged) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: [
          featuredCard('assets/imgs/featured/tomato.jpg', 'Tomato', 0, context,
              box, currentTheme, onThemeChanged),
          featuredCard('assets/imgs/featured/sunflower.jpg', 'Sun Flower', 1,
              context, box, currentTheme, onThemeChanged),
          featuredCard('assets/imgs/featured/lavender.jpg', 'Lavender', 2,
              context, box, currentTheme, onThemeChanged),
        ],
      ),
    );
  }

  SizedBox featuredCard(
      String img,
      String title,
      int index,
      BuildContext context,
      Box box,
      ThemeMode currentTheme,
      Function(ThemeMode) onThemeChanged) {
    return SizedBox(
      height: 220,
      width: 135,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              identifyPlant(img, title, index, context, box, currentTheme,
                  onThemeChanged);
            },
            child: Container(
              width: 135,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0)),
                image:
                    DecorationImage(fit: BoxFit.cover, image: AssetImage(img)),
              ),
            ),
          ),
          Container(
            height: 40,
            width: 135,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (isLoadingList[index])
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: () async {
                          identifyPlant(img, title, index, context, box,
                              currentTheme, onThemeChanged);
                        },
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> identifyPlant(
      String img,
      String title,
      int index,
      BuildContext context,
      Box box,
      ThemeMode currentTheme,
      Function(ThemeMode) onThemeChanged) async {
    try {
      setState(() {
        isLoadingList[index] = true;
      });

      final ByteData data = await rootBundle.load(img);
      String jsonString =
          await rootBundle.loadString('assets/imgs/featured/featured.json');
      final Uint8List bytes = data.buffer.asUint8List();
      var jsonData = json.decode(jsonString);
      Map response = jsonData[index];

      setState(() {
        isLoadingList[index] = false;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              imageBytes: bytes,
              box: box,
              currentTheme: currentTheme,
              onThemeChanged: onThemeChanged,
              showButtonsOfScanScreen: false,
              plantInfo: response['plant_info'],
              plantUses: response['plant_uses'],
            ),
          ),
        );
      });
    } on Exception catch (e) {
      setState(() {
        isLoadingList[index] = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content:
                  const Text('An Unexpected error has occured!\nTry again...'),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }
}
