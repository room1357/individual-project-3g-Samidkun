import 'package:flutter/material.dart';
import '../services/expense_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _addC = TextEditingController();
  final _renameC = TextEditingController();
  String? _selectedId;

  @override
  void dispose() {
    _addC.dispose();
    _renameC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = ExpenseService.instance;
    final cats = svc.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Kategori')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: cats.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final c = cats[i];
                  return ListTile(
                    title: Text(c.name),
                    selected: _selectedId == c.id,
                    onTap: () => setState(() => _selectedId = c.id),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        final ok = svc.deleteCategory(c.id);
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tidak bisa hapus. Kategori sedang dipakai.')),
                          );
                        } else {
                          setState(() {});
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addC,
                    decoration: const InputDecoration(
                      labelText: 'Nama kategori baru',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final ok = svc.addCategory(_addC.text);
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama tidak valid / sudah ada')),
                      );
                    } else {
                      _addC.clear();
                      setState(() {});
                    }
                  },
                  child: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _renameC,
                    decoration: InputDecoration(
                      labelText: _selectedId == null ? 'Pilih kategori dulu' : 'Nama baru',
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    enabled: _selectedId != null,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedId == null
                      ? null
                      : () {
                          final ok = svc.renameCategory(_selectedId!, _renameC.text);
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nama tidak valid / sudah ada')),
                            );
                          } else {
                            _renameC.clear();
                            setState(() {});
                          }
                        },
                  child: const Text('Rename'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
