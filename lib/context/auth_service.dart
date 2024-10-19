import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:toptanci_uygulamasi/service/mongodb.dart';
import 'package:toptanci_uygulamasi/models/users.dart'; // Model sınıfınızı içe aktarın

class AuthService {
  // Kullanıcı kaydı
  Future<bool> register(String name, String email, String password, String taxNumber, bool wholesaler, String address) async {
    final hashedPassword = _hashPassword(password);

    final newUser = UsersModel(
      id: ObjectId(),
      name: name,
      email: email,
      password: hashedPassword,
      taxNumber: taxNumber,
      wholesaler: wholesaler,
      favorites: [],
      orderId: [],
      balance: 0.0,
      address: address,
    );

    try {
      var result = await MongoDatabase.usersCollection.insertOne(newUser.toJson()); // MongoDatabase'den kullanıcı koleksiyonunu kullanarak ekler
      return result.isSuccess;
    } catch (e) {
      if (kDebugMode) {
        print('Kayıt hatası: $e'); // Debug modunda hata mesajını yazdırır
      }
      return false; // Hata durumunda false döner
    }
  }

  // Kullanıcı girişi
  Future<bool> login(String email, String password) async {
    final hashedPassword = _hashPassword(password);

    try {
      final user = await MongoDatabase.fetchUserByUsername(email); // MongoDatabase'den kullanıcıyı getirir
      if (user != null && user['password'] == hashedPassword) {
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Giriş hatası: $e'); // Debug modunda hata mesajını yazdırır
      }
    }
    return false;
  }

  // Şifreyi hash'leme
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
