import 'dart:developer';

import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:replanto/screens/home/views/widgets/AI%20assistance%20chatbot/chat_page.dart';
import 'package:replanto/screens/home/views/widgets/CarouselPanel.dart';
import 'package:replanto/screens/home/views/widgets/user_screen.dart';
import 'package:user_repository/user_repository.dart';
import 'package:plant_repository/plant_repository.dart'; // Ensure this import is correct

import 'createPlant.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _searchQuery = '';
  int _selectedIndex = 0;
  String? _userId;
  MyUser _myUser = MyUser.empty;

  final FirebasePlantRepo plantRepo = FirebasePlantRepo(); // Initialize your plant repository
  late FirebaseUserRepo userRepo; // Declare but don't initialize yet

  @override
  void initState() {
    super.initState();
    userRepo = FirebaseUserRepo(plantRepo: plantRepo); // Initialize in initState
    _fetchUserId();
  }

  void _onProfileButtonPressed() {
    if (_userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(userId: _userId!,),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to sign in first.')),
      );
    }
  }

  void _fetchUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      _fetchMyUserData(user.uid); // Fetch MyUser data
    }
  }

  void _fetchMyUserData(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userEntity = MyUserEntity.fromDocument(userDoc.data() as Map<String, dynamic>);
        setState(() {
          _myUser = MyUser.fromEntity(userEntity);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found.')),
        );
      }
    } catch (e) {
      log('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching user data.')),
      );
    }
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
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
        break;
      case 2:
        if (_userId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPlantScreen(userId: _userId!)),
          );
        }
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
            icon: const Icon(CupertinoIcons.person_alt_circle, color: Colors.green),
            onPressed: _onProfileButtonPressed,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
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
            icon: const Icon(CupertinoIcons.add_circled_solid, size: 30),
            title: const Text('Add Plant'),
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

          return CarouselPanel(
            plantDocuments: plants,
            currentUser: _myUser,
            plantRepo: plantRepo,
            userRepo: userRepo,
          );
        },
      ),
    );
  }
}
