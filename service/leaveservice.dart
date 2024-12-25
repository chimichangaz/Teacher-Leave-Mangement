import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_request.dart';

class LeaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitLeaveRequest(LeaveRequest request) async {
    await _firestore.collection('leaveRequests').add(request.toJson());
  }

  Future<void> updateLeaveStatus(String requestId, String status) async {
    await _firestore
        .collection('leaveRequests')
        .doc(requestId)
        .update({'status': status});
  }

  Stream<List<LeaveRequest>> getTeacherLeaveRequests(String teacherId) {
    return _firestore
        .collection('leaveRequests')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaveRequest.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<LeaveRequest>> getAllLeaveRequests() {
    return _firestore
        .collection('leaveRequests')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaveRequest.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
}