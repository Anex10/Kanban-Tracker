import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/board.dart';

class ApiService {
  final String baseUrl = "http://localhost:8000";
 
  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
 
  Future<dynamic> get(String path, String? token) async {
    final res = await http.get(Uri.parse("$baseUrl$path"), headers: _headers(token));
    return _handle(res);
  }
 
  Future<dynamic> post(String path, Map body, String? token) async {
    final res = await http.post(Uri.parse("$baseUrl$path"), headers: _headers(token), body: jsonEncode(body));
    return _handle(res);
  }
 
  Future<dynamic> put(String path, Map body, String? token) async {
    final res = await http.put(Uri.parse("$baseUrl$path"), headers: _headers(token), body: jsonEncode(body));
    return _handle(res);
  }
 
  Future<dynamic> delete(String endpoint, String? token) async {
  final response = await http.delete(
    Uri.parse("http://127.0.0.1:8000$endpoint"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );
  if (response.statusCode != 200) throw Exception(response.body);
  return jsonDecode(response.body);
}

   Future<dynamic> patch(String endpoint, Map<String, dynamic> body, String? token) async {
  final response = await http.patch(
    Uri.parse("http://127.0.0.1:8000$endpoint"), 
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode(body),
  );
  if (response.statusCode != 200) throw Exception(response.body);
  return jsonDecode(response.body);
}
 
  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return jsonDecode(res.body);
    throw Exception(res.body);
  }

Future<List<Board>> getBoards(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/boards/"),
      headers: {"Authorization": "Bearer $token"},
    );
 
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Board.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch boards");
    }
  }
 
  Future<Board> createBoard(String token, String name) async {
    final response = await http.post(
      Uri.parse("$baseUrl/boards/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": name}),
    );
 
    if (response.statusCode == 200) {
      return Board.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to create board");
    }
  }

}