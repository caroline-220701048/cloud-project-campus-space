import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _currentView = 'dashboard';
  final Color _primaryColor = Colors.deepPurple;
  final Color _cardColor = Colors.deepPurple[100]!;
  final Color _borderColor = Colors.deepPurple;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentView == 'dashboard' 
          ? AppBar(
              title: Text('Admin Dashboard'),
              backgroundColor: _primaryColor,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout,color:Colors.black,),
                  onPressed: _logout,
                ),
              ],
            )
          : AppBar(
              title: Text(_getAppBarTitle()),
              backgroundColor: _primaryColor,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => _changeView('dashboard'),
              ),
            ),
      body: _currentView == 'dashboard' ? _buildDashboardView()
          : _currentView == 'users' ? _buildUsersView()
          : _currentView == 'rooms' ? _buildRoomsView()
          : _currentView == 'add_room' ? _buildAddRoomView()
          : _currentView == 'requests' ? _buildRequestsView()
          : _buildHistoryView(),
    );
  }

  String _getAppBarTitle() {
    switch (_currentView) {
      case 'users': return 'Users';
      case 'rooms': return 'List of Rooms';
      case 'add_room': return 'Add Room';
      case 'requests': return 'Requests';
      case 'history': return 'Booking History';
      default: return 'Admin Dashboard';
    }
  }

  void _logout() {
    _auth.signOut();
    Navigator.pop(context);
  }

  void _changeView(String view) {
    setState(() {
      _currentView = view;
    });
  }

  Widget _buildDashboardView() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _buildMenuCard('USERS', Icons.people),
            _buildMenuCard('LIST OF ROOMS', Icons.meeting_room),
            _buildMenuCard('ADD ROOM', Icons.add),
            _buildMenuCard('REQUESTS', Icons.notifications),
            _buildMenuCard('BOOKING HISTORY', Icons.history),
          ],
        ),
      ),
    );
  }

