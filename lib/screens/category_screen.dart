import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../utils/category_style.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _nameC = TextEditingController();
  final _iconKeyC = TextEditingController();
  final _imageUrlC = TextEditingController();

  @override
  void dispose() {
    _nameC.dispose();
    _iconKeyC.dispose();
    _imageUrlC.dispose();
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
            // daftar kategori
            Expanded(
              child: ListView.separated(
                itemCount: cats.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final c = cats[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: categoryColor(c.name),
                      child: c.imageUrl != null && c.imageUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                c.imageUrl!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  categoryIcon(c.name),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            )
                          : Icon(
                              categoryIcon(c.name),
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                    title: Text(c.name),
                    subtitle: null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        final ok = svc.deleteCategory(c.id);
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tidak bisa hapus (sedang dipakai).'),
                            ),
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
            const SizedBox(height: 12),

            // tambah kategori
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tambah Kategori',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameC,
              decoration: const InputDecoration(
                labelText: 'Nama kategori baru',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            // Compute helperText outside of const InputDecoration
            TextField(
              controller: _iconKeyC,
              decoration: InputDecoration(
                labelText: 'Icon key (mis. shopping, food, wifi...)',
                border: const OutlineInputBorder(),
                isDense: true,
                helperText:
                    'Daftar contoh: ${kIconMap.keys.take(8).join(", ")} ... (case-insensitive)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _imageUrlC,
              decoration: const InputDecoration(
                labelText: 'Image URL (opsional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final ok = svc.addCategory(
                    _nameC.text,
                    iconKey: _iconKeyC.text,
                    imageUrl: _imageUrlC.text,
                  );
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama kosong / duplikat.'),
                      ),
                    );
                  } else {
                    _nameC.clear();
                    _iconKeyC.clear();
                    _imageUrlC.clear();
                    setState(() {});
                  }
                },
                child: const Text('Tambah'),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Catatan: ikon diisi bebas sesuai key (lihat contoh). '
              'Jika URL gambar diisi, avatar akan menampilkan gambar tersebut.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
