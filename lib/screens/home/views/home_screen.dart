import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:replanto/screens/auth/blocs/bloc/sign_in_bloc.dart';

import 'widgets/CarouselPanel.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            icon: Icon(Icons.settings, color: Colors.green),
            onPressed: () {
              // Parameter button action
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.news_solid),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.add_circled_solid, size: 40), // Larger + icon
            label: 'Add Plant',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search_circle_fill),
            label: 'Research',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.arrow_right_to_line),
            label: 'Logout',
          ),
        ],
        onTap: (index) {
          // Handle navigation on tap
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Homepage()),
              );
              break;
            case 1:
            // Navigate to News Page
              break;
            case 2:
            // Add Plant action
              break;
            case 3:
            // Navigate to Research Page
              break;
            case 4:
              context.read<SignInBloc>().add(SignOutRequired());
              break;
          }
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('plants').snapshots(),
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
