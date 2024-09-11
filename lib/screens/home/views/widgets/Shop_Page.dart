import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_repository/plant_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'CarouselPanel.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<QueryDocumentSnapshot> _plantDocuments = [];
  List<QueryDocumentSnapshot> _filteredPlantDocuments = [];
  MyUser _currentUser = MyUser.empty;
  late FirebasePlantRepo _plantRepo;
  late FirebaseUserRepo _userRepo;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _plantRepo = FirebasePlantRepo();
    _userRepo = FirebaseUserRepo(plantRepo: _plantRepo);
    _fetchPlants();
    _fetchCurrentUser();
  }

  Future<void> _fetchPlants() async {
    try {
      final plantSnapshot = await FirebaseFirestore.instance.collection('plants').get();
      setState(() {
        _plantDocuments = plantSnapshot.docs;
        _filterPlants();
      });
    } catch (e) {
      print('Error fetching plants: $e');
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userEntity = MyUserEntity.fromDocument(userDoc.data() as Map<String, dynamic>);
          setState(() {
            _currentUser = MyUser.fromEntity(userEntity);
          });
        }
      }
    } catch (e) {
      print('Error fetching current user: $e');
    }
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _filterPlants();
    });
  }

  void _filterPlants() {
    if (_searchQuery.isNotEmpty) {
      _filteredPlantDocuments = _plantDocuments.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name']?.toString() ?? '';
        return name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    } else {
      _filteredPlantDocuments = _plantDocuments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("REPLANTO Shop ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50), // Increased height for search field
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 8.0),
            child: Column(
              children: [
                TextField(
                  onChanged: _updateSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Find Plant...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                    ),
                    filled: true,
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _filteredPlantDocuments.isEmpty || _currentUser == MyUser.empty
          ? const Center(child: CircularProgressIndicator())
          : CarouselPanel(
        plantDocuments: _filteredPlantDocuments,
        currentUser: _currentUser,
        plantRepo: _plantRepo,
        userRepo: _userRepo,
      ),
    );
  }
}
