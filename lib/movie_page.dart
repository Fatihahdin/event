import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MoviePage extends StatelessWidget {
  const MoviePage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchMovieEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('category', isEqualTo: 'Movie')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching movie events: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchMovieEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Movie Events Available'));
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