Widget _buildMenuCard(String title, IconData icon) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double iconSize = constraints.maxWidth * 0.30; // Adjust icon size dynamically
      double fontSize = constraints.maxWidth * 0.06; // Adjust font size dynamically

      return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _changeView(_getViewFromTitle(title)),
          child: Container(
            padding: EdgeInsets.all(10), // Add padding for better spacing
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: iconSize, color: _primaryColor),
                SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  String _getViewFromTitle(String title) {
    switch (title) {
      case 'USERS': return 'users';
      case 'LIST OF ROOMS': return 'rooms';
      case 'ADD ROOM': return 'add_room';
      case 'REQUESTS': return 'requests';
      case 'BOOKING HISTORY': return 'history';
      default: return 'dashboard';
    }
  }

  Widget _buildUsersView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final user = doc.data() as Map<String, dynamic>;
            return _buildStyledCard(
              ListTile(
                title: Text(user['name'] ?? user['email']?.split('@')[0] ?? 'Unknown'),
                subtitle: Text('Email: ${user['email']}\nRole: ${user['role']}'),
                leading: CircleAvatar(
                  backgroundColor: _primaryColor,
                  child: Text(
                    user['name']?.substring(0, 1) ?? user['email']?.substring(0, 1) ?? '?',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRoomsView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('rooms').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final room = doc.data() as Map<String, dynamic>;
            return _buildStyledCard(
              ListTile(
                title: Text('Room: ${room['room']}'),
                subtitle: Text(
                  'Block: ${room['block']}\n'
                  'Floor: ${room['floor']}, Capacity: ${room['capacity']}\n'
                  'Amenities: ${room['amenities']}'
                ),
                leading: Icon(Icons.meeting_room, size: 40, color: _primaryColor),
              ),
            );
          },
        );
      },
    );
  }

 Widget _buildAddRoomView() {
  final TextEditingController _roomNumberController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  List<String> _selectedAmenities = [];

  Future<void> _addRoom() async {
    if (_roomNumberController.text.isEmpty ||
        _blockController.text.isEmpty ||
        _floorController.text.isEmpty ||
        _capacityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      await _firestore.collection('rooms').add({
        'room': _roomNumberController.text,
        'block': _blockController.text,
        'floor': _floorController.text,
        'capacity': _capacityController.text,
        'amenities': _selectedAmenities.join(', '),
        'createdBy': _auth.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Room added successfully!')));
      _roomNumberController.clear();
      _blockController.clear();
      _floorController.clear();
      _capacityController.clear();
      setState(() => _selectedAmenities.clear());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add room: ${e.toString()}')),
      );
    }
  }

  Widget _buildAmenityCheckbox(String amenity) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return CheckboxListTile(
          title: Text(amenity),
          value: _selectedAmenities.contains(amenity),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                if (!_selectedAmenities.contains(amenity)) {
                  _selectedAmenities.add(amenity);
                }
              } else {
                _selectedAmenities.remove(amenity);
              }
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }

  return SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: _buildStyledCard(
      Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _roomNumberController,
              decoration: InputDecoration(
                labelText: 'Room Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _blockController,
              decoration: InputDecoration(
                labelText: 'Block',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _floorController,
              decoration: InputDecoration(
                labelText: 'Floor',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _capacityController,
              decoration: InputDecoration(
                labelText: 'Capacity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text('Amenities:', style: TextStyle(fontSize: 16)),
            ...['AC', 'Projector', 'Mic', 'Whiteboard']
                .map((amenity) => _buildAmenityCheckbox(amenity))
                .toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Add Room', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ),
  );
}
  Widget _buildRequestsView() {
    Future<void> _processRequest(String bookingId, bool isApproved) async {
      try {
        await _firestore.collection('bookings').doc(bookingId).update({
          'status': isApproved ? 'approved' : 'rejected',
          'processedAt': FieldValue.serverTimestamp(),
          'processedBy': _auth.currentUser?.uid,
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process request: ${e.toString()}')),
        );
      }
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'pending')
          .orderBy('requestedAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: _buildStyledCard(
            Center(child: Text('No pending requests')),
          ));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final booking = doc.data() as Map<String, dynamic>;
            return _buildStyledCard(
              ListTile(
                title: Text('Room: ${booking['roomName']}'),
                subtitle: Text(
                  'Block: ${booking['block']}\n'
                  'Date: ${_formatDate(booking['fromDate'])}\n'
                  'Time: ${_formatTime(booking['fromDate'])} to ${_formatTime(booking['toDate'])}\n'
                  'Requested by: ${booking['userName']} (${booking['userEmail']})\n'
                  'Purpose: ${booking['purpose']}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () => _processRequest(doc.id, true),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => _processRequest(doc.id, false),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bookings')
          .where('status', whereIn: ['approved', 'rejected'])
          .orderBy('processedAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: _buildStyledCard(
            Center(child: Text('No booking history')),
          ));
        }

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 16), // Added bottom padding to fix overflow
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final booking = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildStyledCard(
                ListTile(
                  title: Text('Room: ${booking['roomName']}'),
                  subtitle: Text(
                    'Block: ${booking['block']}\n'
                    'Date: ${_formatDate(booking['fromDate'])}\n'
                    'Time: ${_formatTime(booking['fromDate'])} to ${_formatTime(booking['toDate'])}\n'
                    'Status: ${booking['status']}\n'
                    'Booked by: ${booking['userName']}\n'
                    'Purpose: ${booking['purpose']}',
                  ),
                  trailing: Icon(
                    booking['status'] == 'approved' ? Icons.check_circle : Icons.cancel,
                    color: booking['status'] == 'approved' ? Colors.green : Colors.red,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStyledCard(Widget child) {
    return Container(
      margin: EdgeInsets.only(bottom: 8), // Reduced margin to prevent overflow
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }

  String _formatDate(Timestamp timestamp) {
    return timestamp.toDate().toString().split(' ')[0];
  }

  String _formatTime(Timestamp timestamp) {
    final time = timestamp.toDate();
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}