import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signIn(String email, String password) async {
    try {
      print('AuthService: Attempting sign in for email: $email');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('AuthService: Sign in successful for uid: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('AuthService: FirebaseAuthException - ${e.code}: ${e.message}');
      throw e.message ?? 'Authentication failed';
    } catch (e) {
      print('AuthService: Unexpected error - $e');
      throw 'An unexpected error occurred during sign in';
    }
  }

  Future<Teacher?> getTeacherData(String uid) async {
    try {
      print('AuthService: Fetching teacher data for uid: $uid');
      final doc = await _firestore.collection('teachers').doc(uid).get();
      if (doc.exists) {
        print('AuthService: Teacher data found');
        return Teacher.fromMap(doc.data()!, doc.id); // Pass doc.id as the ID
      } else {
        print('AuthService: No teacher document found for uid: $uid');
        return null;
      }
    } catch (e) {
      print('AuthService: Error fetching teacher data - $e');
      return null;
    }
  }
}

/// Teacher model class for representing Firestore documents.
class Teacher {
  final String email;
  final String id; // Firestore document ID
  final String name;
  final int totalLeaves;
  final int usedLeaves;

  Teacher({
    required this.email,
    required this.id,
    required this.name,
    required this.totalLeaves,
    required this.usedLeaves,
  });

  factory Teacher.fromMap(Map<String, dynamic> map, String documentId) {
    return Teacher(
      email: map['email'] ?? '',
      id: documentId, // Use the Firestore document ID
      name: map['name'] ?? '',
      totalLeaves: map['totalLeaves'] ?? 0,
      usedLeaves: map['usedLeaves'] ?? 0,
    );
  }
}
