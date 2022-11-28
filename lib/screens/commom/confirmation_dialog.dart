import "package:flutter/material.dart";
import 'package:webapi_journal_flutter/screens/commom/onhover.dart';

Future<dynamic> showConfirmationDialog(
  BuildContext context, {
  String title = "Atenção!",
  String content = "Você realmente deseja executar essa operação?",
  String affirmativeOption = "Confirmar",
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("CANCELAR"),
          ),
          //   TextButton(
          //     onPressed: () {
          //       Navigator.pop(context, true);
          //     },
          //     child: Text(
          //       affirmativeOption.toUpperCase(),
          //       style: const TextStyle(
          //           color: Color.fromARGB(255, 165, 66, 29),
          //           fontWeight: FontWeight.bold),
          //     ),
          //   ),
          OnHover(builder: (isHovered) {
            final colorBackgroud = isHovered ? Colors.red : Colors.white;
            final colorText = isHovered ? Colors.white : Colors.red;

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: colorText,
                  backgroundColor: colorBackgroud,
                  elevation: 0),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                affirmativeOption.toUpperCase(),
              ),
            );
          }),
        ],
      );
    },
  );
}
