import 'dart:html' as html;
import 'dart:io';

import 'package:admin_panel/pages/pdf_service/pdf_service_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RecentOrdersTable extends StatelessWidget {
  final Function(Map<String, dynamic>) onDownloadPDF;

  const RecentOrdersTable({super.key, required this.onDownloadPDF});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 50,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text("No Orders Found", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 30,
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade300),
              columns: const [
                DataColumn(
                  label: Text(
                    "Order No",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Customer Phone",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Product",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Quantity",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Model",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Partner",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Price",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Time",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Address",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Actions",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final orderData = {
                  ...data,
                  'orderId': data['orderNumber'],
                  'id': doc.id,
                };

                String phone = data['phone']?.toString() ?? "";
                var addressData = data['address'] ?? {};
                double lat = 0;
                double lng = 0;

                if (addressData is Map) {
                  lat = (addressData['latitude'] ?? 0).toDouble();
                  lng = (addressData['longitude'] ?? 0).toDouble();
                }

                final List items = (data['items'] is List) ? data['items'] : [];
                String brand = "N/A";
                String model = "N/A";
                String quantity = "N/A";
                String service = "N/A";
                String serviceName = "N/A";

                if (items.isNotEmpty) {
                  final item = items[0];
                  brand = item['brand']?.toString() ?? "N/A";
                  model = item['model']?.toString() ?? "N/A";
                  quantity = item['quantity']?.toString() ?? "N/A";
                  service = item['title']?.toString() ?? "N/A";
                  serviceName = item['serviceName']?.toString() ?? "N/A";
                }

                String formattedTime = "N/A";
                Timestamp? timestamp = data['createdAt'] as Timestamp?;
                if (timestamp != null) {
                  DateTime dateTime = timestamp.toDate();
                  formattedTime = DateFormat(
                    'dd MMM yyyy, hh:mm a',
                  ).format(dateTime);
                }

                String currentStatus =
                    data['status']?.toString().toLowerCase() ?? 'pending';
                
                // Get partner info from order
                String partnerId = data['partnerId']?.toString() ?? '';
                String partnerName = data['partnerName']?.toString() ?? 'Not Assigned';
                String partnerPhotoUrl = data['partnerPhotoUrl']?.toString() ?? '';

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        data['orderNumber']?.toString() ?? "N/A",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    DataCell(Text(data['phone']?.toString() ?? "N/A")),
                    DataCell(
                      Text(
                        service != "N/A" ? service + ", " + serviceName : "N/A",
                      ),
                    ),
                    DataCell(Text(quantity)),
                    DataCell(Text(model)),
                    // Partner Column with Photo and Name
                    // Alternative with orders count (using Row instead of Column)
DataCell(
  SizedBox(
    width: 180,
    height: 40,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Partner Photo
        if (partnerPhotoUrl.isNotEmpty)
          CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(partnerPhotoUrl),
            onBackgroundImageError: (_, __) {},
          )
        else
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey.shade300,
            child: Icon(
              Icons.person,
              size: 12,
              color: Colors.grey.shade600,
            ),
          ),
        const SizedBox(width: 6),
        // Partner Info - Name and Orders Count in Column but with constraints
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  partnerName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: partnerId.isNotEmpty
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: partnerId.isNotEmpty
                        ? Colors.teal.shade700
                        : Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (partnerId.isNotEmpty)
                  Text(
                    '${(data['partnerOrdersCount'] ?? 0)} orders',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 1,
                  ),
              ],
            ),
          ),
        ),
        // Assign Button if no partner assigned
        if (partnerId.isEmpty)
          Container(
            margin: const EdgeInsets.only(left: 4),
            child: InkWell(
              onTap: () => _showAssignPartnerDialog(
                context,
                doc.id,
                data['orderNumber']?.toString() ?? '',
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.person_add,
                  size: 14,
                  color: Colors.teal.shade600,
                ),
              ),
            ),
          ),
      ],
    ),
  ),
),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            currentStatus,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          focusColor: Colors.white,
                          dropdownColor: Colors.white,
                          value: currentStatus,
                          underline: const SizedBox(),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: _getStatusColor(currentStatus),
                          ),
                          style: TextStyle(
                            color: _getStatusColor(currentStatus),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          items: const [
                            'pending',
                            'confirmed',
                            'assigned',
                            'on the way',
                            'processing',
                            'shipped',
                            'completed',
                            'cancelled',
                          ].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    status.toUpperCase(),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null &&
                                newStatus != currentStatus) {
                              updateOrderStatus(context, doc.id, newStatus);
                            }
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        "₹${data['finalAmount']?.toString() ?? "0"}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isRecentOrder(timestamp)
                              ? Colors.blue.shade50
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isRecentOrder(timestamp))
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: _isRecentOrder(timestamp)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _isRecentOrder(timestamp)
                                    ? Colors.blue.shade900
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.red),
                                    const SizedBox(width: 8),
                                    const Text("Full Address"),
                                  ],
                                ),
                                content: Container(
                                  width: 300,
                                  child: Text(
                                    "${data['address']?['title'] ?? ''}, "
                                    "${data['address']?['type'] ?? ''}, "
                                    "${data['address']?['address'] ?? ''}, "
                                    "${data['address']?['city'] ?? ''}, "
                                    "${data['address']?['state'] ?? ''}",
                                    style: const TextStyle(height: 1.5),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Close"),
                                  ),
                                  if (lat != 0 && lng != 0)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        openMap(lat, lng);
                                      },
                                      icon: const Icon(
                                        Icons.map,
                                        color: Colors.blue,
                                      ),
                                      label: const Text(
                                        "Open Maps",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueGrey,
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        },
                        child: SizedBox(
                          width: 200,
                          child: Text(
                            "${data['address']?['address'] ?? ''}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.cyan,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            onPressed: () => openMap(lat, lng),
                            tooltip: 'Open in Maps',
                            iconSize: 20,
                          ),
                          IconButton(
                            icon: const Icon(Icons.phone, color: Colors.green),
                            onPressed: () => callCustomer(phone),
                            tooltip: 'Call Customer',
                            iconSize: 20,
                          ),
                          IconButton(
                            icon: const Icon(Icons.message, color: Colors.teal),
                            onPressed: () => openWhatsApp(phone),
                            tooltip: 'WhatsApp',
                            iconSize: 20,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                            ),
                            onPressed: () => onDownloadPDF(orderData),
                            tooltip: 'Download PDF',
                            iconSize: 20,
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.green),
                            onPressed: () =>
                                sharePDFViaWhatsApp(orderData, phone),
                            tooltip: 'Share PDF via WhatsApp',
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  // Show dialog to assign partner to order
void _showAssignPartnerDialog(
    BuildContext context,
    String orderId,
    String orderNumber,
  ) async {
    // Fetch partners from Firestore
    QuerySnapshot partnerSnapshot = await FirebaseFirestore.instance
        .collection('partners')
        .where('isAvailable', isEqualTo: true)
        .get();

    if (partnerSnapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No partners available. Please add partners first.',style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    List<Map<String, dynamic>> partners = partnerSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': data['name'] ?? 'Unknown',
        'phoneNumber': data['phoneNumber'] ?? '',
        'photoUrl': data['photoUrl'] ?? '',
        'assignedOrdersCount': data['assignedOrdersCount'] ?? 0,
      };
    }).toList();

    String? selectedPartnerId;
    Map<String, dynamic>? selectedPartner;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  const Icon(Icons.person_add, color: Colors.teal),
                  const SizedBox(width: 8),
                  const Text('Assign Partner to Order'),
                ],
              ),
              content: Container(
                width: 400,
                constraints: const BoxConstraints(
                  maxHeight: 500, // Add max height constraint
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #: $orderNumber',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select a partner:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.white,
                          focusColor: Colors.white,
                          isExpanded: true,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Choose a partner'),
                          ),
                          value: selectedPartnerId,
                          items: partners.map<DropdownMenuItem<String>>((partner) {
                            return DropdownMenuItem<String>(
                              
                              value: partner['id']?.toString(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    // Partner Photo
                                    ClipOval(
                                      
                                      child: partner['photoUrl'].isNotEmpty
                                          ? Image.network(
                                              partner['photoUrl'],
                                              width: 30,
                                              height: 30,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: 30,
                                                  height: 30,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 16,
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              width: 30,
                                              height: 30,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.person,
                                                size: 16,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    // FIXED: Use Expanded with Row instead of Column
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            partner['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.teal.shade50,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            // child: Text(
                                            //   '${partner['assignedOrdersCount']} orders',
                                            //   style: TextStyle(
                                            //     fontSize: 10,
                                            //     color: Colors.teal.shade700,
                                            //     fontWeight: FontWeight.w500,
                                            //   ),
                                            // ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPartnerId = value;
                              selectedPartner = partners.firstWhere(
                                (p) => (p['id']?.toString() ?? '') == value,
                              );
                            });
                          },
                        ),
                      ),
                    ),
                    if (selectedPartner != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Partner Details:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person,
                                    size: 14, color: Colors.teal),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    selectedPartner!['name'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone,
                                    size: 14, color: Colors.teal),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    selectedPartner!['phoneNumber'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedPartnerId != null
                      ? () async {
                          Navigator.pop(context);
                          await _assignPartnerToOrder(
                            context,
                            orderId,
                            selectedPartnerId!,
                            selectedPartner!,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Assign Partner'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Assign partner to order
  Future<void> _assignPartnerToOrder(
    BuildContext context,
    String orderId,
    String partnerId,
    Map<String, dynamic> partner,
  ) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Assigning partner...'),
            ],
          ),
          backgroundColor: Colors.blue,
        ),
      );

      // Update order with partner info
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'partnerId': partnerId,
        'partnerName': partner['name'],
        'partnerPhotoUrl': partner['photoUrl'],
        'partnerPhone': partner['phoneNumber'],
        'assignedAt': FieldValue.serverTimestamp(),
      });

      // Increment partner's assigned orders count
      await FirebaseFirestore.instance
          .collection('partners')
          .doc(partnerId)
          .update({
        'assignedOrdersCount': FieldValue.increment(1),
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('Partner ${partner['name']} assigned successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: $e')),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isRecentOrder(Timestamp? timestamp) {
    if (timestamp == null) return false;
    DateTime orderTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(orderTime);
    return difference.inHours < 24;
  }

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void openMap(double lat, double lng) async {
    final url = Uri.parse("https://www.google.com/maps?q=$lat,$lng");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void callCustomer(String phone) async {
    final url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void openWhatsApp(String phone) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final url = Uri.parse("https://wa.me/$cleanPhone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> sharePDFViaWhatsApp(
    Map<String, dynamic> orderData,
    String phoneNumber,
  ) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final PDFService pdfService = PDFService();
      final Uint8List? bytes = await pdfService.generatePDFBytes(orderData);

      if (bytes == null || bytes.isEmpty) {
        Get.back();
        Get.snackbar(
          'Error',
          'Failed to generate PDF',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      String orderId =
          orderData['orderId'] ?? orderData['orderNumber'] ?? 'ORDER';
      String customerName =
          orderData['customerName'] ?? orderData['userName'] ?? 'Customer';
      String totalAmount = orderData['finalAmount']?.toString() ?? '0';

      Get.back();

      final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "receipt_$orderId.pdf")
        ..style.display = 'none';

      html.document.body?.append(anchor);
      anchor.click();

      Future.delayed(const Duration(milliseconds: 500), () {
        html.Url.revokeObjectUrl(url);
        anchor.remove();
      });

      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (!cleanPhone.startsWith('91')) {
        cleanPhone = '91$cleanPhone';
      }

      String message = """
📱 *SmartFix Tech - Receipt*

Hello $customerName,

📋 Order ID: $orderId
💰 Amount: ₹$totalAmount

📎 Please attach the downloaded receipt PDF.

Thank you for choosing SmartFix Tech! 🙏
""";

      final whatsappUrl =
          "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}";

      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );

      Get.snackbar(
        'Success',
        'PDF downloaded! Please attach it in WhatsApp',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.back();
      print('WhatsApp Share Error: $e');
      Get.snackbar(
        'Error',
        'Failed to share: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> updateOrderStatus(
    BuildContext context,
    String orderId,
    String status,
  ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text('Updating status to ${status.toUpperCase()}...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );

      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'status': status, 'updatedAt': FieldValue.serverTimestamp()},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('Status updated to ${status.toUpperCase()} successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('Failed to update status: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      debugPrint("Error updating status: $e");
    }
  }
}