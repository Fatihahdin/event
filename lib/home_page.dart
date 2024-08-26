import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/all_events_page.dart';
import 'package:event/concert_page.dart';
import 'package:event/movie_page.dart';
import 'package:event/sport_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'eventspage.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Use the new context
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Add notification functionality here
            },
          ),
        ],
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildCategoryTabs(context),
                    const SizedBox(height: 16),
                    _buildCarouselSlider(context),
                    const SizedBox(height: 16),
                    const Text(
                      'EVENTS',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildEventsFromFirebase(context),
                    const SizedBox(height: 16),
                    const Text(
                      'UPCOMING',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildUpcomingEvents(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context), // Pass the context here
      drawer: _buildDrawer(context), // Add the Drawer widget here
    );
  }

  Future<String> getUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Safely cast the data to Map<String, dynamic>
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          return userData['username'] ?? 'User';
        } else {
          return 'User'; // Default username if document does not exist
        }
      } catch (e) {
        print('Error fetching username: $e');
        return 'User'; // Default username in case of error
      }
    } else {
      return 'User'; // Default username if no user is logged in
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: FutureBuilder<String>(
        future: getUsername(),
        builder: (context, snapshot) {
          String username = 'User'; // Default username
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              username = snapshot.data!;
            } else if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
            }
          }
          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hi, $username',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              ListTile(
                leading: Icon(Icons.event),
                title: Text('Events'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/events');
                },
              ),
              ListTile(
                leading: Icon(Icons.confirmation_number),
                title: Text('My Tickets'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/my-tickets');
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('About Us'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/about-us');
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Sign Out'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login'); // Adjust to your login route
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConcertPage()),
              );
            },
            child: Chip(
              label: Text(
                'Concert',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              backgroundColor: Color(0xFFF6F6F6),
              shape: StadiumBorder(
                side: BorderSide(color: Colors.black, width: 0),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SportPage()),
              );
            },
            child: Chip(
              label: Text(
                'Sport',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              backgroundColor: Color(0xFFF6F6F6),
              shape: StadiumBorder(
                side: BorderSide(color: Colors.black, width: 0),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MoviePage()),
              );
            },
            child: Chip(
              label: Text(
                'Movie',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
              backgroundColor: Color(0xFFF6F6F6),
              shape: StadiumBorder(
                side: BorderSide(color: Colors.black, width: 0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<String>> fetchAds() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('ads')
          .get();

      return snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
    } catch (e) {
      print('Error fetching ads: $e');
      return [];
    }
  }

  Future<List<String>> fetchEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .get();

      return snapshot.docs.map((doc) => doc['imageUrl'] as String).toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  Widget _buildCarouselSlider(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchAds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No ads available'));
        }

        final ads = snapshot.data!;
        final screenWidth = MediaQuery.of(context).size.width;

        return CarouselSlider(
          options: CarouselOptions(
            height: screenWidth * 0.5625, // Set height based on the desired aspect ratio (16:9 here)
            autoPlay: true, // Auto-play is enabled
            enlargeCenterPage: true,
            viewportFraction: 1.0, // Ensures the slider fills the width of the screen
          ),
          items: ads.map((adUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: screenWidth, // Set the container width

                  margin: const EdgeInsets.symmetric(horizontal: 0.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(adUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEventsFromFirebase(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'EVENTS',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllEventsPage()),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<String>>(
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
            final cardWidth = MediaQuery.of(context).size.width * 0.7; // Adjust width based on desired size
            final cardHeight = cardWidth * 0.6; // Adjust height based on aspect ratio

            return Container(
              height: cardHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final eventUrl = events[index];
                  return Container(
                    width: cardWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: NetworkImage(eventUrl),
                        fit: BoxFit.cover, // Ensures the image is centered and covers the card
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }


  Widget _buildUpcomingEvents() {
    return Column(
      children: [
        _buildUpcomingEventCard('Fun Run', 'Sport', 'RM50', '15', 'THU'),
        const SizedBox(height: 16),
        _buildUpcomingEventCard('Exhuma', 'Movie', 'RM2', '16', 'FRI'),
      ],
    );
  }

  Widget _buildUpcomingEventCard(
      String title, String category, String price, String day, String weekday) {
    return Row(
      children: [
        // Date and weekday section
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFCAA55D), // Adjust the color as needed
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                day,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white, // Text color for day
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                weekday.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white, // Text color for weekday
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(category),
                const SizedBox(height: 8),
                Text(price),
              ],
            ),
          ),
        ),
      ],
    );
  }

BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
  return BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.event),
        label: 'Events',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.confirmation_number),
        label: 'Tickets',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ],
    backgroundColor: Colors.grey[200], // Background color of the BottomNavigationBar
    selectedItemColor: const Color.fromARGB(255, 193, 156, 63), // Color for the selected item
    unselectedItemColor: Colors.black54, // Color for unselected items
    showSelectedLabels: true, // Show labels for selected items
    showUnselectedLabels: true, // Show labels for unselected items
    type: BottomNavigationBarType.fixed, // Ensures that the items have equal spacing
    onTap: (int index) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EventsPage()),
          );
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/my-tickets');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    },
  );
}

}
