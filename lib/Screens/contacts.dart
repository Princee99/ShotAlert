import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shot_alert/Screens/home.dart';

class Contacts extends StatefulWidget {
  final String userId;
  Contacts({required this.userId});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addContact() async {
    if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
      await firestore
          .collection('users')
          .doc(widget.userId)
          .collection('contacts')
          .add({
        'name': nameController.text,
        'phone': phoneController.text,
      });
      nameController.clear();
      phoneController.clear();
    }
  }

  Future<void> deleteContact(String contactId) async {
    await firestore
        .collection('users')
        .doc(widget.userId)
        .collection('contacts')
        .doc(contactId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            Text("Emergency Contacts", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Phone",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: addContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text("Add Contact", style: TextStyle(color: Colors.black)),
            ),
            SizedBox(height: 15),
            Expanded(
              child: StreamBuilder(
                stream: firestore
                    .collection('users')
                    .doc(widget.userId)
                    .collection('contacts')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Error fetching contacts",
                            style: TextStyle(color: Colors.white)));
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text("No Contacts Added",
                            style: TextStyle(color: Colors.white70)));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          title: Text(doc['name'],
                              style: TextStyle(color: Colors.white)),
                          subtitle: Text(doc['phone'],
                              style: TextStyle(color: Colors.white70)),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteContact(doc.id),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.black, size: 28),
                onPressed: () {
                  Get.off(Homepage());
                },
              ),
              IconButton(
                icon: Icon(Icons.contacts, color: Colors.black, size: 28),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.black, size: 28),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
