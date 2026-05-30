import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

 
class LoginScreen extends ConsumerWidget {
   LoginScreen({Key? key}) : super(key: key);

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final auth = ref.watch(authProvider);
 
    return Scaffold(
      backgroundColor: Colors.black87, 
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "KANBAN LOGIN",
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 2,
                  color: Colors.white
                ),
              ),
              const SizedBox(height: 32),
              
             
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              
           
              TextField(
                controller: passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
 
             
              auth.isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[800]),
                      onPressed: () async {
                        await ref.read(authProvider.notifier).login(
                          emailCtrl.text, 
                          passCtrl.text
                        );
                      },
                      child: const Text("LOGIN"),
                    ),
                  ),
 
              
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    auth.error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
 
              const SizedBox(height: 16),
              
           
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: const Text(
                  "Don't have an account? Register here",
                  style: TextStyle(color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
