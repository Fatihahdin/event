import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'custom_bottom_navigation_bar.dart';
import 'eventsdetailspage.dart';
import 'home_page.dart';
import 'ticket_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('date', descending: false)
          .get();

      final now = DateTime.now();

      // Map the documents to include eventId and filter out past events
      final events = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['eventId'] = doc.id;
        return data;
      }).where((event) {
        final Timestamp? eventDate = event['date'];
        if (eventDate == null) return false;
        return eventDate.toDate().isAfter(now);
      }).toList();

      // If the search query is not empty, filter the events by name
      if (_searchQuery.isNotEmpty) {
        return events.where((event) {
          final eventName = event['name'] ?? '';
          return eventName.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }

      return events;
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'EVENTS',
          style: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color.fromARGB(255, 193, 156, 63)),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(  
              future: fetchEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No events available', style: TextStyle(color: Colors.white)));
                }

                final events = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return EventCard(event: event);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildDrawerItem(context, Icons.home, 'Home', const Home()),
          _buildDrawerItem(context, Icons.event, 'Events', const EventsPage()),
          _buildDrawerItem(context, Icons.confirmation_number, 'My Tickets', const TicketPage()),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search events by name',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white24,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            event['imageUrl'] ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          event['name'] ?? 'No Name',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                event['locationId'] ?? 'No Location',
                style: const TextStyle(fontSize: 14, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'RM ${event['price'] ?? 'Free'}',
              style: const TextStyle(color: Colors.blue, fontSize: 14),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatDate(event['date']),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsPage(event: event, eventId: event['eventId']),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'No Date';
    final dateTime = timestamp.toDate();
    return '${dateTime.day} ${_getMonthName(dateTime.month)}';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}


