import 'package:flutter/material.dart';
import 'package:webapi_journal_flutter/models/journal.dart';
import 'package:webapi_journal_flutter/screens/add_journal_screen/add_journal_screen.dart';
import 'package:webapi_journal_flutter/screens/login_screen/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isLogged = await verifyToken();

  runApp(
    MyApp(
      isLogged: isLogged,
    ),
  );
  // JournalService service = JournalService();
  // service.register(Journal.empty());
  // service.getAll();
}

Future<bool> verifyToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? token = prefs.getString("accessToken");
  if (token != null) {
    return true;
  }
  return false;
}

class MyApp extends StatelessWidget {
  final bool isLogged;
  const MyApp({Key? key, required this.isLogged}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Journal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.grey,
        appBarTheme: const AppBarTheme(
            elevation: 0, //remove sombra appBar
            backgroundColor: Colors.black,
            titleTextStyle: TextStyle(color: Colors.white),
            actionsIconTheme: IconThemeData(color: Colors.white),
            iconTheme: IconThemeData(color: Colors.white)),
        textTheme: GoogleFonts.bitterTextTheme(),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      initialRoute: (isLogged) ? "home" : "login",
      routes: {
        "home": (context) => const HomeScreen(),
        "login": (context) => LoginScreen(),
      }, // passando argumentos para rota nomeada
      onGenerateRoute: ((settings) {
        if (settings.name == "add-journal") {
          // captura dos argumentos necessarios para mudar de tela
          // Map para passar mais de um argumento
          Map<String, dynamic> map = settings.arguments as Map<String, dynamic>;

          final Journal journal = map["journal"] as Journal;
          final bool isEditing = map["is_editing"];
          // print("Recebi da main isEditing: $isEditing");
          // print("Indo para rota -> add-journal");
          return MaterialPageRoute(builder: (context) {
            return AddJournalScreen(
              journal: journal,
              isEditing: isEditing,
            );
          });
        }
        return null;
      }),
    );
  }
}
