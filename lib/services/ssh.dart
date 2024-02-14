// TODO 2: Import 'dartssh2' package
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:place_lg_controller/services/LookAt.dart';
import 'package:place_lg_controller/services/balloon_makers.dart';
import 'package:place_lg_controller/services/orbit.dart';

import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class SSH {
  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  SSHClient? _client;

  // Initialize connection details from shared preferences
  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  // Connect to the Liquid Galaxy system
  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    try {
      final socket = await SSHSocket.connect(_host, int.parse(_port));
      // TODO 3: Connect to Liquid Galaxy system, using examples from https://pub.dev/packages/dartssh2#:~:text=freeBlocks%7D%27)%3B-,%F0%9F%AA%9C%20Example%20%23,-SSH%20client%3A
      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );
      // const Duration(seconds: 20);
      print(_host);
      print(_passwordOrKey);
      print(_port);
      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');
      return false;
    }
  }

  Future<SSHSession?> execute(String command) async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      //   TODO 4: Execute a demo command: echo "search=Lleida" >/tmp/query.txt
      final execResult = await _client!.execute('$command');

      return execResult;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<SSHSession?> rebootLG() async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }

      for (int i = int.parse(_numberOfRigs); i > 0; i--) {
        await _client!.execute(
            'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S reboot" ');
        print(
            'sshpass -p $_passwordOrKey ssh -t lg$i "echo $_passwordOrKey | sudo -S reboot"');
      }
      return null;
    } catch (e) {
      print('An error occurred while executing the command: Se');
      return null;
    }
  }

  String orbitLookAtLinear(double latitude, double longitude, double zoom,
      double tilt, double bearing) {
    return '<gx:duration>1.2</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>$zoom</range><tilt>$tilt</tilt><heading>$bearing</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';
  }

  Future<SSHSession?> flyToOrbit(double latitude, double longitude, double zoom,
      double tilt, double bearing) async {
    try {
      if (_client == null) {
        print('MESSAGE :: SSH CLIENT IS NOT INITIALISED');
        return null;
      }

      final executeResult = await _client!.execute(
          'echo "flytoview=${orbitLookAtLinear(latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
      print(executeResult);
      return executeResult;
    } catch (e) {
      print('MESSAGE :: AN ERROR HAS OCCURRED WHILE EXECUTING THE COMMAND: $e');
      return null;
    }
  }

  Future<void> balloonAtHome() async {
    try {
      if (_client == null) {
        print('MESSAGE :: SSH CLIENT IS NOT INITIALISED');
        return;
      }

      String balloonKML = BalloonMakers.balloon();

      File inputFile = await makeFile("BalloonKML", balloonKML);
      await uploadKMLFile(inputFile, "BalloonKML", "Task_Balloon");
    } catch (e) {
      print("error");
    }
  }

  makeFile(String filename, String content) async {
    try {
      var localPath = await getApplicationDocumentsDirectory();
      File localFile = File('${localPath.path}/${filename}.kml');
      await localFile.writeAsString(content);

      return localFile;
    } catch (e) {
      return null;
    }
  }

  Future<void> orbitAtMyCity() async {
    try {
      if (_client == null) {
        print('MESSAGE :: SSH CLIENT IS NOT INITIALISED');
        return;
      }

      await cleanKML();

      String orbitKML = OrbitEntity.buildOrbit(OrbitEntity.tag(LookAtEntity(
          lng: 82.989372, lat: 25.262377, range: 7000, tilt: 60, heading: 0)));

      File inputFile = await makeFile("OrbitKML", orbitKML);
      await uploadKMLFile(inputFile, "OrbitKML", "Task_Orbit");
    } catch (e) {
      print("Error");
    }
  }

  uploadKMLFile(File inputFile, String kmlName, String task) async {
    try {
      bool uploading = true;
      final sftp = await _client!.sftp();
      final file = await sftp.open('/var/www/html/$kmlName.kml',
          mode: SftpFileOpenMode.create |
              SftpFileOpenMode.truncate |
              SftpFileOpenMode.write);
      var fileSize = await inputFile.length();
      file.write(inputFile.openRead().cast(), onProgress: (progress) async {
        if (fileSize == progress) {
          uploading = false;
          if (task == "Task_Orbit") {
            await loadKML("OrbitKML", task);
          } else if (task == "Task_Balloon") {
            await loadKML("BalloonKML", task);
          }
        }
      });
    } catch (e) {
      print("Error");
    }
  }

  loadKML(String kmlName, String task) async {
    try {
      final v = await _client!.execute(
          "echo 'http://lg1:81/$kmlName.kml' > /var/www/html/kmls.txt");

      if (task == "Task_Orbit") {
        await beginOrbiting();
      } else if (task == "Task_Balloon") {
        await showBalloon();
      }
    } catch (error) {
      print("error");
      await loadKML(kmlName, task);
    }
  }

  beginOrbiting() async {
    try {
      final res = await _client!.run('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (error) {
      await beginOrbiting();
    }
  }

  showBalloon() async {
    try {
      String balloonKML = BalloonMakers.balloon();

      await _client!.run("echo '$balloonKML' > /var/www/html/kml/slave_2.kml");

      await cleanKML();
    } catch (error) {
      await showBalloon();
    }
  }

  Future<void> rightScreenDisplayName() async {
    try {
      if (_client == null) {
        print('MESSAGE :: SSH CLIENT IS NOT INITIALISED');
        return;
      }
      int totalScreen = int.parse(_numberOfRigs);
      int rightMostScreen = (totalScreen / 2).floor() + 1;

      final executeResult = await _client!.execute(
          "echo '${BalloonMakers.balloon()}' > /var/www/html/kml/slave_$rightMostScreen.kml");
      print(executeResult);
    } catch (e) {
      print('MESSAGE :: AN ERROR HAS OCCURRED WHILE EXECUTING THE COMMAND: $e');
    }
  }

  setRefresh() async {
    try {
      for (var i = 2; i <= int.parse(_numberOfRigs); i++) {
        String search = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';
        String replace =
            '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';

        await _client!.execute(
            'sshpass -p $_passwordOrKey ssh -t lg$i \'echo $_passwordOrKey | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml\'');
        await _client!.execute(
            'sshpass -p $_passwordOrKey ssh -t lg$i \'echo $_passwordOrKey | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml\'');
      }
    } catch (error) {
      print("ERROR");
    }
  }

  stopOrbit() async {
    try {
      await _client!.run('echo "exittour=true" > /tmp/query.txt');
    } catch (error) {
      stopOrbit();
    }
  }

  startOrbit() async {
    try {
      await _client!.run('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (error) {
      stopOrbit();
    }
  }

  cleanBalloon() async {
    try {
      await _client!.run(
          "echo '${BalloonMakers.blankBalloon()}' > /var/www/html/kml/slave_2.kml");
      await _client!.run(
          "echo '${BalloonMakers.blankBalloon()}' > /var/www/html/kml/slave_3.kml");
    } catch (error) {
      await cleanBalloon();
    }
  }

  cleanSlaves() async {
    try {
      await _client!.run("echo '' > /var/www/html/kml/slave_2.kml");
      await _client!.run("echo '' > /var/www/html/kml/slave_3.kml");
    } catch (error) {
      await cleanSlaves();
    }
  }

  cleanKML() async {
    try {
      await cleanBalloon();
      await stopOrbit();
      await _client!.run("echo '' > /tmp/query.txt");
      await _client!.run("echo '' > /var/www/html/kmls.txt");
    } catch (error) {
      await cleanKML();
    }
  }
}
