import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // text field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  // Trenutni user sa kojim se logira
  final user = FirebaseAuth.instance.currentUser!;

  final CollectionReference _employee =
      FirebaseFirestore.instance.collection('employee');

  // Ova funkcija se pokrece kad se stisne plusic ili edit dugme
  // Ako documentSnapshot != null napravi update postojeceg
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _salaryController.text = documentSnapshot['salary'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Ime i prezime'),
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Plaća',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Stvori' : 'Update'),
                  onPressed: () async {
                    // ignore: unnecessary_nullable_for_final_variable_declarations
                    final String? name = _nameController.text;
                    final double? salary =
                        double.tryParse(_salaryController.text);
                    if (name != null && salary != null) {
                      if (action == 'create') {
                        // Ubacivanje zaposlenika u Firebase
                        await _employee.add({"name": name, "salary": salary});
                      }

                      if (action == 'update') {
                        // Update zaposlenika
                        await _employee
                            .doc(documentSnapshot!.id)
                            .update({"name": name, "salary": salary});
                      }

                      // Ciscenje textControllera, standardna procedura kad se radi sa TextFieldovima
                      _nameController.text = '';
                      _salaryController.text = '';

                      // Ovo sluzi da se vrati na listu poslije obavljenog zadatka
                      // bilo to update, delete ili create
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  // Funkcija koja ce pristupiti zaposleniku po njegovom ID-u
  Future<void> _deleteEmployee(String employeeId) async {
    await _employee.doc(employeeId).delete();

    // Ovo je tzv. snackbar koji ce iskociti kad se uspjesno izbrise zaposlenik
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uspjesno ste izbrisali zaposlenika!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista zaposlenika'),
        actions: [ElevatedButton.icon(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.arrow_back), label: const Text("Odjava", style: TextStyle(fontSize: 18),))],
      ),
      // StreamBuilder se koristi za ucitavanje iz Firestora u real-time aspektu
      body: StreamBuilder(
        stream: _employee.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['name']),
                    subtitle:
                        Text("${documentSnapshot['salary'].toString()} KM"),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Button za uredivanje zaposlenika sa liste
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          // Button za brisanje zaposlenika sa liste
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteEmployee(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Dodavanje zaposlenika
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
