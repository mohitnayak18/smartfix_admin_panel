import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class RecentOrdersTable extends StatelessWidget {
  const RecentOrdersTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Orders Found"));
          }

          final docs = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 50,
              headingRowColor: MaterialStateProperty.all(Colors.grey.shade300),
              columns: const [
                DataColumn(label: Text("Order No")),
                DataColumn(label: Text("Customer Phone")),
                DataColumn(label: Text("Product")),
                DataColumn(label: Text("Quantity")),
                DataColumn(label: Text("Model")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Price")),
                DataColumn(label: Text("Time")),
                DataColumn(label: Text("Address")),
                DataColumn(label: Text("Actions")),
              ],

              rows: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                /// Extract phone
String phone = data['phone']?.toString() ?? "";

/// Extract address map
var addressData = data['address'] ?? {};

double lat = 0;
double lng = 0;

if (addressData is Map) {
  lat = (addressData['latitude'] ?? 0).toDouble();
  lng = (addressData['longitude'] ?? 0).toDouble();
}

                /// Safe items array
                final List items = (data['items'] is List) ? data['items'] : [];

                /// Default values
                String brand = "N/A";
                String model = "N/A";
                String quantity = "1";

                if (items.isNotEmpty) {
                  final item = items[0];

                  brand = item['brand']?.toString() ?? "N/A";
                  model = item['model']?.toString() ?? "N/A";
                  quantity = item['quantity']?.toString() ?? "1";
                }

                return DataRow(

                  cells: [
                    /// Order Number
                    DataCell(Text(data['orderNumber']?.toString() ?? "N/A")),

                    /// Phone
                    DataCell(Text(data['phone']?.toString() ?? "N/A")),

                    /// Product Brand
                    DataCell(
  FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('service')
        .doc(items.isNotEmpty ? items[0]['serviceId'] : "")
        .get(),
    builder: (context, serviceSnapshot) {
      if (!serviceSnapshot.hasData) {
        return const Text("Loading...");
      }

      if (!serviceSnapshot.data!.exists) {
        return const Text("Service not found");
      }

      var serviceData =
          serviceSnapshot.data!.data() as Map<String, dynamic>;

      return Text(serviceData['name'] ?? "No Name");
    },
  ),
),

                    /// Quantity
                    DataCell(Text(quantity)),

                    /// Model
                    DataCell(Text(model)),

                    /// Status
                    DataCell(
                      Text(
                        data['status']?.toString().toUpperCase() ?? "PENDING",
                      ),
                    ),

                    /// Price
                    DataCell(
                      Text("₹${data['finalAmount']?.toString() ?? "0"}"),
                    ),

                    /// Time
                    DataCell(
                      Text(
  DateFormat('dd MMM yyyy, hh:mm a')
      .format((data['createdAt'] as Timestamp).toDate()),
),
                    ),

                    /// Address
                   DataCell(
  InkWell(
    onTap: () {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white ,
            title: const Text("Full Address"),
            content: Text(
              "${data['address']?['title'] ?? ''}, "
              "${data['address']?['type'] ?? ''}, "
              "${data['address']?['address'] ?? ''}",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              )
            ],
          );
        },
      );
    },
    child: SizedBox(
      width: 250,
      child: Text(
        "${data['address']?['address'] ?? ''}",
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ),
),
DataCell(
  Row(
    children: [

      IconButton(
        icon: Icon(Icons.location_on, color: Colors.red),
        onPressed: () => openMap(lat, lng),
      ),

      IconButton(
        icon: Icon(Icons.phone, color: Colors.green),
        onPressed: () => callCustomer(phone),
      ),

      IconButton(
        icon: Icon(Icons.message, color: Colors.teal),
        onPressed: () => openWhatsApp(phone),
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
  void openMap(double lat, double lng) async {
  final url = Uri.parse("https://www.google.com/maps?q=$lat,$lng");

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  }
}

void callCustomer(String phone) async {
  final url = Uri.parse("tel:$phone");

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  }
}

void openWhatsApp(String phone) async {
  final url = Uri.parse("https://wa.me/$phone");

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  }
}
}
