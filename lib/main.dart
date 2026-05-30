import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'screens/board_screen.dart';
import 'screens/board_list_screen.dart';
import 'providers/auth_provider.dart';

void main(){
  runApp(ProviderScope(child: MyApp()));
}
class MyApp extends ConsumerWidget{
  const MyApp({super.key});

  @override
  Widget build (BuildContext context,WidgetRef ref){
    final auth = ref.watch(authProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kanban Board',
      theme:ThemeData.dark(),
      home:auth.token == null ? LoginScreen() : BoardListScreen(),
    );
  }
}