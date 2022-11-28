import "package:flutter/material.dart";

Future<dynamic> showExceptionDialog(
  BuildContext context, {
  String title = "Um problema aconteceu",
  required String content,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.warning,
              color: Colors.red,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.red),
            )
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "OK",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          )
        ],
      );
    },
  );
}
