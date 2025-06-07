import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db/db_helper.dart';
import 'models/user_model.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await DBHelper.resetDatabase();
  await DBHelper.database; // инициализира базата
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> getLoggedUserUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedUserUid');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String?>(
        future: getLoggedUserUid(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen(userUid: snapshot.data!);
          } else {
            return LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return HomeScreen(userUid: args);
        },
      },
    );
  }
}