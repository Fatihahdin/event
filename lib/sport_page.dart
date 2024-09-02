import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SportPage extends StatelessWidget {
  const SportPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchSportEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('category', isEqualTo: 'Sport')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching sport events: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sport'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchSportEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Sport Events Available'));
          }

          final events = snapshot.data!;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                leading: event['imageUrl'] != null
                    ? Image.network(event['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                title: Text(event['name'] ?? 'No Name'),
                subtitle: Text(event['category'] ?? 'No Category'),
              );
            },
          );
        },
      ),
    );
  }
}
