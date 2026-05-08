import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_provider.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final appProv = Provider.of<AppProvider>(context, listen: false);
    appProv.clearUserData();

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Chưa đăng nhập"));
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        final fullName = data?['fullName'] ?? 'Chưa có tên';
        final email = data?['email'] ?? user.email ?? '';
        final age = data?['age']?.toString() ?? 'Chưa có';
        final gender = data?['gender'] ?? 'Chưa có';

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      child: Icon(Icons.person, size: 50),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text("Email: $email"),
                    Text("Tuổi: $age"),
                    Text("Giới tính: $gender"),
                    const SizedBox(height: 16),
                    const Text(
                      "Ứng dụng nghe nhạc online sử dụng Flutter, Firebase và just_audio.",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        logout(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Đăng xuất"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
