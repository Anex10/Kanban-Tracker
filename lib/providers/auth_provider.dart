import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/models/user.dart';
import 'package:state_notifier/state_notifier.dart';
 
class AuthState {
  final String? token;
  final User? user;
  final bool isLoading;
  final String? error;
 
  AuthState({this.token, this.isLoading = false, this.error,this.user});
}
 
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(token:null,isLoading: false,error:null));

  Future<bool>register(String password,String email)async{
    state = AuthState(isLoading: true);
    try{
      final response = await http.post(
        Uri.parse('http://localhost:8000/auth/register'),
        headers: {'Content-Type':'application/json'},
        body:jsonEncode({
          'password':password,
          'email':email,
        })
      );
      if(response.statusCode==201 || response.statusCode==200){
        state=AuthState(isLoading: false);
        return true;
      }else{
        state = AuthState(error: 'Registration Failed:${response.body}');
        return false;
      }
    }catch (e){
      state = AuthState(error: e.toString());
      return false;
    }
  }
 
  Future<void> login(String email, String password) async {
  state = AuthState(isLoading: true);
  try {
    final response = await http.post(
      Uri.parse('http://localhost:8000/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
 
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final loggedInUser = User(email: email);
      
      state = AuthState(
        token: data['access_token'],
        user: loggedInUser, 
        isLoading: false,
      );
    } else {
      state = AuthState(error: "Login Failed", isLoading: false);
    }
  } catch (e) {
    state = AuthState(error: e.toString(), isLoading: false);
  }
}

    void logout(){
      state=AuthState();
    }

}
 
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});