import 'package:flutter/material.dart';
import 'package:todolist/todo/repository/abstract_todo_repository.dart';
import 'package:todolist/todo/repository/firebase_todo_repository.dart';
import 'package:todolist/todo/repository/mock_todo_repository.dart';
import 'model/todo.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  late final AbstractTodoRepository repository;

  @override
  void initState() {
    super.initState();

    final env = dotenv.env['ENV'] ?? 'dev';
    repository = env == 'prod' ? FirebaseTodoRepository() : MockTodoRepository();
  }

  void _addOrEditTodo({Todo? todo}) async {
    final titleController = TextEditingController(text: todo?.title ?? '');
    final descController = TextEditingController(text: todo?.description ?? '');
    DateTime? dueDate = todo?.dueDate ?? DateTime.now();
    String? errorText;

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

                  final newTodo = Todo(
                    id: todo?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    description: descController.text,
                    dueDate: dueDate!,
                    isDone: todo?.isDone ?? false,
                  );

                  try {
                    await repository.addOrEditTodo(newTodo);
                    Navigator.pop(context);
                  } catch (e) {
                    setState(() => errorText = 'Échec de l\'enregistrement de la tâche : $e');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteTodo(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la tâche'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await repository.deleteTodo(id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _toggleDone(Todo todo) async {
    await repository.toggleDone(todo);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes tâches'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'À faire'),
              Tab(text: 'Terminées'),
            ],
          ),
        ),
        body: StreamBuilder<List<Todo>>(
          stream: repository.todos(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucune tâche disponible dans cet onglet.'));
            }

            final todos = snapshot.data!..sort((a, b) => a.dueDate.compareTo(b.dueDate));
            final toDoList = todos.where((t) => !t.isDone).toList();
            final doneList = todos.where((t) => t.isDone).toList();

            return TabBarView(
              children: [
                _buildTodoList(toDoList),
                _buildTodoList(doneList),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addOrEditTodo(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    if (todos.isEmpty) {
      return const Center(child: Text('Aucune tâche ici.'));
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, i) {
        final todo = todos[i];
        
        return ListTile(
          title: Text(todo.title),
          subtitle: Text('${todo.description}\nÉchéance : ${todo.dueDate.toLocal().toString().split(' ')[0]}'),
          isThreeLine: true,
          leading: Checkbox(
            value: todo.isDone,
            onChanged: (_) => _toggleDone(todo),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit), onPressed: () => _addOrEditTodo(todo: todo)),
              IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteTodo(todo.id)),
            ],
          ),
        );
      },
    );
  }
}
