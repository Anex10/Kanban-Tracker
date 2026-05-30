import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerWidget{
   RegisterScreen({super.key});

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  
  @override
  Widget build(BuildContext context,WidgetRef ref){
    final auth = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body:Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: emailCtrl,decoration: InputDecoration(labelText: "Email")),
              TextField(controller: passCtrl,decoration: InputDecoration(labelText: "Password"),obscureText: true),
              SizedBox(height:20),
              auth.isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                onPressed: () async{
                  bool success = await ref.read(authProvider.notifier).register(
                    passCtrl.text, emailCtrl.text
                  );
                  if (!context.mounted) return;
                  if (success){
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Successful")));
                  }
                }, child: const Text("Register"),),
                if (auth.error != null)Text(auth.error!,style:TextStyle(color:Colors.red))
            ],
          ),
        ),
      )
    );
  }
  }