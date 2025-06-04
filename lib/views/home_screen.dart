import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tpm_fp/models/user_model.dart';
import 'package:tpm_fp/network/auth_service.dart';
import 'package:tpm_fp/views/feedback_screen.dart';
import 'package:tpm_fp/views/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  int _currentIndex = 0;
  List<Widget> _screens = [
    _MainMenuContent(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUserData();
    setState(() {
      _currentUser = user;
      _screens = [
        _MainMenuContent(),
        ProfileScreen(),
        FeedbackScreen(currentUser: _currentUser),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.logout();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: _currentIndex == 0
          ? ListView(
              padding: EdgeInsets.all(16),
              children: [
                Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      _currentUser != null
                          ? 'Welcome, ${_currentUser!.fullname}!'
                          : 'Welcome',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
                _MainMenuContent(),
              ],
            )
          : _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedbacks',
          ),
        ],
      ),
    );
  }
}

class _MainMenuContent extends StatelessWidget {
@override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMenuCard(
          context: context,
          icon: Icons.calendar_month,
          title: 'Schedule',
          onTap: () => Get.toNamed('/schedule'),
        ),
        _buildMenuCard(
          context: context,
          icon: Icons.attach_money,
          title: 'Currency  Converter',
          onTap: () => Get.toNamed('/currency'),
        ),
        _buildMenuCard(
          context: context,
          icon: Icons.access_time,
          title: 'Time Zone Converter',
          onTap: () => Get.toNamed('/time'),
        ),
        _buildMenuCard(
          context: context,
          icon: Icons.map,
          title: 'Map',
          onTap: () => Get.toNamed('/map'),
        ),
        _buildMenuCard(
          context: context,
          icon: Icons.explore,
          title: 'Compass',
          onTap: () => Get.toNamed('/compass'),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.red),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
