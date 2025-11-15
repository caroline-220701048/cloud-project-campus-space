import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDashboard extends StatefulWidget {
  final String role;
  UserDashboard({required this.role});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _currentView = 'dashboard';
  final Color _primaryColor = Colors.deepPurple;
  final Color _cardColor = Colors.deepPurple[100]!;
  final Color _borderColor = Colors.deepPurple;
  DateTime? _fromDate;
  TimeOfDay? _fromTime;
  DateTime? _toDate;
  TimeOfDay? _toTime;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      setState(() {
        _userName = user.email!.split('@')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentView == 'dashboard' 
          ? AppBar(
              title: Text('User Dashboard'),
              backgroundColor: _primaryColor,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.black),
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
          : _currentView == 'book_room' ? _buildBookRoomView()
          : _currentView == 'profile' ? _buildProfileView()
          : _currentView == 'current_bookings' ? _buildCurrentBookingsView()
          : _buildPreviousBookingsView(),
    );
  }

  String _getAppBarTitle() {
    switch (_currentView) {
      case 'book_room': return 'Book Room';
      case 'profile': return 'User Profile';
      case 'current_bookings': return 'Current Bookings';
      case 'previous_bookings': return 'Previous Bookings';
      default: return 'User Dashboard';
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
            _buildMenuCard('BOOK ROOM', Icons.add),
            _buildMenuCard('VIEW PROFILE', Icons.person),
            _buildMenuCard('CURRENT BOOKINGS', Icons.event_available),
            _buildMenuCard('PREVIOUS BOOKINGS', Icons.history),
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
      case 'BOOK ROOM': return 'book_room';
      case 'VIEW PROFILE': return 'profile';
      case 'CURRENT BOOKINGS': return 'current_bookings';
      case 'PREVIOUS BOOKINGS': return 'previous_bookings';
      default: return 'dashboard';
    }
  }

  // Book Room View
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
        log("Selected Date : ${_fromDate} ${_fromTime} to ${_toDate} ${_toTime}");
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          _fromTime = picked;
        } else {
          _toTime = picked;
        }
        print("Selected Date : ${_fromDate} ${_fromTime} to ${_toDate} ${_toTime}");
      });
    }
  }

  void _checkAvailableRooms() {
    if (_fromDate == null || _fromTime == null || _toDate == null || _toTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    DateTime fromDateTime = DateTime(
      _fromDate!.year,
      _fromDate!.month,
      _fromDate!.day,
      _fromTime!.hour,
      _fromTime!.minute,
    );

    DateTime toDateTime = DateTime(
      _toDate!.year,
      _toDate!.month,
      _toDate!.day,
      _toTime!.hour,
      _toTime!.minute,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvailableRoomsPage(
          fromDateTime: fromDateTime,
          toDateTime: toDateTime,
        ),
      ),
    );
  }

  Widget _buildBookRoomView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: _buildStyledCard(
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'From:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(
                      _fromDate == null
                          ? 'Select Date'
                          : '${_fromDate!.toLocal()}'.split(' ')[0],
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selectTime(context, true),
                    child: Text(
                      _fromTime == null
                          ? 'Select Time'
                          : _fromTime!.format(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'To:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(
                      _toDate == null
                          ? 'Select Date'
                          : '${_toDate!.toLocal()}'.split(' ')[0],
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _selectTime(context, false),
                    child: Text(
                      _toTime == null
                          ? 'Select Time'
                          : _toTime!.format(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _checkAvailableRooms,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                    child: Text(
                      'Check Available Rooms',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Profile View
  Widget _buildProfileView() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(_auth.currentUser?.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        
        final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
        final user = _auth.currentUser;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: _buildStyledCard(
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 80,
                    color: _primaryColor,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Username: ${user?.email?.split('@')[0] ?? 'User'}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Email: ${user?.email ?? ''}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Role: ${userData['role'] ?? ''}",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Current Bookings View - Updated from the provided code
  Widget _buildCurrentBookingsView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bookings')
          .where('userId', isEqualTo: _auth.currentUser?.uid)
          .orderBy('fromDate', descending: true)
          .snapshots(),
      builder: (context, bookingSnapshot) {
        try {
          if (bookingSnapshot.hasError) {
            print("Error loading bookings: ${bookingSnapshot.error}");
            return Center(child: Text("Error loading bookings"));
          }
          
          if (bookingSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (!bookingSnapshot.hasData || bookingSnapshot.data!.docs.isEmpty) {
            return Center(
              child: _buildStyledCard(
                Center(child: Text('No current bookings')),
              ),
            );
          }

          final bookings = bookingSnapshot.data!.docs;
          final currentBookings = bookings.where((b) => 
              (b['toDate'] as Timestamp).toDate().isAfter(DateTime.now())
          ).toList();

          if (currentBookings.isEmpty) {
            return Center(
              child: _buildStyledCard(
                Center(child: Text('No current bookings')),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: currentBookings.length,
            itemBuilder: (context, index) {
              final booking = currentBookings[index];
              final status = booking['status'];
              Color statusColor;
              
              switch (status) {
                case 'approved': statusColor = Colors.green; break;
                case 'rejected': statusColor = Colors.red; break;
                case 'pending': default: statusColor = Colors.orange;
              }

              return _buildStyledCard(
                ListTile(
                  title: Text(
                    booking['roomName'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Block: ${booking['block']}"),
                      Text("Date: ${_formatDate(booking['fromDate'])}"),
                      Text("Time: ${_formatTime(booking['fromDate'])} - ${_formatTime(booking['toDate'])}"),
                      Text("Purpose: ${booking['purpose'] ?? 'Not specified'}"),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text("Status: "),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  leading: Icon(Icons.meeting_room, color: _primaryColor),
                ),
              );
            },
          );
        } catch (e) {
          print("Error fetching bookings: $e");
          return Center(child: Text("Error fetching bookings: ${e.toString()}"));
        }
      },
    );
  }

  // Previous Bookings View - Corrected version
Widget _buildPreviousBookingsView() {
  return StreamBuilder<QuerySnapshot>(
    stream: _firestore
        .collection('bookings')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .orderBy('fromDate', descending: true)
        .snapshots(),
    builder: (context, bookingSnapshot) {
      try {
        if (bookingSnapshot.hasError) {
          print("Error loading bookings: ${bookingSnapshot.error}");
          return Center(child: Text("Error loading bookings"));
        }
        
        if (bookingSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (!bookingSnapshot.hasData || bookingSnapshot.data!.docs.isEmpty) {
          return Center(
            child: _buildStyledCard(
              Center(child: Text('No previous bookings')),
            ),
          );
        }

        final bookings = bookingSnapshot.data!.docs;
        final previousBookings = bookings.where((b) => 
            (b['toDate'] as Timestamp).toDate().isBefore(DateTime.now()) &&
            b['status'] == 'approved'
        ).take(3).toList();

        if (previousBookings.isEmpty) {
          return Center(
            child: _buildStyledCard(
              Center(child: Text('No previous bookings')),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: previousBookings.length,
          itemBuilder: (context, index) {
            final booking = previousBookings[index];
            return _buildStyledCard(
              ListTile(
                title: Text(
                  booking['roomName'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Block: ${booking['block']}"),
                    Text("Date: ${_formatDate(booking['fromDate'])}"),
                    Text("Time: ${_formatTime(booking['fromDate'])} - ${_formatTime(booking['toDate'])}"),
                    Text("Purpose: ${booking['purpose'] ?? 'Not specified'}"),
                  ],
                ),
                leading: Icon(Icons.history, color: _primaryColor),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        );
      } catch (e) {
        print("Error fetching bookings: $e");
        return Center(child: Text("Error fetching bookings: ${e.toString()}"));
      }
    },
  );
}
  Widget _buildStyledCard(Widget child) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
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

class AvailableRoomsPage extends StatefulWidget {
  final DateTime fromDateTime;
  final DateTime toDateTime;

  AvailableRoomsPage({required this.fromDateTime, required this.toDateTime});

  @override
  _AvailableRoomsPageState createState() => _AvailableRoomsPageState();
}

class _AvailableRoomsPageState extends State<AvailableRoomsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DocumentSnapshot? _selectedRoom;
  final TextEditingController _purposeController = TextEditingController();

  Future<List<DocumentSnapshot>> _getAvailableRooms() async {
    final Timestamp fromTimestamp = Timestamp.fromDate(widget.fromDateTime);
    final Timestamp toTimestamp = Timestamp.fromDate(widget.toDateTime);

    final roomsSnapshot = await _firestore.collection('rooms').get();
    final allRooms = roomsSnapshot.docs;

    if (allRooms.isEmpty) {
      print("No rooms found.");
      return [];
    }

    final bookedRoomsQuery = await _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'approved')
        .where('toDate', isGreaterThan: fromTimestamp)
        .where('fromDate', isLessThan: toTimestamp)
        .get();

    final bookedRoomIds = <String>{};
    for (var doc in bookedRoomsQuery.docs) {
      bookedRoomIds.add(doc['roomId']);
    }

    final availableRooms = allRooms.where((room) => !bookedRoomIds.contains(room.id)).toList();
    return availableRooms;
  }

  Future<void> _bookRoom() async {
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a room')));
      return;
    }

    if (_purposeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter purpose of booking')),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('bookings').add({
        'userId': user.uid,
        'userName': user.email!.split('@')[0],
        'userEmail': user.email,
        'roomId': _selectedRoom!.id,
        'roomName': _selectedRoom!['room'],
        'block': _selectedRoom!['block'],
        'fromDate': widget.fromDateTime,
        'toDate': widget.toDateTime,
        'purpose': _purposeController.text,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking request sent successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send booking request: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Available Rooms')),
      body: _selectedRoom == null
          ? FutureBuilder<List<DocumentSnapshot>>(
              future: _getAvailableRooms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No rooms available for selected time slot'),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final room = snapshot.data![index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRoom = room),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.deepPurple, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              room['room'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text('Block: ${room['block']}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.deepPurple, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Booking Room: ${_selectedRoom!['room']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Block: ${_selectedRoom!['block']}'),
                    Text('Floor: ${_selectedRoom!['floor']}'),
                    Text('Capacity: ${_selectedRoom!['capacity']}'),
                    Text('Amenities: ${_selectedRoom!['amenities']}'),
                    SizedBox(height: 20),
                    TextField(
                      controller: _purposeController,
                      decoration: InputDecoration(
                        labelText: 'Enter event details',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _bookRoom,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                        child: Text('Book Room', style: TextStyle(fontSize: 16)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}