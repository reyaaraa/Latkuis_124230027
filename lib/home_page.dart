import 'package:flutter/material.dart';
import 'login_page.dart';
import 'vehicle-data.dart';
import 'detail_page.dart';
import 'profile_page.dart';

/// Halaman utama aplikasi dengan BottomNavigationBar.
/// - Tab 0 = Home (menampilkan daftar kendaraan dalam bentuk ListView)
/// - Tab 1 = Profile (menampilkan halaman profil user)
class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ---------------------------
  // STATE / DATA YANG DIGUNAKAN
  // ---------------------------

  /// Menyimpan index kendaraan yang masuk ke "sampah".
  /// Kendaraan yang ada di _trashBin tidak akan tampil di Home.
  final List<int> _trashBin = [];

  /// Menyimpan index kendaraan yang disukai.
  /// Digunakan untuk toggle icon ❤️.
  final List<int> _favorite = [];

  /// Controller untuk search bar (input pencarian).
  final TextEditingController _searchController = TextEditingController();

  /// Kata kunci pencarian (diketik user).
  String _searchKeyword = "";

  /// Index halaman aktif pada BottomNavigationBar.
  /// - 0 = Home (List kendaraan)
  /// - 1 = Profile
  int _selectedIndex = 0;

  // ---------------------------
  // FUNGSI PENDUKUNG
  // ---------------------------

  /// Logout dengan konfirmasi.
  /// Jika user menekan "Iya", maka diarahkan kembali ke LoginPage.
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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

  /// Membuka halaman Sampah.
  /// TrashPage akan menerima data kendaraan yang sudah dihapus.
  void _openTrashPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrashPage(
          trashBin: _trashBin,
          vehicleList: vehicleList,
          onRestore: (index) {
            // Jika user klik Restore, keluarkan dari _trashBin
            setState(() {
              _trashBin.remove(index);
            });
          },
        ),
      ),
    );
  }

  /// Toggle favorite (like).
  /// Jika kendaraan sudah ada di _favorite → hapus.
  /// Jika belum → tambahkan.
  void _toggleFavorite(int vehicleIndex) {
    setState(() {
      if (_favorite.contains(vehicleIndex)) {
        _favorite.remove(vehicleIndex);
      } else {
        _favorite.add(vehicleIndex);
      }
    });
  }

  /// Pindahkan kendaraan ke sampah (trash).
  void _moveToTrash(int vehicleIndex) {
    setState(() {
      if (!_trashBin.contains(vehicleIndex)) {
        _trashBin.add(vehicleIndex);
      }
    });
  }

  // ---------------------------
  // HALAMAN HOME (LIST KENDARAAN)
  // ---------------------------
  Widget _buildHomeList() {
    // Filter kendaraan: hanya tampilkan yang
    // - Tidak ada di trash
    // - Nama/tipe sesuai keyword pencarian
    final filtered = List.generate(vehicleList.length, (i) => i).where((index) {
      if (_trashBin.contains(index)) return false;
      final v = vehicleList[index];
      final keyword = _searchKeyword.toLowerCase();
      return v.name.toLowerCase().contains(keyword) ||
          v.type.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Selamat datang, ${widget.username}"),
        backgroundColor: Colors.orange,
        actions: [
          // Tombol menuju ke halaman Sampah
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: "Sampah",
            onPressed: _openTrashPage,
          ),
          // Tombol logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _logout(context),
          ),
        ],
      ),

      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari kendaraan...",
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                suffixIcon: _searchKeyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchKeyword = "";
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchKeyword = value),
            ),
          ),

          // List kendaraan (kebawah)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final vehicleIndex = filtered[idx];
                final vehicle = vehicleList[vehicleIndex];
                final liked = _favorite.contains(vehicleIndex);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(vehicle.imageUrls[0]),
                      backgroundColor: Colors.orange.shade100,
                    ),
                    title: Text(
                      vehicle.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(vehicle.type),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Like
                        IconButton(
                          icon: Icon(
                            liked ? Icons.favorite : Icons.favorite_border,
                            color: liked ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => _toggleFavorite(vehicleIndex),
                        ),
                        // Tombol Hapus
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _moveToTrash(vehicleIndex),
                        ),
                      ],
                    ),
                    // Klik → buka detail kendaraan
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => DetailPage(vehicle: vehicle),
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

  // ---------------------------
  // ROOT DENGAN BOTTOM NAVIGATION
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    // Daftar halaman/tab
    final pages = <Widget>[
      _buildHomeList(), // Halaman Home (List kendaraan)
      const ProfilePage(), // Halaman Profile
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// Halaman Sampah (Trash)
/// - Menampilkan kendaraan yang dihapus
/// - Ada tombol Restore untuk mengembalikan kendaraan ke Home
class TrashPage extends StatelessWidget {
  final List<int> trashBin;
  final List vehicleList;
  final Function(int) onRestore;

  const TrashPage({
    super.key,
    required this.trashBin,
    required this.vehicleList,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sampah"),
        backgroundColor: Colors.orange,
      ),
      body: trashBin.isEmpty
          ? const Center(child: Text("Sampah kosong"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: trashBin.length,
              itemBuilder: (context, i) {
                final vehicleIndex = trashBin[i];
                final vehicle = vehicleList[vehicleIndex];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(vehicle.imageUrls[0]),
                    ),
                    title: Text(vehicle.name),
                    subtitle: Text(vehicle.type),
                    trailing: TextButton(
                      child: const Text("Restore"),
                      onPressed: () {
                        onRestore(vehicleIndex);
                        Navigator.pop(context); // kembali ke Home
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
