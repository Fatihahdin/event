import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'paymentpage.dart';

class SeatSelectionPage extends StatefulWidget {
  final String locationId;
  final String category;
  final String eventName;  // New parameters for event details
  final String eventDate;
  final String eventImage;
  final double ticketPrice;

  const SeatSelectionPage({
    Key? key,
    required this.locationId,
    required this.category,
    required this.eventName,  // Initialize new parameters
    required this.eventDate,
    required this.eventImage,
    required this.ticketPrice,
  }) : super(key: key);

  @override
  _SeatSelectionPageState createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  List<Map<String, dynamic>> seatRows = [];
  Set<String> selectedSeats = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSeats();
  }

  Future<void> fetchSeats() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('seats')
          .where('locationId', isEqualTo: widget.locationId)
          .where('category', isEqualTo: widget.category)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          errorMessage = 'No seats available for this location and category.';
          isLoading = false;
        });
        return;
      }

      setState(() {
        seatRows = [];
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data();
          if (data.containsKey('layout')) {
            seatRows = List<Map<String, dynamic>>.from(data['layout']);
          }
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching seats: $e';
        isLoading = false;
      });
    }
  }

  void toggleSeatSelection(String seatLabel) {
    setState(() {
      if (selectedSeats.contains(seatLabel)) {
        selectedSeats.remove(seatLabel);
      } else {
        selectedSeats.add(seatLabel);
      }
    });
  }

  void navigateToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          category: widget.category,
          selectedSeats: selectedSeats.toList(), // Convert Set<String> to List<String>
          eventName: widget.eventName,  // Pass event details to PaymentPage
          eventDate: widget.eventDate,
          eventLocation: widget.locationId,
          eventImage: widget.eventImage,
          ticketPrice: widget.ticketPrice,
        ),
      ),
    );
  }

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
          'SELECT SEATS',
          style: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.white)))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        // Custom Paint for the curved screen
                        Container(
                          height: constraints.maxHeight * 0.1,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: ScreenPainter(),
                          ),
                        ),
                        // Seats grid
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Column(
                                children: seatRows.map((row) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          row['row'], // Display the row label
                                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      // Display sections: left, middle, right
                                      ...['left', 'middle', 'right'].map((section) {
                                        List<Widget> seatWidgets = row['seats']
                                            .where((seat) => seat['section'] == section) // Filter seats by section
                                            .map<Widget>((seat) {
                                              final seatLabel = seat['label'];
                                              bool isSelected = selectedSeats.contains(seatLabel);

                                              return GestureDetector(
                                                onTap: () {
                                                  if (seat['occupied'] == false) {
                                                    toggleSeatSelection(seatLabel);
                                                  }
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Colors.cyan
                                                        : seat['occupied'] == true
                                                            ? Color(0xFFD4AF37)
                                                            : Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  width: 35,
                                                  height: 35,
                                                  child: Center(
                                                    child: Text(
                                                      seatLabel,
                                                      style: TextStyle(
                                                        color: isSelected || seat['occupied'] == true
                                                            ? Colors.black
                                                            : Colors.grey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            })
                                            .toList();

                                        // Return the seats in the section with some spacing
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Row(children: seatWidgets),
                                        );
                                      }).toList(),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        // Seat legend
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.circle, color: Colors.white, size: 8),
                                  SizedBox(width: 5),
                                  Text('Available', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.circle, color: Color(0xFFD4AF37), size: 8),
                                  SizedBox(width: 5),
                                  Text('Reserved', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.circle, color: Colors.cyan, size: 8),
                                  SizedBox(width: 5),
                                  Text('Selected', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Book Seats button
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFD4AF37),
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () {
                                navigateToPayment();
                              },
                              child: Text('Book Seat(S)', style: TextStyle(fontSize: 14)),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}

// Custom Painter for the curved screen
class ScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
