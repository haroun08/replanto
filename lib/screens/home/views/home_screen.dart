import 'dart:developer';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:replanto/screens/home/views/widgets/AI%20assistance%20chatbot/chat_page.dart';
import 'package:replanto/screens/home/views/widgets/Calender.dart';
import 'package:replanto/screens/home/views/widgets/RealTime%20Fetching/RealTimePage.dart';
import 'package:replanto/screens/home/views/widgets/Shop_Page.dart';
import 'package:replanto/screens/home/views/widgets/user_screen.dart';
import 'package:user_repository/user_repository.dart';
import 'package:plant_repository/plant_repository.dart';

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

  final FirebasePlantRepo plantRepo = FirebasePlantRepo();
  late FirebaseUserRepo userRepo;

  @override
  void initState() {
    super.initState();
    userRepo = FirebaseUserRepo(plantRepo: plantRepo);
    _fetchUserId();
  }

  void _onProfileButtonPressed() {
    if (_userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(userId: _userId!),
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
      _fetchMyUserData(user.uid);
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
      _searchQuery = query.toLowerCase();
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
          MaterialPageRoute(builder: (context) =>  ShopPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalendarReplanto()
          ),
        );
        break;
      case 3:
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
            icon: Icon(CupertinoIcons.time_solid, color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RealTimePage(

                )),
              );            },
          ),
          _myUser.picture.isNotEmpty
              ? GestureDetector(
            onTap: _onProfileButtonPressed,
            child: CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(_myUser.picture, scale: 2),
            ),
          )
              : GestureDetector(
            onTap: _onProfileButtonPressed,
            child: IconButton(
              icon: const Icon(CupertinoIcons.person_alt_circle, color: Colors.green),
              onPressed: () {
                // This action is handled by GestureDetector
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Find User...',
                border: InputBorder.none,
                filled: true,
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
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
            icon: Icon(CupertinoIcons.home, color: Theme.of(context).colorScheme.primary),
            title: Text('Home', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          BottomNavyBarItem(
            icon: const Icon(CupertinoIcons.shopping_cart, color: Colors.green),
            title: const Text('Shop', style: TextStyle(color: Colors.green)),
            activeColor: Colors.green,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.calendar_today, color: Colors.green),
            title: const Text('Calendar', style: TextStyle(color: Colors.green)),
            activeColor: Colors.green,
          ),
          BottomNavyBarItem(
            icon: const Icon(CupertinoIcons.add_circled_solid, size: 30, color: Colors.green),
            title: const Text('Add Plant', style: TextStyle(color: Colors.green)),
            activeColor: Colors.green,
          ),

        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading users.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs;

          if (users == null || users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final filteredUsers = users.where((user) {
            final userData = user.data() as Map<String, dynamic>;
            final userName = userData['name']?.toLowerCase() ?? '';
            return userName.contains(_searchQuery);
          }).toList();

          if (filteredUsers.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredUsers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16.0),
            itemBuilder: (context, index) {
              final userData = filteredUsers[index].data() as Map<String, dynamic>;
              final userId = filteredUsers[index].id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(userId: userId),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(userData['picture'] ?? 'https://example.com/default-picture.jpg'),
                          radius: 30,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name'] ?? 'No name',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (userData['age'] != null)
                                Text(
                                  'Age: ${userData['age']}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              if (userData['age'] == null)
                                Text(
                                  'No age provided',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                      ],
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
}
