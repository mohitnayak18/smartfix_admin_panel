import 'package:admin_panel/pages/home/home_controller.dart';
import 'package:admin_panel/pages/home/widget/dashboardcard.dart';
import 'package:admin_panel/pages/home/widget/recent_order.dart';
import 'package:admin_panel/pages/home/widget/sidebar.dart';
import 'package:admin_panel/pages/pdf_service/pdf_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminHomeScreen extends StatelessWidget {
  AdminHomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());
  final PDFService _pdfService = PDFService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Row(
        children: [
          AdminSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with refresh button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Dashboard",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => controller.refreshData(),
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Refresh Data',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    /// DASHBOARD CARDS
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          DashboardCard(
                            title: "Total Orders",
                            value: controller.totalOrders.value.toString(),
                            icon: Icons.shopping_cart,
                            color: Colors.blue,
                          ),
                          DashboardCard(
                            title: "Pending Orders",
                            value: controller.pendingOrders.value.toString(),
                            icon: Icons.pending_actions,
                            color: Colors.orange,
                          ),
                          DashboardCard(
                            title: "Completed Orders",
                            value: controller.completedOrders.value.toString(),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                          DashboardCard(
                            title: "Total Revenue",
                            value:
                                "₹${controller.totalRevenue.value.toStringAsFixed(2)}",
                            icon: Icons.currency_rupee,
                            color: Colors.purple,
                          ),
                          DashboardCard(
                            title: "Total Canceled",
                            value:
                                "₹${controller.totalCanceled.value.toStringAsFixed(2)}",
                            icon: Icons.cancel,
                            color: Colors.red,
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 40),

                    /// RECENT ORDERS TABLE
                    const Text(
                      "Recent Orders",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),

                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (controller.recentOrders.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 50,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No recent orders found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return RecentOrdersTable(
                        onDownloadPDF: (Map<String, dynamic> order) =>
                            _pdfService.generateAndSavePDF(order),
                      );
                    }),

                    const SizedBox(height: 30),

                    /// CUSTOMER CONTACT INFO FROM LATEST ORDER
                    Obx(() {
                      if (controller.recentOrders.isEmpty) {
                        return const SizedBox();
                      }

                      var latestOrder = controller.recentOrders.first;

                      String customerAddress = "Not available";

                      var addressData = latestOrder['address'];

                      double lat = 0;
                      double lng = 0;

                      if (addressData != null && addressData is Map) {
                        String type = addressData['type'] ?? "";
                        String address = addressData['address'] ?? "";

                        lat = addressData['latitude'] ?? 0;
                        lng = addressData['longitude'] ?? 0;

                        customerAddress = "$type • $address";
                      }

                      // SAFELY extract values with null checks
                      String customerName = _getSafeString(
                        latestOrder['customerName'] ??
                            latestOrder['userName'] ??
                            latestOrder['name'] ??
                            'Not available',
                      );

                      String customerPhone = _getSafeString(
                        latestOrder['customerPhone'] ??
                            latestOrder['phone'] ??
                            latestOrder['userPhone'] ??
                            latestOrder['mobile'] ??
                            'Not available',
                      );

                      return Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade50,
                              Colors.purple.shade50.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.8),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(4, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section with improved design
                            Row(
                              children: [
                                // Icon with modern gradient background
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue,
                                        Colors.purple.shade400,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.contact_phone,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Title with badge
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Latest Customer Contact",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Active Now",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Timestamp
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "2 min ago",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Divider with gradient
                            Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade200,
                                    Colors.purple.shade200,
                                    Colors.blue.shade200,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Contact Info Grid
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernContactInfo(
                                    icon: Icons.person_outline,
                                    label: "Customer Name",
                                    value: customerName,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModernContactInfo(
                                    icon: Icons.phone_outlined,
                                    label: "Phone Number",
                                    value: customerPhone,
                                    color: Colors.green,
                                    actionIcon: Icons.phone_callback,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Second Row with Address
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildModernContactInfo(
                                    icon: Icons.location_on_outlined,
                                    label: "Address",
                                    value: customerAddress,
                                    color: Colors.purple,
                                    isAddress: true,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Quick Actions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildQuickActionButton(
                                  icon: Icons.message_outlined,
                                  label: "Message",
                                  color: Colors.green,
                                  onTap: () => openWhatsApp(customerPhone),
                                ),

                                _buildQuickActionButton(
                                  icon: Icons.call_outlined,
                                  label: "Call",
                                  color: Colors.blue,
                                  onTap: () => callCustomer(customerPhone),
                                ),

                                _buildQuickActionButton(
                                  icon: Icons.location_on_outlined,
                                  label: "Map",
                                  color: Colors.purple,
                                  onTap: () => openMap(lat, lng),
                                ),
                                _buildQuickActionButton(
                                  icon: Icons.download,
                                  label: "PDF",
                                  color: Colors.teal,
                                  onTap: () => _pdfService.generateAndSavePDF(
                                    latestOrder,
                                  ),
                                ),
                                _buildQuickActionButton(
                                  icon: Iconsax.share,
                                  label: "Share on whatsapp",
                                  color: Colors.green.shade700,
                                  onTap: () => _pdfService.sharePDFViaWhatsApp(
                                    latestOrder,
                                    customerPhone,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    /// ALL USERS WITH PHONE NUMBERS SECTION
                    Obx(() {
                      if (controller.isLoadingUsers.value) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.only(top: 30),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade50, Colors.green.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.contacts,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "All Registered Users",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${controller.allAuthUsers.length} total users • ${controller.phoneUsers.length} with phone',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            Divider(
                              height: 25,
                              color: Colors.blueGrey.shade100,
                            ),

                            // Stats Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _buildUserStatCard(
                                    title: 'Phone Users',
                                    count: controller.phoneUsers.length,
                                    icon: Icons.phone_android,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildUserStatCard(
                                    title: 'Email Users',
                                    count: controller.emailUsers.length,
                                    icon: Icons.email,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildUserStatCard(
                                    title: 'Total Users',
                                    count: controller.allAuthUsers.length,
                                    icon: Icons.people,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Search/Filter Tabs
                            DefaultTabController(
                              length: 2,
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.grey.shade100,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TabBar(
                                      indicator: BoxDecoration(
                                        borderRadius: BorderRadius.circular(28),
                                        color: Colors.teal,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.teal,
                                            Color(0xFF26A69A),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.teal.withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      dividerColor: Colors.transparent,
                                      labelColor: Colors.white,
                                      unselectedLabelColor:
                                          Colors.teal.shade800,
                                      labelStyle: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      unselectedLabelStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      tabs: const [
                                        Tab(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.people_alt, size: 18),
                                              SizedBox(width: 8),
                                              Text('Phone'),
                                            ],
                                          ),
                                        ),
                                        Tab(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.mail_outline,
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Email'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 400, // Fixed height for the list
                                    child: TabBarView(
                                      children: [
                                        // Phone Users Tab
                                        _buildUsersList(
                                          users: controller.phoneUsers,
                                          emptyMessage: 'No phone users found',
                                          icon: Icons.phone,
                                          color: Colors.green,
                                        ),

                                        // Email Users Tab
                                        _buildUsersList(
                                          users: controller.emailUsers,
                                          emptyMessage: 'No email users found',
                                          icon: Icons.email,
                                          color: Colors.orange,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to safely convert any value to String
  String _getSafeString(dynamic value) {
    if (value == null) return 'Not available';
    if (value is String) {
      return value.trim().isEmpty ? 'Not available' : value;
    }
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    return value.toString();
  }

  void openMap(double lat, double lng) async {
    final url = Uri.parse("https://www.google.com/maps?q=$lat,$lng");
    await launchUrl(url);
  }

  void callCustomer(String phone) async {
    final url = Uri.parse("tel:$phone");
    await launchUrl(url);
  }

  void openWhatsApp(String phone) async {
    final url = Uri.parse("https://wa.me/$phone");
    await launchUrl(url);
  }

  Future<void> generateOrderPDF(Map<String, dynamic> order) async {
    await _pdfService.generateAndSavePDF(order);
  }

  Widget _buildUserStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 0,
            offset: const Offset(0, 0),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),

          // Count with subtle background
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              letterSpacing: 0.3,
            ),
          ),

          // Subtle indicator line
          Container(
            width: 30,
            height: 3,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernContactInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    IconData? actionIcon,
    bool isAddress = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: isAddress ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isAddress ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Optional action icon
          if (actionIcon != null)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(actionIcon, size: 16, color: color),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList({
    required List<Map<String, dynamic>> users,
    required String emptyMessage,
    required IconData icon,
    required Color color,
  }) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(
              user['displayName'] ?? 'No name',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user['phoneNumber'] != 'No phone')
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user['phoneNumber'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (user['email'] != 'No email')
                  Row(
                    children: [
                      Icon(Icons.email, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user['email'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user['isPhoneUser'] == true ? 'Phone' : 'Email',
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
