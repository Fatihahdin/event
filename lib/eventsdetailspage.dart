import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'paymentpage.dart';
import 'seatselectionpage.dart';

class EventDetailsPage extends StatefulWidget {
  final Map<String, dynamic> event;
  final String eventId;

  const EventDetailsPage({super.key, required this.event, required this.eventId});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  int _selectedTicketCount = 1;
  late int _totalAvailableQuantity;
  late GoogleMapController _mapController;
  late LatLng _eventLocation;

  @override
  void initState() {
    super.initState();
    _totalAvailableQuantity = widget.event['quantity'] ?? 0;
    _eventLocation = LatLng(6.44197, 100.2731); // Default coordinates
    _checkAndRequestPermissions(); // Request location permissions
  }

  // Method to check and request location permissions
  Future<void> _checkAndRequestPermissions() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled")),
      );
      return;
    }

    // Check for location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return;
      }
    }

    // Get the current position after permissions are granted
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _eventLocation = LatLng(position.latitude, position.longitude);  // Update location
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 254, 254),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.event['name'] ?? 'Event Details',
          style: const TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: Image.network(
                    widget.event['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text('Image not available', style: TextStyle(color: Colors.white)));
                    },
                  ),
                ),
                Positioned(
                  top: 200,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event['name'] ?? 'Event Name',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.black, size: 16),
                                const SizedBox(width: 5),
                                Text(
                                  _formatDate(widget.event['date']),
                                  style: const TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.confirmation_number, color: Colors.black, size: 16),
                                const SizedBox(width: 5),
                                Text(
                                  'RM ${widget.event['price'].toString()}',
                                  style: const TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.black),
                            const SizedBox(width: 8),
                            Text(
                              widget.event['time']?.toString() ?? '8:00 PM',
                              style: const TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.black),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.event['locationId'] ?? 'No Location',
                                style: const TextStyle(color: Colors.black, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 125),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Details',
                    style: TextStyle(color: Color.fromARGB(255, 14, 14, 14), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Event Organizers: ${widget.event['organizers'] ?? 'No Organizer Info'}',
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Event Details: ${widget.event['details'] ?? 'No Event Details'}',
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Location',
                    style: TextStyle(color: Color.fromARGB(255, 8, 8, 8), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey[800],
                    ),
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;  // Initialize the map controller
                      },
                      initialCameraPosition: CameraPosition(
                        target: _eventLocation,
                        zoom: 15,
                      ),
                      myLocationEnabled: true, // Enable 'My Location' layer
                      markers: {
                        Marker(
                          markerId: const MarkerId('eventLocation'),
                          position: _eventLocation,
                          infoWindow: InfoWindow(
                            title: widget.event['locationId'] ?? 'Location',
                          ),
                        ),
                      },
                      // *** Add the gestureRecognizers here ***
                      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                        Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                        Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.event['category'] == 'Sport') _ticketCountSelector(),
                  const SizedBox(height: 20),
                  const Text(
                    'Terms And Policies',
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'This Ticketing Term and Conditions set out the terms and conditions applicable to purchase of Ticket from us.',
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Center(
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: _totalAvailableQuantity > 0
          ? () {
              _purchaseTickets();
              // Optionally reduce quantity here if a ticket is purchased
              setState(() {
                _totalAvailableQuantity--;
              });
            }
          : null, // Disable the button when quantity is 0
      child: Text(
        _totalAvailableQuantity > 0 ? 'Buy Now' : 'Sold Out',
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    ),
  ),
),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketCountSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Select number of tickets', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      DropdownButton<int>(
        value: _selectedTicketCount,
        items: List.generate(_totalAvailableQuantity, (index) => index + 1)
            .map((count) => DropdownMenuItem(
                  value: count,
                  child: Text('$count', style: const TextStyle(color: Color.fromARGB(255, 186, 166, 166))),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedTicketCount = value ?? 1;
          });
        },
        dropdownColor: const Color.fromARGB(255, 255, 255, 255),
        iconEnabledColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      const SizedBox(height: 5),
      Text(
        'Remaining tickets: ${_totalAvailableQuantity - _selectedTicketCount}',
        style: const TextStyle(color: Color.fromARGB(255, 9, 9, 9), fontSize: 16),
      ),
    ],
  );

  // Handle ticket purchase
  void _purchaseTickets() async {
    // Reduce the quantity in Firestore
    int newQuantity = _totalAvailableQuantity - _selectedTicketCount;

    // Update Firestore
    await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
      'quantity': newQuantity
    });

    // Check event category and navigate accordingly
    if (widget.event['category'] == 'Sport') {
      // Navigate to PaymentPage for sport events
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            eventId: widget.eventId,
            layoutId: widget.event['layoutId'], // Pass layoutId
            locationId: widget.event['locationId'], // Pass locationId
            category: widget.event['category'], // Pass category
            name: widget.event['name'],
            date: _formatDate(widget.event['date']),
            time: widget.event['time']?.toString() ?? '8:00 PM',
            imageUrl: widget.event['imageUrl'],
            price: (widget.event['price'] is int) ? widget.event['price'].toDouble() : double.parse(widget.event['price'].toString()),
            selectedSeats: [], // Pass the selected seats (none for sport)
            selectedTicketCount: _selectedTicketCount, // Pass the selected ticket count
          ),
        ),
      );
    } else {
      // Navigate to SeatSelectionPage for concert or movie events
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeatSelectionPage(
            eventId: widget.eventId,
            layoutId: widget.event['layoutId'], // Pass layoutId
            locationId: widget.event['locationId'], // Pass locationId
            category: widget.event['category'], // Pass category
            name: widget.event['name'],
            date: _formatDate(widget.event['date']),
            time: widget.event['time']?.toString() ?? '8:00 PM',
            imageUrl: widget.event['imageUrl'],
            price: (widget.event['price'] is int) ? widget.event['price'].toDouble() : double.parse(widget.event['price'].toString()),
          ),
        ),
      );
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'No Date';
    if (date is Timestamp) {
      final dateTime = date.toDate();
      return '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}'; 
    } else if (date is DateTime) {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}'; 
    } else {
      return 'Invalid Date';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}


