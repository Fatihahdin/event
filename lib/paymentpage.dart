import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String eventImage;
  final List<String> selectedSeats;
  final double ticketPrice;
  final String category; // Add the category parameter

  const PaymentPage({
    Key? key,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.eventImage,
    required this.selectedSeats,
    required this.ticketPrice,
    required this.category, // Add the category parameter
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = 'PayPal';

  @override
  Widget build(BuildContext context) {
    double subtotal = widget.selectedSeats.length * widget.ticketPrice;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'DETAILS',
          style: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Details
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: NetworkImage(widget.eventImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.eventName,
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(widget.eventDate.toString(), style: TextStyle(color: Colors.white, fontSize: 14)), // Ensure it's a string
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.yellow, size: 16),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(widget.eventLocation.toString(), // Ensure it's a string
                                  style: TextStyle(color: Colors.white, fontSize: 14)),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Category: ${widget.category}', // Display category
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Order Summary
              Text(
                'Order Summary',
                style: TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Seat', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text(widget.selectedSeats.join(', '), style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text('RM${subtotal.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('RM${subtotal.toStringAsFixed(2)}', style: TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 20),

              // Payment Method
              Text(
                'Payment Method',
                style: TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildPaymentMethodOption('PayPal', Icons.payment), // Corrected icon
              _buildPaymentMethodOption('Credit/Debit Card', Icons.credit_card),
              SizedBox(height: 20),

              // Checkout and Payment Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD4AF37),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // Implement your checkout and payment logic here
                    checkoutAndPayment(context);
                  },
                  child: Text('Checkout and Payment', style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Example function for checkout and payment logic
  void checkoutAndPayment(BuildContext context) {
    // Logic for handling payment processing based on the selected payment method
    if (selectedPaymentMethod == 'PayPal') {
      // Redirect to PayPal payment page or initiate PayPal SDK
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Redirecting to PayPal...')),
      );
    } else if (selectedPaymentMethod == 'Credit/Debit Card') {
      // Implement card payment flow
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing Credit/Debit Card Payment...')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a payment method.')),
      );
    }
  }

  Widget _buildPaymentMethodOption(String method, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedPaymentMethod == method ? Colors.yellow : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                method,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (selectedPaymentMethod == method)
              Icon(Icons.check_circle, color: Colors.yellow),
          ],
        ),
      ),
    );
  }
}
