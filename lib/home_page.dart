import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/current_month_events_widget.dart';
import 'package:event/custom_app_bar.dart';
import 'package:event/custom_bottom_navigation_bar.dart';
import 'package:event/past_events.dart';
import 'package:event/upcoming_events_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'concert_page.dart';
import 'drawer_widget.dart';
import 'eventsdetailspage.dart';
import 'movie_page.dart';
import 'sport_page.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final Set<String> shownNotifications = {};

  @override
  void initState() {
    super.initState();
    setupFCM();
    requestNotificationPermissions();
    getTokenAndSave();
  }

  Future<void> requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void setupFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!mounted) return;

      if (message.notification != null) {
        String notificationId = '${message.notification!.title}:${message.notification!.body}';
        if (!shownNotifications.contains(notificationId)) {
          shownNotifications.add(notificationId);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${message.notification!.title}: ${message.notification!.body}'),
            ),
          );
          saveNotificationToFirestore(message, notificationId);
        } else {
          print('Duplicate notification ignored: $notificationId');
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (!mounted) return;
      if (message.data['eventId'] != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsPage(
              event: message.data,
              eventId: message.data['eventId'],
            ),
          ),
        );
      }
    });
  }

  /// Save notifications to Firestore
  Future<void> saveNotificationToFirestore(RemoteMessage message, String notificationId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(notificationId)
            .set({
          'title': message.notification?.title,
          'message': message.notification?.body,
          'timestamp': FieldValue.serverTimestamp(),
          'eventId': message.data['eventId'],
        }, SetOptions(merge: true));
      } catch (e) {
        print('Error saving notification to Firestore: $e');
      }
    }
  }

  /// Get FCM token and save it to Firestore
  Future<void> getTokenAndSave() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'fcmToken': token}, SetOptions(merge: true));
        }
      }
    } catch (e) {
      print('Error while getting FCM token: $e');
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: CustomAppBar(), // Gunakan Custom App Bar
    body: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCarouselSlider(context),
                  const SizedBox(height: 16),
                  _buildCategoryTabs(context),
                  const SizedBox(height: 16),
                  const CurrentMonthEventsWidget(),
                  const SizedBox(height: 16),
                  const Text(
                    'UPCOMING',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFe2a800),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const UpcomingEventsWidget(),
                  const SizedBox(height: 16),
                  PastEventsWidget(),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    drawer: const CustomDrawer(),
  );
}

Widget _buildCategoryTabs(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const Text(
        'Categories',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 0, 0, 0), // Gold color
        ),
      ),
      const SizedBox(height: 16),
      // Using GridView for responsive layout
      GridView.count(
        crossAxisCount: 3, // 3 columns for categories
        childAspectRatio: 1, // Square aspect ratio
        shrinkWrap: true, // Makes grid scrollable
        physics: const NeverScrollableScrollPhysics(), // Disable grid scroll
        crossAxisSpacing: 20,
        mainAxisSpacing: 16,
        children: <Widget>[
          _buildCategoryIcon(
            context,
            Icons.music_note,
            'Concert',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConcertPage()),
              );
            },
          ),
          _buildCategoryIcon(
            context,
            FontAwesomeIcons.soccerBall, // Football icon from Font Awesome
            'Sport',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SportPage()),
              );
            },
          ),
          _buildCategoryIcon(
            context,
            Icons.movie,
            'Movie',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MoviePage()),
              );
            },
          ),
        ],
      ),
    ],
  );
}

Widget _buildCategoryIcon(
    BuildContext context, IconData icon, String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6F4F37), // Dark brown
                Color(0xFFF5F5DC), // Light beige
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(0xFFD9C0A2), // Lighter beige color for border
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 40,
            color: Colors.white, // White icons for contrast
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6F4F37), // Dark brown for text color
          ),
        ),
      ],
    ),
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

 Widget _buildCarouselSlider(BuildContext context) {
  return FutureBuilder<List<String>>(
    future: fetchAds(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return const Center(child: Text('Error loading ads'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No ads available'));
      } else {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 6), // Soft shadow
              ),
            ],
          ),
          child: CarouselSlider.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index, realIndex) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20), // Rounded corners
                child: Image.network(
                  snapshot.data![index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            },
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              viewportFraction: 1.0,
              pageSnapping: true,
              onPageChanged: (index, reason) {
                // You can add custom logic for page change here if necessary
              },
            ),
          ),
        );
      }
    },
  );
}
}

