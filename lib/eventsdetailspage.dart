import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore to handle Timestamp
import 'package:flutter/material.dart';

import 'paymentpage.dart'; // Import the payment page
import 'seatselectionpage.dart'; // Import the seat selection page

class EventDetailsPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          event['name'] ?? 'Event Details',
          style: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none, // Allows the card to overflow the image
              children: [
                // Event image
                Container(
                  width: double.infinity,
                  height: 250,
                  child: Image.network(
                    event['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
                // Event details card
                Positioned(
                  top: 200, // Adjust this value to control the overlap amount
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['name'] ?? 'Event Name',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.black, size: 16),
                                SizedBox(width: 5),
                                Text(
                                  _formatDate(event['date']),
                                  style: TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.confirmation_number, color: Colors.black, size: 16),
                                SizedBox(width: 5),
                                Text(
                                  'RM ${event['price'].toString()}', // Convert price to String
                                  style: TextStyle(color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              event['time']?.toString() ?? '8.00 P.M', // Convert time to String if necessary
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.black),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                event['locationId'] ?? 'No Location',
                                style: TextStyle(color: Colors.black, fontSize: 16),
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
            SizedBox(height: 150),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map or image
                  Text(
                    'LOCATION',
                    style: TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey[800], // Placeholder for map or image
                    ),
                    child: Center(
                      child: Text(
                        'Map or Image Placeholder',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Terms and policies
                  Text(
                    'Term And Policies',
                    style: TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'This Ticketing Term and Conditions set out the terms and conditions applicable to purchase of Ticket from us.',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  // Buy Now button with increased width
                  Center(
                    child: SizedBox(
                      width: double.infinity, // Makes the button full width
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD4AF37), // Updated color to D4AF37
                          foregroundColor: Colors.black, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // Rounded corners
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          // Navigate based on event category
                          if (event['category'] == 'Sport') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentPage(
                                  eventName: event['name'],  // Added missing argument
                                  eventDate: _formatDate(event['date']),  // Added missing argument
                                  eventLocation: event['locationId'],  // Added missing argument
                                  eventImage: event['imageUrl'],  // Added missing argument
                                  selectedSeats: [],  // Example seats
                                  ticketPrice: (event['price'] is int) ? event['price'].toDouble() : double.parse(event['price'].toString()), // Safely convert price
                                  category: event['category'],  // Pass the category parameter
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SeatSelectionPage(
                                  locationId: event['locationId'], // Pass locationId parameter
                                  category: event['category'], // Pass category parameter
                                  eventName: event['name'],  // Pass event name
                                  eventDate: _formatDate(event['date']),  // Pass event date
                                  eventImage: event['imageUrl'],  // Pass event image
                                  ticketPrice: (event['price'] is int) ? event['price'].toDouble() : double.parse(event['price'].toString()), // Safely convert price
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Buy Now',
                          style: TextStyle(fontSize: 16, color: Colors.black), // Text color adjusted to black
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'No Date';
    if (date is Timestamp) {
      final dateTime = date.toDate(); // Convert Firestore Timestamp to DateTime
      return '${dateTime.day} ${_getMonthName(dateTime.month)}'; // Removed the year from the format
    } else if (date is DateTime) {
      return '${date.day} ${_getMonthName(date.month)}'; // Removed the year from the format
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
