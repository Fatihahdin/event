import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllEventsPage extends StatelessWidget {
  const AllEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<String>>(
        future: fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events available'));
          }

          final events = snapshot.data!;
          final screenWidth = MediaQuery.of(context).size.width;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final eventUrl = events[index];
              return Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(eventUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                height: screenWidth * 0.6, // Adjust height as needed
                child: Center(
                  child: Text(
                    'Event $index', // Customize as needed
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<String>> fetchEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('events').get();
      return snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }
}
