import 'package:admin_panel/pages/settings_screen/setting.dart';
import 'package:admin_panel/pages/term_condiontions/term_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermPage extends StatefulWidget {
  const TermPage({super.key});

  @override
  State<TermPage> createState() => _TermPageState();
}

class _TermPageState extends State<TermPage> {
  final TermController termCtrl = Get.put(TermController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions", style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        )),
        backgroundColor: Colors.blueGrey,
      ),

      
      body: StreamBuilder<DocumentSnapshot>(
  stream: termCtrl.termDocRef.snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    var data = snapshot.data!.data() as Map<String, dynamic>?;

    String privacy = data?["privacy"] ?? "";
    String terms = data?["terms"] ?? "";

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [

        /// 🔹 PRIVACY POLICY
        Card(
          color: Colors.white,
          child: ListTile(
            title: const Text(
              "Privacy Policy",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(privacy),

            leading: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => termCtrl.showTermDialog(
                field: "privacy",
                oldValue: privacy,
              ),
            ),

            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  termCtrl.deleteTerm("privacy"),
            ),
          ),
        ),

        /// 🔹 TERMS & CONDITIONS
        Card(
          color: Colors.white,
          child: ListTile(
            title: const Text(
              "Terms & Conditions",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(terms),

            leading: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => termCtrl.showTermDialog(
                field: "terms",
                oldValue: terms,
              ),
            ),

            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  termCtrl.deleteTerm("terms"),
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
