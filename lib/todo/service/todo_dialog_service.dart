import 'package:flutter/material.dart';
import '../model/todo.dart';

final class TodoDialogService {
  Future<Todo?> showFormDialog({
    required BuildContext context,
    Todo? todo,
  }) async {
    final titleController = TextEditingController(text: todo?.title ?? '');
    final descController = TextEditingController(text: todo?.description ?? '');
    DateTime? dueDate = todo?.dueDate ?? DateTime.now();
    String? errorText;
    Todo? result;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(todo == null ? 'Ajouter une tâche' : 'Modifier une tâche'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
                TextButton(
                  child: Text(dueDate == null ? 'Choisir une date d\'échéance' : dueDate!.toLocal().toString().split(' ')[0]),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => dueDate = picked);
                  },
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(errorText!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Annuler'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text(todo == null ? 'Ajouter' : 'Enregistrer'),
                onPressed: () async {
                  if (titleController.text.isEmpty) {
                    setState(() => errorText = 'Le titre est requis');
                    return;
                  }

                  if (dueDate == null) {
                    setState(() => errorText = 'La date d\'échéance est requise');
                    return;
                  }

                  result = Todo(
                    id: todo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    description: descController.text,
                    dueDate: dueDate!,
                    isDone: todo?.isDone ?? false,
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
    return result;
  }
}
