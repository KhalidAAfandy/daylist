import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/task_store.dart';
import 'package:todo_app/widgets/daylist_logo.dart';

enum TaskFilter { all, active, completed }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _store = TaskStore();
  List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  String _query = '';
  bool _loading = true;
  bool _saving = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final tasks = await _store.load();
      if (mounted) setState(() => _tasks = tasks);
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(List<Task> tasks) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _store.save(tasks);
      if (mounted) setState(() => _tasks = tasks);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _edit([Task? task]) async {
    final controller = TextEditingController(text: task?.title);
    final formKey = GlobalKey<FormState>();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task == null ? 'A little step forward' : 'Edit task'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 160,
            decoration: const InputDecoration(
              labelText: 'Task name',
              hintText: 'What needs to get done?',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter a task name'
                : null,
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Save task'),
          ),
        ],
      ),
    );
    // The dialog's closing animation still uses its text controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (title == null || !mounted) return;
    await _save(
      task == null
          ? [
              ..._tasks,
              Task(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                title: title,
              ),
            ]
          : _tasks
                .map(
                  (item) =>
                      item.id == task.id ? item.copyWith(title: title) : item,
                )
                .toList(),
    );
  }

  Future<void> _delete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${task.title}” will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _save(_tasks.where((item) => item.id != task.id).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = _tasks.where((task) => task.done).length;
    final visible = _tasks.where((task) {
      final matches = task.title.toLowerCase().contains(_query.toLowerCase());
      return matches &&
          (_filter == TaskFilter.all ||
              (_filter == TaskFilter.completed ? task.done : !task.done));
    }).toList();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                  sliver: SliverList.list(
                    children: [
                      Row(
                        children: [
                          const DaylistLogo(),
                          const SizedBox(width: 12),
                          const Text(
                            'daylist',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                          const Spacer(),
                          if (MediaQuery.sizeOf(context).width > 600)
                            const Text(
                              'ONE STEP AT A TIME',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1,
                                color: Color(0xFF706B58),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      const Text(
                        'Make room for\nwhat matters.',
                        style: TextStyle(
                          fontSize: 38,
                          height: 1.12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'A clear list. A calmer day.',
                        style: TextStyle(
                          color: Color(0xFF706B58),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFE58A), Color(0xFFFFD43B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome_outlined,
                                  color: Color(0xFF57440A),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Your progress',
                                    style: TextStyle(
                                      color: Color(0xFF292719),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$completed / ${_tasks.length}',
                                  style: const TextStyle(
                                    color: Color(0xFF57440A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _tasks.isEmpty
                                    ? 0
                                    : completed / _tasks.length,
                                minHeight: 8,
                                color: const Color(0xFF57440A),
                                backgroundColor: const Color(0x3357440A),
                                semanticsLabel: 'Task completion',
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _tasks.isEmpty
                                  ? 'Start small. Add your first task below.'
                                  : completed == _tasks.length
                                  ? 'All done. Make a little room for yourself.'
                                  : '${_tasks.length - completed} remaining. One step at a time.',
                              style: const TextStyle(color: Color(0xFF57440A)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Your tasks',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: _loading || _saving || _loadFailed
                                ? null
                                : () => _edit(),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add task'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (value) => setState(() => _query = value),
                        decoration: const InputDecoration(
                          hintText: 'Search your tasks',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: TaskFilter.values
                            .map(
                              (filter) => ChoiceChip(
                                label: Text(switch (filter) {
                                  TaskFilter.all => 'All',
                                  TaskFilter.active => 'Active',
                                  TaskFilter.completed => 'Completed',
                                }),
                                selected: _filter == filter,
                                onSelected: (_) =>
                                    setState(() => _filter = filter),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                if (_saving)
                  const SliverToBoxAdapter(
                    child: LinearProgressIndicator(
                      semanticsLabel: 'Saving tasks',
                    ),
                  ),
                if (_loading)
                  const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_loadFailed)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const Text(
                          'Could not load your tasks. Your saved data is unchanged.',
                        ),
                        TextButton(
                          onPressed: _load,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  )
                else if (visible.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.checklist_rounded,
                            size: 52,
                            color: Color(0xFF8A6B00),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _tasks.isEmpty
                                ? 'A fresh start awaits'
                                : 'No matching tasks',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _tasks.isEmpty
                                ? 'Add a task and take your first step.'
                                : 'Try another search or filter.',
                            style: const TextStyle(color: Color(0xFF706B58)),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList.builder(
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final task = visible[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: task.done
                                ? const Color(0xFFF5F1E3)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: task.done
                                    ? const Color(0xFFE8E0C7)
                                    : const Color(0xFFE8E3D3),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: task.done,
                                    semanticLabel: 'Complete ${task.title}',
                                    onChanged: _saving
                                        ? null
                                        : (value) => _save(
                                            _tasks
                                                .map(
                                                  (item) => item.id == task.id
                                                      ? item.copyWith(
                                                          done: value,
                                                        )
                                                      : item,
                                                )
                                                .toList(),
                                          ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: task.done
                                            ? const Color(0xFF736D59)
                                            : const Color(0xFF292719),
                                        decoration: task.done
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    enabled: !_saving,
                                    tooltip: 'Task options',
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _edit(task);
                                      } else {
                                        _delete(task);
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
