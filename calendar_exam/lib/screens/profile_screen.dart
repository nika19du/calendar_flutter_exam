import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/db_helper.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';

class ProfileScreen extends StatefulWidget {
  final String userUid;

  const ProfileScreen({super.key, required this.userUid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  List<EventModel> userEvents = [];

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final u = await DBHelper.getUserByUid(widget.userUid);
    final events = await DBHelper.getUserEvents(widget.userUid);
    setState(() {
      user = u;
      userEvents = events;
    });
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedUserUid');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Профил')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Моят профил'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Име: ${user!.name}', style: TextStyle(fontSize: 18)),
            Text('Email: ${user!.email}', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Text('Моите събития:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: userEvents.isEmpty
                  ? Text('Нямате събития.')
                  : ListView.builder(
                itemCount: userEvents.length,
                itemBuilder: (context, index) {
                  final e = userEvents[index];
                  return ListTile(
                    title: Text(e.title),
                    subtitle: Text(e.description ?? ''),
                    trailing: Text('${e.startTime.hour}:${e.startTime.minute.toString().padLeft(2, '0')}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}