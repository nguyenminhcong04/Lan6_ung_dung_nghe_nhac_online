import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProv = Provider.of<AppProvider>(context);

    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
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
              const Text(
                "Nguyễn Minh Công",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text("MSSV: 2224802010932"),
              const Text("Lớp: D22CNTT04"),
              const SizedBox(height: 12),
              Text(
                "Số bài hát yêu thích: ${appProv.favoriteSongs.length}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Ứng dụng nghe nhạc online sử dụng Flutter, Provider và just_audio.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
