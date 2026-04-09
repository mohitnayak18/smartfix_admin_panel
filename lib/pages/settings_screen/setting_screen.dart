import 'package:admin_panel/pages/settings_screen/setting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingController stngCtrl = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings - Offers", style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        )),
        backgroundColor: Colors.blueGrey,
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          /// ➕ ADD OFFER
          FloatingActionButton(
            heroTag: "offer",
            onPressed: () => stngCtrl.showDialogBox(),
            child: const Icon(Icons.local_offer),
          ),

          const SizedBox(height: 10),

          /// ➕ ADD HIGHLIGHT
          FloatingActionButton(
            heroTag: "highlight",
            onPressed: () => stngCtrl.showDialogBox(isHighlight: true),
            child: const Icon(Icons.star),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("settings").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          List offers = [];
          List highlights = [];

          for (var doc in docs) {
            if (doc.id == "avlOffers") {
              offers = doc["avlOffers"] ?? [];
            }

            if (doc.id == "highlights") {
              highlights = doc["highlights"] ?? [];
            }
          }
          if (offers.isEmpty && highlights.isEmpty) {
            return const Center(child: Text("No data available"));
          }

          return ListView(
            
            children: [
              /// 🔹 OFFERS SECTION
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Offers",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              ...offers.map(
                (offer) => Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(offer),

                    leading: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => stngCtrl.showDialogBox(oldValue: offer),
                    ),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => stngCtrl.deleteOffer(offer),
                    ),
                  ),
                ),
              ),

              /// 🔹 HIGHLIGHTS SECTION
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Highlights",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              ...highlights.map(
                (highlight) => Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(highlight),

                    leading: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => stngCtrl.showDialogBox(
                        oldValue: highlight,
                        isHighlight: true, // 👈 differentiate
                      ),
                    ),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => stngCtrl.deleteHighlight(highlight),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
