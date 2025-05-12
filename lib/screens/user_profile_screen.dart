import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/user_entries_tab.dart';
import '../widgets/liked_entries_tab.dart';
import '../widgets/disliked_entries_tab.dart';
import '../services/user_service.dart';
import 'settings_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel userData;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.userData,
    this.isCurrentUser = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserModel _currentUserData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentUserData = widget.userData;
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);

      // Get updated user data
      if (widget.isCurrentUser) {
        final updatedUser = await userService.getUser(_currentUserData.id!);
        if (updatedUser != null) {
          setState(() {
            _currentUserData = updatedUser;
          });
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load user data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCurrentUser
            ? 'Profile'
            : _currentUserData.displayName ?? 'Anonymous'),
        actions: widget.isCurrentUser
            ? [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()),
                    );
                    // Refresh user data after returning from settings
                    _refreshData();
                  },
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: ProfileHeader(userData: _currentUserData),
                      ),
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(text: 'Entries'),
                              Tab(text: 'Liked'),
                              Tab(text: 'Disliked'),
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      // Entries Tab
                      RefreshIndicator(
                        onRefresh: _refreshData,
                        child: UserEntriesTab(
                          userId: _currentUserData.id!,
                          currentUserData: _currentUserData,
                        ),
                      ),
                      // Liked Entries Tab
                      RefreshIndicator(
                        onRefresh: _refreshData,
                        child: LikedEntriesTab(
                          userId: _currentUserData.id!,
                        ),
                      ),
                      // Disliked Entries Tab
                      RefreshIndicator(
                        onRefresh: _refreshData,
                        child: DislikedEntriesTab(
                          userId: _currentUserData.id!,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
