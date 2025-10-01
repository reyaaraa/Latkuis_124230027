import 'package:flutter/material.dart';
import 'login_page.dart';
import 'vehicle-data.dart';
import 'detail_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Simpan daftar favorit (berdasarkan index vehicleList)
  final Set<int> _favoriteIndexes = {};

  // Controller untuk search bar
  final TextEditingController _searchController = TextEditingController();

  // Keyword pencarian
  String _searchKeyword = "";

  // Fungsi logout dengan konfirmasi
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // batal
            child: const Text("Tidak"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text("Iya"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Urutkan list: favorit muncul duluan
    final sortedVehicles = List.generate(vehicleList.length, (i) => i);
    sortedVehicles.sort((a, b) {
      final aFav = _favoriteIndexes.contains(a) ? 1 : 0;
      final bFav = _favoriteIndexes.contains(b) ? 1 : 0;
      return bFav.compareTo(aFav); // yang favorit naik ke atas
    });

    // Filter berdasarkan pencarian
    final filteredVehicles = sortedVehicles.where((index) {
      final vehicle = vehicleList[index];
      final keyword = _searchKeyword.toLowerCase();
      return vehicle.name.toLowerCase().contains(keyword) ||
          vehicle.type.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text("Selamat datang, ${widget.username}"),
        backgroundColor: Colors.orange,
        actions: [
          // Tombol menuju halaman profil
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "Profile",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          // Tombol logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),

      // List kendaraan dengan search bar
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari kendaraan...",
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value;
                });
              },
            ),
          ),

          // List hasil pencarian
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredVehicles.length,
              itemBuilder: (context, index) {
                final vehicleIndex = filteredVehicles[index];
                final vehicle = vehicleList[vehicleIndex];
                final isFavorite = _favoriteIndexes.contains(vehicleIndex);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    // Foto kendaraan (dari URL)
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.orange.shade100,
                      backgroundImage: NetworkImage(vehicle.imageUrls[0]),
                    ),
                    // Nama kendaraan
                    title: Text(
                      vehicle.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // Jenis kendaraan
                    subtitle: Text(
                      vehicle.type,
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                    // Icon favorit
                    trailing: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.orange,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isFavorite) {
                            _favoriteIndexes.remove(vehicleIndex);
                          } else {
                            _favoriteIndexes.add(vehicleIndex);
                          }
                        });
                      },
                    ),
                    // Klik → masuk ke DetailPage
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(vehicle: vehicle),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
