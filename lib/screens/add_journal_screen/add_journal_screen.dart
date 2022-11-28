import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webapi_journal_flutter/helpers/weekday.dart';
import 'package:webapi_journal_flutter/models/journal.dart';
import 'package:webapi_journal_flutter/services/journal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/logout.dart';
import '../commom/exception_dialog.dart';

class AddJournalScreen extends StatefulWidget {
  final Journal journal;
  final bool isEditing;

  const AddJournalScreen(
      {super.key, required this.journal, required this.isEditing});

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // captura o txt escrito no journal
    _contentController.text = widget.journal.content;
    return Scaffold(
      appBar: AppBar(
        title: Text(WeekDay(widget.journal.createdAt).toString()),
        actions: [
          IconButton(
            onPressed: () {
              registerJournal(context);
            },
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _contentController,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 24),
          expands: true,
          maxLines: null,
          minLines: null,
        ),
      ),
    );
  }

  registerJournal(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      // String? token = prefs.getString("acessToken");

      // if (token != null) {
      String content = _contentController.text;
      // atualizo o conteudo do journal recebido nessa tela
      widget.journal.content = content;
      JournalService service = JournalService();
      if (widget.isEditing) {
        // PUT
        // print("Estou editando");
        service.edit(widget.journal.id, widget.journal).then(
          (result) {
            if (result) {
              Navigator.pop(context, DisposeStatus.success);
            } else {
              Navigator.pop(context, DisposeStatus.error);
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
      } else {
        // POST

        service.register(widget.journal).then(
          (result) {
            if (result) {
              Navigator.pop(context, DisposeStatus.success);
            } else {
              Navigator.pop(context, DisposeStatus.error);
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
    });
  }
}

enum DisposeStatus { exit, error, success }
