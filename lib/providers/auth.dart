import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/htttp_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;

  Future<void> _authenticate(
      String? email, String? password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAUJ8SdqecbRjFuT3frhN8UocQe_qAIvEU');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String? email, String? password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String? email, String? password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
