import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iuto_mobile/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:iuto_mobile/providers/favoris_provider.dart';
import 'package:iuto_mobile/providers/image_provider.dart';
import 'package:iuto_mobile/providers/user_provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<void> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _initializeAllData();
  }

  Future<void> _initializeAllData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchUser();
    final userId = userProvider.user['id'];
    await Provider.of<FavorisProvider>(context, listen: false)
        .loadFavorisbyUser(userId);
    await Provider.of<ImagesProvider>(context, listen: false)
        .fetchUserImages(userId);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: FutureBuilder(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ErrorView(
              error: snapshot.error?.toString(),
              onRetry: () => setState(() {
                _userDataFuture = _initializeAllData();
              }),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ProfileHeader(user: userProvider.user),
                    const SizedBox(height: 24),
                    UserInfoSection(user: userProvider.user),
                    const SizedBox(height: 32),
                    ActionButtonsSection(),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/selection'),
        icon: const Icon(Icons.explore_outlined),
        label: const Text('Explorer'),
      ),
    );
  }
}

class ActionButtonsSection extends StatelessWidget {
  const ActionButtonsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ActionButton(
            icon: Icons.comment_outlined,
            label: 'Mes Commentaires',
            onPressed: () => context.push('/user/comments'),
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ActionButton(
            icon: Icons.photo_library_outlined,
            label: 'Mes Photos',
            onPressed: () => context.push('/user/photosResto'),
          ),
        ),
      ],
    );
  }
}
