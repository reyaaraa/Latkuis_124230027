import 'package:flutter/material.dart';
import 'login_page.dart';
import 'vehicle-data.dart';
import 'detail_page.dart';
import 'profile_page.dart';

/// HomePage utama (root) yang memuat bottom navigation.
/// - Tab 0 = Home (grid kendaraan)
/// - Tab 1 = Profile (menampilkan ProfilePage)
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

  // Menyimpan index kendaraan yang dipindahkan ke "sampah" (trash)
  final List<int> _trashBin = [];

  // Menyimpan index kendaraan yang disukai (favorite).
  // NOTE: "suka" TIDAK merubah urutan list — hanya toggle state.
  final List<int> _favorite = [];

  // Controller untuk search bar
  final TextEditingController _searchController = TextEditingController();

  // Kata kunci pencarian (lowercase)
  String _searchKeyword = "";

  // Index halaman aktif pada bottom navigation (0 = home, 1 = profile)
  int _selectedIndex = 0;

  // ---------------------------
  // FUNGSI PENDUKUNG
  // ---------------------------

  // Logout dengan konfirmasi (tetap menggunakan LoginPage yang ada)
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
              // Ganti route ke halaman login
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

  // Buka halaman Sampah (Trash). Kita push halaman baru yang menampilkan
  // daftar kendaraan yang ada di _trashBin dan menyediakan tombol Restore.
  void _openTrashPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrashPage(
          trashBin: _trashBin,
          vehicleList: vehicleList,
          // onRestore dipanggil ketika user menekan Restore pada TrashPage
          onRestore: (index) {
            setState(() {
              _trashBin.remove(
                index,
              ); // keluarkan dari trash → kembali tampil di grid
            });
          },
        ),
      ),
    );
  }

  // Toggle like/suka. Hanya menambah/menghapus dari list _favorite.
  void _toggleFavorite(int vehicleIndex) {
    setState(() {
      if (_favorite.contains(vehicleIndex)) {
        _favorite.remove(vehicleIndex);
      } else {
        _favorite.add(vehicleIndex);
      }
    });
  }

  // Hapus item ke sampah (tambahkan index ke _trashBin)
  void _moveToTrash(int vehicleIndex) {
    setState(() {
      if (!_trashBin.contains(vehicleIndex)) {
        _trashBin.add(vehicleIndex);
      }
    });
  }

  // ---------------------------
  // WIDGET BANTU: halaman HOME (grid)
  // ---------------------------
  Widget _buildHomeGrid() {
    // Buat daftar index kendaraan yang tidak di-sampah dan cocok filter
    final filtered = List.generate(vehicleList.length, (i) => i).where((index) {
      if (_trashBin.contains(index))
        return false; // jangan tampilkan yg ada di sampah
      final v = vehicleList[index];
      final keyword = _searchKeyword.toLowerCase();
      return v.name.toLowerCase().contains(keyword) ||
          v.type.toLowerCase().contains(keyword);
    }).toList();

    return Scaffold(
      // AppBar khusus untuk halaman Home (inner Scaffold). Kita letakkan appbar
      // di dalam halaman Home sehingga ketika berpindah tab, setiap halaman
      // dapat punya appBar-nya sendiri.
      appBar: AppBar(
        title: Text("Selamat datang, ${widget.username}"),
        backgroundColor: Colors.orange,
        actions: [
          // Akses halaman Sampah dari appbar Home
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: "Sampah",
            onPressed: _openTrashPage,
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _logout(context),
          ),
        ],
      ),

      // Body: search bar + grid
      body: Column(
        children: [
          // SEARCH BAR
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
                          // Clear search text
                          _searchController.clear();
                          setState(() {
                            _searchKeyword = "";
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchKeyword = value),
            ),
          ),

          // GRID: 2 kolom card kendaraan
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 kolom
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final vehicleIndex = filtered[idx];
                final vehicle = vehicleList[vehicleIndex];
                final liked = _favorite.contains(vehicleIndex);

                return GestureDetector(
                  onTap: () {
                    // Buka halaman detail ketika card diketuk
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => DetailPage(vehicle: vehicle),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // FOTO (atas)
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              // gunakan imageUrls[0] sebagai gambar utama
                              vehicle.imageUrls.isNotEmpty
                                  ? vehicle.imageUrls[0]
                                  : '',
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Nama, tipe dan aksi (bawah)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama (bold)
                              Text(
                                vehicle.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Tipe (warna oranye)
                              Text(
                                vehicle.type,
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // ROW aksi: Suka (toggle only) & Sampah (pindah ke trash)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Tombol Suka (♥) — hanya toggle state, TIDAK mengubah urutan
                                  IconButton(
                                    icon: Icon(
                                      liked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                    ),
                                    color: liked ? Colors.red : Colors.grey,
                                    onPressed: () =>
                                        _toggleFavorite(vehicleIndex),
                                    tooltip: liked ? "Batal suka" : "Suka",
                                  ),

                                  // Tombol Sampah (🗑️) — pindahkan ke _trashBin
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red.shade700,
                                    onPressed: () => _moveToTrash(vehicleIndex),
                                    tooltip: "Hapus (pindah ke sampah)",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
  // BUILD ROOT: IndexedStack + BottomNavigationBar
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    // Kita gunakan IndexedStack supaya state tiap tab tetap terjaga saat berpindah
    final pages = <Widget>[
      _buildHomeGrid(), // halaman Home (mengandung Scaffold sendiri)
      // ProfilePage sudah berbentuk widget (Scaffold) — kita pakai langsung
      const ProfilePage(),
    ];

    return Scaffold(
      // Body menggunakan IndexedStack agar kedua halaman tetap hidup dan state terjaga
      body: IndexedStack(index: _selectedIndex, children: pages),

      // Bottom navigation di bawah: Home & Profile
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

  // Jangan lupa dispose controller
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// Halaman Sampah (Trash)
/// - Menerima list index kendaraan yang dihapus (trashBin)
/// - Menampilkan tiap item dengan tombol "Restore" untuk mengembalikan
class TrashPage extends StatelessWidget {
  final List<int> trashBin; // index kendaraan yg ada di sampah
  final List vehicleList; // daftar kendaraan utama
  final Function(int) onRestore; // callback restore

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
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(vehicle.imageUrls[0]),
                    ),
                    title: Text(vehicle.name),
                    subtitle: Text(vehicle.type),
                    trailing: TextButton(
                      child: const Text("Restore"),
                      onPressed: () {
                        // Panggil callback untuk restore (menghapus index dari trashBin)
                        onRestore(vehicleIndex);
                        // Kembali ke halaman Home
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
