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
  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _screens = [
      _MainMenuContent(key: const Key('main_menu_content')),
      ProfileScreen(key: const Key('profile_screen'), onProfileUpdated: _loadCurrentUser),
      FeedbackScreen(key: const Key('feedback_screen'), currentUser: _currentUser),
    ];
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUserData();
    setState(() {
      _currentUser = user;
      _screens = [
        _MainMenuContent(key: const Key('main_menu_content')),
        ProfileScreen(key: const Key('profile_screen'), onProfileUpdated: _loadCurrentUser),
        FeedbackScreen(key: const Key('feedback_screen'), currentUser: _currentUser),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('home_screen'),
      backgroundColor: Colors.black,
      appBar: AppBar(
        key: const Key('home_app_bar'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            key: const Key('logout_button'),
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
              key: const Key('home_list_view'),
              padding: EdgeInsets.all(16),
              children: [
                Column(
                  key: const Key('welcome_column'),
                  children: [
                    Image.asset(
                      key: const Key('logo_image'),
                      'assets/images/logo.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      key: const Key('welcome_text'),
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
                _MainMenuContent(key: const Key('main_menu_content')),
              ],
            )
          : _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        key: const Key('bottom_navigation'),
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
            key: const Key('home_tab'),
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            key: const Key('profile_tab'),
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            key: const Key('feedback_tab'),
            icon: Icon(Icons.feedback),
            label: 'Feedbacks',
          ),
        ],
      ),
    );
  }
}

class _MainMenuContent extends StatelessWidget {
  const _MainMenuContent({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      key: const Key('menu_grid'),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMenuCard(
          key: const Key('schedule_card'),
          context: context,
          icon: Icons.calendar_month,
          title: 'Schedule',
          onTap: () => Get.toNamed('/schedule'),
        ),
        _buildMenuCard(
          key: const Key('currency_card'),
          context: context,
          icon: Icons.attach_money,
          title: 'Currency Converter',
          onTap: () => Get.toNamed('/currency'),
        ),
        _buildMenuCard(
          key: const Key('timezone_card'),
          context: context,
          icon: Icons.access_time,
          title: 'Time Zone Converter',
          onTap: () => Get.toNamed('/time'),
        ),
        _buildMenuCard(
          key: const Key('map_card'),
          context: context,
          icon: Icons.map,
          title: 'Map',
          onTap: () => Get.toNamed('/map'),
        ),
        _buildMenuCard(
          key: const Key('compass_card'),
          context: context,
          icon: Icons.explore,
          title: 'Compass',
          onTap: () => Get.toNamed('/compass'),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    Key? key,
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      key: key,
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        key: key != null ? Key('${key}_inkwell') : null,
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