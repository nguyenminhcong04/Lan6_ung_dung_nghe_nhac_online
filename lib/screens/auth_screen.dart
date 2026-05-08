import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_provider.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final ageController = TextEditingController();

  String gender = "Nam";

  @override
  void initState() {
    super.initState();
    checkLoggedInUser();
  }

  Future<void> checkLoggedInUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final appProv = Provider.of<AppProvider>(context, listen: false);
    await appProv.loadUserData(user.uid);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage("Vui lòng nhập email và mật khẩu");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = result.user!.uid;

      final appProv = Provider.of<AppProvider>(context, listen: false);
      await appProv.loadUserData(uid);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      showMessage(getFirebaseErrorMessage(e.code));
    } catch (e) {
      showMessage("Đăng nhập thất bại: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> register() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final ageText = ageController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        ageText.isEmpty) {
      showMessage("Vui lòng nhập đầy đủ thông tin");
      return;
    }

    final age = int.tryParse(ageText);

    if (age == null || age <= 0) {
      showMessage("Tuổi không hợp lệ");
      return;
    }

    if (password.length < 6) {
      showMessage("Mật khẩu phải từ 6 ký tự trở lên");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = result.user!.uid;

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "uid": uid,
        "fullName": fullName,
        "email": email,
        "age": age,
        "gender": gender,
        "favoriteUrls": [],
        "playlistUrls": [],
        "createdAt": FieldValue.serverTimestamp(),
      });

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      showMessage("Đăng ký thành công. Vui lòng đăng nhập lại.");

      setState(() {
        isLogin = true;
        passwordController.clear();
      });
    } on FirebaseAuthException catch (e) {
      showMessage(getFirebaseErrorMessage(e.code));
    } catch (e) {
      showMessage("Đăng ký thất bại: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String getFirebaseErrorMessage(String code) {
    switch (code) {
      case "email-already-in-use":
        return "Email này đã được đăng ký";
      case "invalid-email":
        return "Email không hợp lệ";
      case "user-not-found":
        return "Không tìm thấy tài khoản";
      case "wrong-password":
        return "Sai mật khẩu";
      case "weak-password":
        return "Mật khẩu quá yếu";
      case "invalid-credential":
        return "Email hoặc mật khẩu không đúng";
      default:
        return "Có lỗi xảy ra: $code";
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.music_note,
                    size: 72,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isLogin ? "Đăng nhập" : "Đăng ký tài khoản",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 22),

                  if (!isLogin)
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: "Họ và tên",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),

                  if (!isLogin) const SizedBox(height: 12),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Mật khẩu",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  if (!isLogin) const SizedBox(height: 12),

                  if (!isLogin)
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Tuổi",
                        prefixIcon: Icon(Icons.cake),
                        border: OutlineInputBorder(),
                      ),
                    ),

                  if (!isLogin) const SizedBox(height: 12),

                  if (!isLogin)
                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: const InputDecoration(
                        labelText: "Giới tính",
                        prefixIcon: Icon(Icons.wc),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Nam", child: Text("Nam")),
                        DropdownMenuItem(value: "Nữ", child: Text("Nữ")),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            gender = value;
                          });
                        }
                      },
                    ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (isLogin) {
                                login();
                              } else {
                                register();
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : Text(
                              isLogin ? "Đăng nhập" : "Đăng ký",
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                    child: Text(
                      isLogin
                          ? "Chưa có tài khoản? Đăng ký"
                          : "Đã có tài khoản? Đăng nhập",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
