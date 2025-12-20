import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/feature/menuManagement/controllers/ExtrasController.dart';
import 'package:gastcallde/feature/menuManagement/models/ExtraModel.dart';
import 'package:get/get.dart';

class ExtrasScreen extends StatelessWidget {
  ExtrasScreen({super.key});

  final ExtrasController controller = Get.put(ExtrasController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extras Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.extras.isEmpty) {
          return const Center(child: Text('No extras found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.extras.length,
          itemBuilder: (context, index) {
            final extra = controller.extras[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  extra.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Price: ${extra.price}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () => _showExtraDialog(context, extra: extra),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, extra),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExtraDialog(context),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showExtraDialog(BuildContext context, {Extra? extra}) {
    final titleController = TextEditingController(text: extra?.title ?? '');
    final priceController = TextEditingController(text: extra?.price ?? '');
    final isEditing = extra != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Extra' : 'Add Extra'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Extra Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  priceController.text.isEmpty) {
                Get.snackbar('Error', 'Please fill all fields');
                return;
              }

              bool success;
              if (isEditing) {
                success = await controller.updateExtra(
                  extra.id,
                  titleController.text,
                  priceController.text,
                );
              } else {
                success = await controller.addExtra(
                  titleController.text,
                  priceController.text,
                );
              }

              if (success) {
                Navigator.pop(context);
                Get.snackbar(
                  'Success',
                  'Extra ${isEditing ? 'updated' : 'added'} successfully',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Extra extra) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Extra'),
        content: Text('Are you sure you want to delete "${extra.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.deleteExtra(extra.id);
              if (success) {
                Get.snackbar('Success', 'Extra deleted successfully');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
