import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webapi_journal_flutter/helpers/weekday.dart';
import 'package:webapi_journal_flutter/models/journal.dart';
import 'package:webapi_journal_flutter/screens/commom/confirmation_dialog.dart';
import 'package:webapi_journal_flutter/services/journal_service.dart';
import 'package:uuid/uuid.dart';

import '../../../helpers/logout.dart';
import '../../add_journal_screen/add_journal_screen.dart';
import '../../commom/exception_dialog.dart';

class JournalCard extends StatelessWidget {
  final Journal? journal;
  final DateTime showedDate;
  final Function refreshFunction;
  final String userId;
  // final String token;

  const JournalCard(
      {Key? key,
      this.journal,
      required this.showedDate,
      required this.refreshFunction,
      required this.userId
      // required this.token
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (journal != null) {
      return InkWell(
        onTap: () {
          callAddJournalScreen(context, journal: journal);
        },
        child: Container(
          height: 115,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 3,
              color: Colors.black87,
            ),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    height: 75,
                    width: 75,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(135, 116, 117, 116),
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(6)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      journal!.createdAt.day.toString(),
                      style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 34,
                    width: 75,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.black87)),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(WeekDay(journal!.createdAt).short),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    journal!.content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  removeJournal(context);
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          callAddJournalScreen(context);
        },
        child: Container(
          height: 115,
          alignment: Alignment.center,
          child: Text(
            "${WeekDay(showedDate).short} - ${showedDate.day}",
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  callAddJournalScreen(BuildContext context, {Journal? journal}) {
    // print("Entrou");
    Journal innerJournal = Journal(
      id: const Uuid().v1(),
      content: "",
      createdAt: showedDate,
      updatedAt: showedDate,
      userId: userId,
    );
    // caso journal exista
    if (journal != null) {
      innerJournal = journal;
    }
    Map<String, dynamic> map = {
      'journal': innerJournal,
      'is_editing': journal != null
    };

    Navigator.pushNamed(
      context,
      'add-journal',
      arguments: map,
    ).then((value) {
      // refresh na pagina apos add card
      refreshFunction();
      //pega o result do resgisterJournal do file add_journal_screen.dart
      if (value == DisposeStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(255, 67, 218, 72),
            content: Text("Registrado com sucesso!"),
          ),
        );
      } else if (value == DisposeStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Houve uma falha ao registar."),
          ),
        );
      }
    });
  }

  removeJournal(BuildContext context) {
    showConfirmationDialog(context,
            content:
                "Deseja realmente remover o registro do dia: ${WeekDay(journal!.createdAt)}",
            affirmativeOption: "Remover")
        .then((value) {
      if (value != null && value) {
        JournalService service = JournalService();
        if (journal != null) {}
        service.delete(journal!.id).then(
          (excludeOk) {
            if (excludeOk) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color.fromARGB(255, 67, 218, 72),
                  content: Text((value)
                      ? "Removido com sucesso!"
                      : "Houve um erro ao remover"),
                ),
              );
            }
          },
        ).then((value) {
          refreshFunction();
        }).catchError(
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

        // refreshFunction();
      }
    });
  }
}
