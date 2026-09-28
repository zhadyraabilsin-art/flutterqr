import 'package:flutter/material.dart';

void main() {
  runApp(const KanbanBoardApp());
}

class KanbanBoardApp extends StatelessWidget {
  const KanbanBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kanban Sprint Board',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const KanbanScreen(),
    );
  }
}

enum TaskStage { todo, inProgress, done }

enum TaskPriority { low, medium, high }

class KanbanTask {
  final String id;
  final String title;
  final String tag;
  final TaskPriority priority;
  TaskStage stage;

  KanbanTask({
    required this.id,
    required this.title,
    required this.tag,
    required this.priority,
    required this.stage,
  });
}

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  final List<KanbanTask> _tasks = [
    KanbanTask(
      id: '1',
      title: 'Design Material 3 App Architecture',
      tag: 'UI/UX',
      priority: TaskPriority.high,
      stage: TaskStage.done,
    ),
    KanbanTask(
      id: '2',
      title: 'Implement State & Filter Logic',
      tag: 'Dart',
      priority: TaskPriority.high,
      stage: TaskStage.inProgress,
    ),
    KanbanTask(
      id: '3',
      title: 'Write README & Push to GitHub',
      tag: 'Git',
      priority: TaskPriority.medium,
      stage: TaskStage.todo,
    ),
    KanbanTask(
      id: '4',
      title: 'Optimize Widget Rebuilds',
      tag: 'Perf',
      priority: TaskPriority.low,
      stage: TaskStage.todo,
    ),
  ];

  TaskStage _selectedTab = TaskStage.todo;
  final _titleController = TextEditingController();
  final _tagController = TextEditingController(text: 'Feature');
  TaskPriority _newPriority = TaskPriority.medium;

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return Colors.redAccent;
      case TaskPriority.medium:
        return Colors.amberAccent;
      case TaskPriority.low:
        return Colors.greenAccent;
    }
  }

  void _moveStage(KanbanTask task, int delta) {
    final stages = TaskStage.values;
    final nextIndex = (task.stage.index + delta).clamp(0, stages.length - 1);
    setState(() {
      task.stage = stages[nextIndex];
    });
  }

  void _addTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _tasks.insert(
        0,
        KanbanTask(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          tag: _tagController.text.trim().isEmpty
              ? 'General'
              : _tagController.text.trim(),
          priority: _newPriority,
          stage: _selectedTab,
        ),
      );
    });

    _titleController.clear();
    Navigator.of(context).pop();
  }

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'New Sprint Task',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Tag (e.g., UI, API, Bug)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<TaskPriority>(
                    segments: const [
                      ButtonSegment(
                        value: TaskPriority.low,
                        label: Text('Low'),
                      ),
                      ButtonSegment(
                        value: TaskPriority.medium,
                        label: Text('Medium'),
                      ),
                      ButtonSegment(
                        value: TaskPriority.high,
                        label: Text('High'),
                      ),
                    ],
                    selected: {_newPriority},
                    onSelectionChanged: (val) =>
                        setModalState(() => _newPriority = val.first),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _addTask,
                    child: const Text('Add to Board'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _tasks.where((t) => t.stage == _selectedTab).toList();
    final doneCount = _tasks.where((t) => t.stage == TaskStage.done).length;
    final progress = _tasks.isEmpty ? 0.0 : doneCount / _tasks.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Sprint Kanban'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161B26),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sprint Completion',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$doneCount / ${_tasks.length} Done',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<TaskStage>(
              segments: [
                ButtonSegment(
                  value: TaskStage.todo,
                  label: Text(
                    'To Do (${_tasks.where((t) => t.stage == TaskStage.todo).length})',
                  ),
                ),
                ButtonSegment(
                  value: TaskStage.inProgress,
                  label: Text(
                    'Doing (${_tasks.where((t) => t.stage == TaskStage.inProgress).length})',
                  ),
                ),
                ButtonSegment(
                  value: TaskStage.done,
                  label: Text('Done ($doneCount)'),
                ),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (val) =>
                  setState(() => _selectedTab = val.first),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: filteredTasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks in this stage.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (ctx, index) {
                        final task = filteredTasks[index];
                        final pColor = _priorityColor(task.priority);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pColor.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        task.priority.name.toUpperCase(),
                                        style: TextStyle(
                                          color: pColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text(
                                        task.tag,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                        color: Colors.white54,
                                      ),
                                      onPressed: () =>
                                          setState(() => _tasks.remove(task)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (task.stage != TaskStage.todo)
                                      TextButton.icon(
                                        onPressed: () => _moveStage(task, -1),
                                        icon: const Icon(
                                          Icons.arrow_back,
                                          size: 16,
                                        ),
                                        label: const Text('Move Back'),
                                      ),
                                    if (task.stage != TaskStage.done)
                                      FilledButton.tonalIcon(
                                        onPressed: () => _moveStage(task, 1),
                                        icon: const Icon(
                                          Icons.arrow_forward,
                                          size: 16,
                                        ),
                                        label: const Text('Advance'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
