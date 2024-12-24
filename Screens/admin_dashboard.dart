import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _leaveRequests = [];
  bool _isLoading = true;
  String _selectedFilter = 'pending';  
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadLeaveRequests();
  }

  Future<void> _loadLeaveRequests() async {
    setState(() => _isLoading = true);
    try {
      Query query = _firestore.collection('leaveRequests')
          .where('status', isEqualTo: _selectedFilter);
      
      final QuerySnapshot snapshot = await query.get();
      
      final List<Map<String, dynamic>> requests = snapshot.docs.map((doc) => {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      }).toList();
      
      setState(() {
        if (_searchQuery.isEmpty) {
          _leaveRequests = requests;
        } else {
          _leaveRequests = requests.where((leave) =>
            leave['teacherName'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading leave requests: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLeaveStatus(String requestId, String newStatus, Map<String, dynamic> leaveData) async {
    try {
      await _firestore.collection('leaveRequests')
          .doc(requestId)
          .update({
            'status': newStatus,
            'submittedAt': FieldValue.serverTimestamp(),
          });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave request ${newStatus}'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadLeaveRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final List<Map<String, String>> filters = [
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Approved', 'value': 'approved'},
      {'label': 'Rejected', 'value': 'rejected'},
    ];

    return Row(
      children: filters.map((filter) {
        final bool isSelected = _selectedFilter == filter['value'];
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FilterChip(
            label: Text(filter['label']!),
            selected: isSelected,
            onSelected: (selected) {
              setState(() => _selectedFilter = filter['value']!);
              _loadLeaveRequests();
            },
            selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
            checkmarkColor: Theme.of(context).primaryColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLeaveRequestCard(Map<String, dynamic> leave) {
    final startDate = (leave['startDate'] as Timestamp).toDate();
    final endDate = (leave['endDate'] as Timestamp).toDate();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          leave['teacherName'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
            ),
            Text(
              '${leave['numberOfDays']} days ${leave['leaveType']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: _buildStatusBadge(leave['status']),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Reason'),
                  subtitle: Text(leave['reason']),
                  contentPadding: EdgeInsets.zero,
                ),
                if (_selectedFilter == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _updateLeaveStatus(
                          leave['id'],
                          'rejected',
                          leave,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => _updateLeaveStatus(
                          leave['id'],
                          'approved',
                          leave,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Approve'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by teacher name',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _loadLeaveRequests();
                  },
                ),
                const SizedBox(height: 16),
                _buildFilterChips(),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _leaveRequests.isEmpty
                ? Center(
                    child: Text(
                      'No ${_selectedFilter} leave requests found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _leaveRequests.length,
                    itemBuilder: (context, index) {
                      return _buildLeaveRequestCard(_leaveRequests[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}