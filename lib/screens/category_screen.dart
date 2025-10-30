import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../utils/category_style.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
 void _showAddCategorySheet(BuildContext context) {
  final nameC = TextEditingController();
  String? selectedIconKey;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                   Color(0xFFCBF1FF), 
                    Color(0xFFD9CFFF),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Add New Category',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: nameC,
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      IconPickerDropdown(
                        selectedIconKey: selectedIconKey,
                        onChanged: (newValue) {
                          setModalState(() {
                            selectedIconKey = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF9B5DE5), // ungu
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          final name = nameC.text.trim();
                          final iconKey = selectedIconKey;

                          if (name.isEmpty || iconKey == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Name and icon must be filled in.')),
                            );
                            return;
                          }

                          final ok = ExpenseService.instance.addCategory(
                            name: name,
                            iconKey: iconKey,
                          );

                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('The category name already exists (duplicate).')),
                            );
                          } else {
                            Navigator.pop(context); // close sheet
                          }
                        },
                        child: const Text('Save Category'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final svc = ExpenseService.instance;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB3F8F1),
              Color(0xFFD2CCFB),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: svc,
          builder: (context, _) {
            final cats =
                svc.categories.where((c) => c.ownerId != 'global').toList();

            if (cats.isEmpty) {
              return const Center(
                  child: Text(
                      'No categories yet. Press the + button to add one.'));
            }

            return ListView.separated(
              padding:
                  const EdgeInsets.fromLTRB(20, kToolbarHeight + 32, 20, 24),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final c = cats[i];
                return Dismissible(
                  key: Key(c.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red.shade400,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child:
                        const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: Text('Delete Category "${c.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                  },
                  onDismissed: (direction) {
                    final ok = svc.deleteCategory(c.id);
                    if (!ok && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Cannot delete (category is currently in use).')),
                      );
                    }
                  },
                  child: Card(
                    elevation: 1,
                    color: Colors.pink.shade50,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: categoryAvatar(c.name),
                      title: Text(c.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.edit_outlined, color: Colors.grey),
                        onPressed: () {
                          // TODO: Implement edit
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
  backgroundColor: const Color(0xFF9B5DE5),
  foregroundColor: Colors.white, // Ungu yang sama
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  elevation: 6,
  onPressed: () => _showAddCategorySheet(context),
  child: const Icon(Icons.add, size: 28),
),
floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

    );
  }
}
