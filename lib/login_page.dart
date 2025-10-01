// login_page.dart
import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk menangani input username dan password
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State untuk menentukan apakah password disembunyikan atau ditampilkan
  bool _obscurePassword = true;

  // Fungsi login sederhana (hardcoded username/password untuk demo)
  void _login() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    // Contoh validasi sederhana: cek username & password
    if (username == "Rey" && password == "1603") {
      // Navigasi ke HomePage dan mengganti route saat ini
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(username: username)),
      );
    } else {
      // Tampilkan Snackbar jika kredensial salah
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username atau password salah!")),
      );
    }
  }

  @override
  void dispose() {
    // Pastikan controller dibuang saat widget di-destroy untuk mencegah memory leak
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Latar belakang bernuansa oranye lembut
      backgroundColor: Colors.orange.shade50,
      body: Center(
        child: Card(
          // Styling kartu: rounded + elevation
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gambar header (pastikan file assets/images/header.png ada dan terdaftar di pubspec.yaml)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    "assets/images/header.png",
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),

                // Judul halaman login
                Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 20),

                // Field Username
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                    // bisa tambahkan icon jika mau: prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                // Field Password dengan suffix icon untuk show/hide
                TextField(
                  controller: _passwordController,
                  // Gunakan state _obscurePassword untuk menentukan obscureText
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    // Tombol kecil di kanan untuk toggle tampilkan/ sembunyikan password
                    suffixIcon: IconButton(
                      // Icon berubah sesuai state
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        // Toggle state untuk menampilkan atau menyembunyikan password
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Login
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
