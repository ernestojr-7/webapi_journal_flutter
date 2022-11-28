import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webapi_journal_flutter/screens/commom/exception_dialog.dart';
import 'package:webapi_journal_flutter/screens/home_screen/widgets/home_screen_list.dart';
import 'package:webapi_journal_flutter/services/journal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/logout.dart';
import '../../models/journal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // O último dia apresentado na lista
  DateTime currentDay = DateTime.now();

  // Tamanho da lista
  int windowPage = 10;

  // A base de dados mostrada na lista
  Map<String, Journal> database = {};

  final ScrollController _listScrollController = ScrollController();
  final JournalService _journalService = JournalService();

  String userId = '';
  // String? userToken;

  // chamado quando a tela aberta pela primeira vez
  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Título baseado no dia atual
        title: Text(
          "${currentDay.day}  |  ${currentDay.month}  |  ${currentDay.year}",
        ),
        actions: [
          IconButton(
              onPressed: () {
                refresh();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      drawer: Drawer(
        child: ListView(children: [
          ListTile(
            onTap: () {
              logout(context);
            },
            title: const Text("Sair"),
            leading: const Icon(Icons.logout),
          ),
        ]),
      ),
      body: ListView(
        controller: _listScrollController,
        children: generateListJournalCards(
          windowPage: windowPage,
          currentDay: currentDay,
          database: database,
          refreshFunction: refresh,
          userId: userId,
          // token: userToken!,
        ),
      ),
    );
  }

  void refresh() async {
    SharedPreferences.getInstance().then(
      (prefs) {
        String? token = prefs.getString("accessToken");
        String? id = prefs.getString("id");
        String? email = prefs.getString("email");

        if (token != null && id != null && email != null) {
          _journalService.getAll(id: id).then(
            (List<Journal> listJournal) {
              setState(
                () {
                  userId = id;
                  database = {};
                  for (Journal journal in listJournal) {
                    database[journal.id] = journal;
                  }

                  if (_listScrollController.hasClients) {
                    final double position =
                        _listScrollController.position.maxScrollExtent;
                    _listScrollController.jumpTo(position);
                  }
                },
              );
            },
          );
        } else {
          print("JOGOU PARA LOGIN DE NOVO!");
          Navigator.pushReplacementNamed(context, "login");
        }
      },
    ).catchError(
      (error) {
        logout(context);
      },
      test: (error) => error is TokenExpiredException,
    ).catchError(
      (error) {
        var innerError = error as HttpException;
        showExceptionDialog(context, content: innerError.message);
      },
      test: (error) => error is HttpException,
    );
  }
}
