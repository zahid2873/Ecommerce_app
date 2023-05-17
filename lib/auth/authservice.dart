import 'package:firebase_auth/firebase_auth.dart';

import '../db/db_helper.dart';

class AuthService {
   static final _auth = FirebaseAuth.instance;
   static User? get currentUser => _auth.currentUser;

}