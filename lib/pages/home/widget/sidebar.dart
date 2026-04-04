import 'package:admin_panel/pages/banners/banners_screen.dart';
import 'package:admin_panel/pages/brands/brands_view.dart';
import 'package:admin_panel/pages/home/home_controller.dart';
import 'package:admin_panel/pages/phonemodels/models_view.dart';
import 'package:admin_panel/pages/product_screen/product_view.dart';
import 'package:admin_panel/pages/product_screen/widget/product_list.dart';
import 'package:admin_panel/pages/service/service_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminSidebar extends StatelessWidget {
  AdminSidebar({super.key});
  final HomeController controller = Get.put(HomeController());
  final RxBool isExpanded = true.obs;
  final RxInt selectedIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      width: isExpanded.value ? 280 : 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!,
            Colors.grey[850]!,
            Colors.black87,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section with toggle button
          _buildHeader(),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // _buildMenuItem(
                //   icon: Icons.dashboard_outlined,
                //   title: "Dashboard",
                //   index: 0,
                //   onTap: () {},
                // ),
                _buildMenuItem(
                  icon: Icons.post_add_outlined,
                  title: "Banners",
                  index: 1,
                  onTap: () {
                    selectedIndex.value = 1;
                    Get.to(() => const BannerPage());
                  },
                ),
                _buildMenuItem(
                  icon: Icons.branding_watermark_outlined,
                  title: "Mobile Brands",
                  index: 2,
                  onTap: () {
                    selectedIndex.value = 2;
                    Get.to(() => BrandPage());
                  },
                ),
                _buildMenuItem(
                  icon: Icons.build_outlined,
                  title: "Services",
                  index: 3,
                  onTap: () {
                    selectedIndex.value = 3;
                    Get.to(() => ServicePage());
                  },
                ),
                _buildMenuItem(
                  icon: Icons.phone_android_outlined,
                  title: "Mobile Models",
                  index: 4,
                  onTap: () {
                    selectedIndex.value = 4;
                    Get.to(() => const ModelPage());
                  },
                ),
                const Divider(color: Colors.white24, height: 32),
                _buildMenuItem(
                  icon: Icons.add_shopping_cart_rounded,
                  title: "Add Product",
                  index: 5,
                  onTap: () {
                    selectedIndex.value = 5;
                    Get.to(() => AddProductScreen());
                  },
                ),
                _buildMenuItem(
                  icon: Icons.edit_note_sharp,
                  title: "Product List",
                  index: 6,
                  onTap: () {
                    selectedIndex.value = 6;
                    Get.to(() => ProductListScreen());
                  },
                ),
                const Divider(color: Colors.white24, height: 32),
                _buildMenuItem(
                  icon: Icons.description_outlined,
                  title: "Terms & Conditions",
                  index: 7,
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          // Logout button
          _buildLogoutButton(),
          
          const SizedBox(height: 20),
        ],
      ),
    ));
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: isExpanded.value 
            ? MainAxisAlignment.spaceBetween 
            : MainAxisAlignment.center,
        children: [
          if (isExpanded.value) ...[
            const SizedBox(width: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.build_circle_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "SmartFix",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          IconButton(
            icon: Icon(
              isExpanded.value 
                  ? Icons.chevron_left 
                  : Icons.chevron_right,
              color: Colors.white70,
            ),
            onPressed: () => isExpanded.toggle(),
          ),
          if (isExpanded.value) const SizedBox(width: 8),
        ],
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Obx(() => MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          gradient: selectedIndex.value == index && !isLogout
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    Colors.blue.withOpacity(0.05),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            hoverColor: Colors.white.withOpacity(0.05),
            splashColor: Colors.blue.withOpacity(0.2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isLogout
                        ? Colors.redAccent
                        : (selectedIndex.value == index
                            ? Colors.blueAccent
                            : Colors.grey[400]),
                    size: 22,
                  ),
                  if (isExpanded.value) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isLogout
                              ? Colors.redAccent
                              : (selectedIndex.value == index
                                  ? Colors.white
                                  : Colors.grey[300]),
                          fontSize: 14,
                          fontWeight: selectedIndex.value == index
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
  
  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Get.defaultDialog(
                backgroundColor: Colors.white,
                title: "Logout",
                titleStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                middleText: "Are you sure you want to logout?",
                middleTextStyle: const TextStyle(fontSize: 14),
                textConfirm: "Yes",
                textCancel: "No",
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                cancelTextColor: Colors.grey[700],
                radius: 12,
                onConfirm: () {
                  Get.back();
                  controller.signOut();
                },
              );
            },
            borderRadius: BorderRadius.circular(12),
            hoverColor: Colors.white.withOpacity(0.05),
            splashColor: Colors.red.withOpacity(0.2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.power_settings_new_rounded,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  if (isExpanded.value) ...[
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}