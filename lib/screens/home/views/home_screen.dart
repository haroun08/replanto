import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:replanto/screens/home/views/widgets/CarouselPanel.dart';
import 'package:replanto/screens/home/views/widgets/community_page.dart';
import 'package:replanto/screens/home/views/widgets/user_screen.dart';

import '../../auth/blocs/bloc/sign_in_bloc.dart';
import 'createPlant.dart';
class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}
class _HomepageState extends State<Homepage> {
  String _searchQuery = '';
  int _selectedIndex = 0; // Track the selected index for BottomNavyBar
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  void _fetchUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userId = user?.uid;
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>const CommunityPage() )
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddPlantScreen(userId: _userId!)),
        );
        break;

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/replanto.png',
            scale: 14,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.green),
            onPressed: () {
              // Notification button action
            },
          ),
          IconButton(
            icon: Icon(CupertinoIcons.person_alt_circle, color: Colors.green),
            onPressed: () {
              if (_userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(userId: _userId!),
                  ),
                );
              } else {
                // Handle case where user is not logged in
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User is not logged in')),
                );
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: _updateSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Find your plant...',
                border: InputBorder.none,
                filled: true,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        itemCornerRadius: 24,
        containerHeight: 56,
        backgroundColor: Colors.white,
        onItemSelected: _onItemSelected,
        items: [
          BottomNavyBarItem(
            icon: Icon(CupertinoIcons.home),
            title: Text('Home'),
            activeColor: Colors.green,
          ),
          BottomNavyBarItem(
            icon: const Icon(CupertinoIcons.news_solid),
            title: const Text('Community'),
            activeColor: Colors.green,
          ),
          BottomNavyBarItem(
            icon: Icon(CupertinoIcons.add_circled_solid, size: 30),
            title: Text('Add Plant'),
            activeColor: Colors.green,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _searchQuery.isEmpty
            ? FirebaseFirestore.instance.collection('plants').snapshots()
            : FirebaseFirestore.instance
            .collection('plants')
            .where('name', isGreaterThanOrEqualTo: _searchQuery)
            .where('name', isLessThan: '$_searchQuery\uf8ff')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading plants.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final plants = snapshot.data?.docs;

          if (plants == null || plants.isEmpty) {
            return const Center(child: Text('No plants found.'));
          }

          return CarouselPanel(plantDocuments: plants);
        },
      ),
    );
  }
}
