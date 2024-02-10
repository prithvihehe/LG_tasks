import 'package:flutter/material.dart';
import 'package:place_lg_controller/components/connection_flag.dart';
import 'package:place_lg_controller/services/ssh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartssh2/dartssh2.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool connectionStatus = false;
  // TODO 8: Declare SSH Instance
  late SSH ssh;

  Future<void> _connectToLG() async {
    bool? result = await ssh.connectToLG();
    setState(() {
      connectionStatus = result!;
    });
  }

  @override
  void initState() {
    super.initState();
    ssh = SSH();
    _loadSettings();
    _connectToLG();
  }

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sshPortController = TextEditingController();
  final TextEditingController _rigsController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _sshPortController.dispose();
    _rigsController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('ipAddress') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _sshPortController.text = prefs.getString('sshPort') ?? '';
      _rigsController.text = prefs.getString('numberOfRigs') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_ipController.text.isNotEmpty) {
      await prefs.setString('ipAddress', _ipController.text);
    }
    if (_usernameController.text.isNotEmpty) {
      await prefs.setString('username', _usernameController.text);
    }
    if (_passwordController.text.isNotEmpty) {
      await prefs.setString('password', _passwordController.text);
    }
    if (_sshPortController.text.isNotEmpty) {
      await prefs.setString('sshPort', _sshPortController.text);
    }
    if (_rigsController.text.isNotEmpty) {
      await prefs.setString('numberOfRigs', _rigsController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, connectionStatus);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Connection Settings',
              style: TextStyle(color: Colors.white)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ConnectionFlag(
                    status: connectionStatus,
                  )),
              TextField(
                controller: _ipController,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.computer,
                    color: Colors.white,
                  ),
                  labelText: 'IP address',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'Enter Master IP',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  labelText: 'LG Username',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'Enter your username',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  focusColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.white,
                  ),
                  labelText: 'LG Password',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _sshPortController,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.settings_ethernet,
                    color: Colors.white,
                  ),
                  labelText: 'SSH Port',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: '22',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _rigsController,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.memory,
                    color: Colors.white,
                  ),
                  labelText: 'No. of LG rigs',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'Enter the number of rigs',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.white),
                  shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                  ),
                ),
                onPressed: () async {
                  await _saveSettings();
                  // TODO 6: Initalize SSH Instance and call connectToLG() function
                  SSH ssh = SSH();
                  bool? result = await ssh.connectToLG();
                  if (result == true) {
                    setState(() {
                      connectionStatus = true;
                    });
                    print('Connected to LG successfully');
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cast,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          'CONNECT TO LG',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
