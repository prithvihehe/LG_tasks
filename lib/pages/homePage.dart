import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:place_lg_controller/common/button.dart';
import 'package:place_lg_controller/pages/config_page.dart';
import 'package:place_lg_controller/services/LookAt.dart';
import 'package:place_lg_controller/services/orbit.dart';
import 'package:place_lg_controller/services/ssh.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double longvalue = 0;
  double latvalue = 0;
  // playOrbit() async {
  //   await LGConnection()
  //       .buildOrbit(Orbit.buildOrbit(Orbit.generateOrbitTag(
  //           LookAt(longvalue, latvalue, "6341.7995674", "0", "0"))))
  //       .then((value) async {
  //     await LGConnection().startOrbit();
  //   });
  // }

  // stopOrbit() async {
  //   await LGConnection().stopOrbit();
  //   setState(() {
  //     isOrbiting = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: _appBar(context),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoundedSmallButton(
                    onTap: () async {
                      // SSH ssh = SSH();
                      // await ssh.connectToLG();
                      // SSHSession? execResult = await ssh.execute(
                      //     'echo "search=IIT BHU Varanasi" >/tmp/query.txt');
                      // if (execResult != null) {
                      //   print('Command executed successfully');
                      // } else {
                      //   print('Failed to execute command');
                      // }
                      SSH ssh = SSH();
                      await ssh.connectToLG();
                      await ssh.cleanKML();
                      SSHSession? sshSession = await ssh.flyToOrbit(
                          25.262280, 82.989560, 7095, 60, 0);
                      if (sshSession != null) {
                        print("MESSAGE :: COMMAND EXECUTED SUCCESSFULLY");
                      } else {
                        print("MESSAGE :: COMMAND EXECUTION FAILED");
                      }
                    },
                    label: "Relocate",
                    backgroundColor: Color(0xff31B161),
                    textColor: Colors.white),
                const SizedBox(height: 70),
                RoundedSmallButton(
                    onTap: () async {
                      SSH ssh = SSH();
                      await ssh.connectToLG();
                      await ssh.orbitAroundHome();
                      // await ssh.startTour();
                    },
                    label: "Start Orbit",
                    backgroundColor: Color(0xffFCBA25),
                    textColor: Colors.black),
                const SizedBox(height: 70),
                RoundedSmallButton(
                    onTap: () async {
                      SSH ssh = SSH();
                      await ssh.connectToLG();
                      await ssh.stopOrbit();
                      // await ssh.startTour();
                    },
                    label: "Stop Orbit",
                    backgroundColor: Color(0xff4C7CBF),
                    textColor: Colors.black)
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(80),
              child: Container(
                  child: const Image(
                image: AssetImage('assets/imgs/lg_logo.png'),
                height: 350,
                width: 350,
              )),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundedSmallButton(
                    onTap: () async {
                      SSH ssh = SSH();
                      await ssh.connectToLG();
                      await ssh.rebootLG();
                    },
                    label: "Reboot",
                    backgroundColor: Color(0xff4C7CBF),
                    textColor: Colors.white),
                const SizedBox(height: 70),
                RoundedSmallButton(
                    onTap: () async {
                      SSH ssh = SSH();
                      await ssh.connectToLG();
                      await ssh.rightScreenBalloon();
                    },
                    label: "Display",
                    backgroundColor: Color(0xffEF4F3F),
                    textColor: Colors.black)
              ],
            )
          ],
        ));
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: const Text(
        "LG Controller",
        style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            letterSpacing: 5,
            fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        const SizedBox(width: 15),
        IconButton(
            iconSize: 35,
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage()));
            },
            icon: const Icon(Icons.settings)),
      ],
    );
  }
}
