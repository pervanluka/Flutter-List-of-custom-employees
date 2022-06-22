import 'package:employees/home/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Ovaj snackBar je sigurnost neka ako je jedno od polja prazno prilikom klika na sign in
  // izbacit ce dolje crni prozorcic da fali nesto

  var snackBar =
      const SnackBar(content: Text("Email i password moraju biti popunjeni!"));

  var passwordSnackBar =
      const SnackBar(content: Text("Email mora biti popunjen!"));

  var emailSnackBar =
      const SnackBar(content: Text("Password mora biti popunjen"));

  Future signIn() async {
    try {
      if (_emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty) {
        // await sluzi da se obavi radnja preko interneta i ono je uvijek povezano sa async (koje mora biti pored funkcije)
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());
        MaterialPageRoute(builder: (context) => const HomePage());
      } else if (_emailController.text.isNotEmpty &&
          _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(passwordSnackBar);
      } else if (_emailController.text.isEmpty &&
          _passwordController.text.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(emailSnackBar);
      } else if (_emailController.text.isEmpty &&
          _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Error: $e");
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const SingleChildScrollView(
              child: Text("Unesite pravilni e-mail i password"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Razumijem'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _emailController.clear();
                  _passwordController.clear();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ovaj GestureDetector ti sluzi kad je fokus na emailu tj kad je otvorena tipkovina
    // kad kliknes negdi po zaslonu on ce zatvorit tipkovnicu i nece bit vise fokusa na tom polju
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 25, left: 16, right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset('assets/images/fsre.jpeg',height: 150)),
            const SizedBox(
              height: 40,
            ),
            TextField(
              controller: _emailController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            const SizedBox(
              height: 4,
            ),
            TextField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
              // Ovo je metoda signIn() koja se zove klikom na button
              onPressed: signIn,
              icon: const Icon(Icons.lock_open),
              label: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
