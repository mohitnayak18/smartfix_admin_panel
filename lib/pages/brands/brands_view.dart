import 'package:admin_panel/pages/brands/brands_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrandPage extends StatelessWidget {
  BrandPage({super.key});

  final BrandController controller = Get.put(BrandController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        automaticallyImplyActions: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey,
        title: const Text("Mobile Brands",style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),),
        actions: [
          IconButton(
            tooltip: "Add Brand",
            color: Colors.white,
            icon: const Icon(Icons.add,color: Colors.black,),
            onPressed: controller.openAddBrandDialog,
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.brands.isEmpty) {
          return const Center(child: Text("No brands found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.brands.length,
          itemBuilder: (context, index) {
            var brand = controller.brands[index];

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    // color: Colors.white,
                    brand["logo"],
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 20),
                      );
                    },
                  ),
                ),
                title: Text(
                  brand["name"],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text("Rating: ${brand["rating"]}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmation(context, brand);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic brand) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Delete Brand"),
        content: Text("Are you sure you want to delete ${brand["name"]}?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              controller.deleteBrand(brand["id"], brand["logo"]);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}