import 'package:admin_panel/pages/banners/banners_screen.dart';
import 'package:admin_panel/pages/brands/brands_view.dart';
import 'package:admin_panel/pages/phonemodels/models_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.black87,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            "SmartFix Admin",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),

          sidebarItem(Icons.dashboard, "Dashboard", () {}),

          sidebarItem(Icons.post_add_rounded, "Banners", () {
            Get.to(() => const BannerPage());
          }),

          sidebarItem(Icons.branding_watermark, "Mobile Brands", () {
            Get.to(() => BrandPage());
          }),

          sidebarItem(Icons.build, "Services", () {}),

          sidebarItem(Icons.people, "Mobile Models", () {
            Get.to(() => const ModelPage());
          }),

          sidebarItem(Icons.shopping_cart, "Orders", () {}),

          sidebarItem(Icons.shopping_cart, "Products", () {}),

          sidebarItem(Icons.settings, "Settings", () {}),
        ],
      ),
    );
  }

  Widget sidebarItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      onTap: onTap, // ✅ FIXED
    );
  }
}