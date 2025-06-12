import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// === Model ===
class Matkul {
  final int id;
  final String namaMatkul;
  final int sks;

  Matkul({required this.id, required this.namaMatkul, required this.sks});

  factory Matkul.fromJson(Map<String, dynamic> json) {
    return Matkul(
      id: json['id'],
      namaMatkul: json['nama_matkul'],
      sks: json['sks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_matkul': namaMatkul,
      'sks': sks,
    };
  }

  @override
  String toString() => 'Matkul(id: $id, namaMatkul: $namaMatkul, sks: $sks)';
}

// === Service ===
class MatkulService {
  final String baseUrl = 'https://learn.smktelkom-mlg.sch.id/ukl1/api'; // Ganti sesuai kebutuhan

  Future<List<Matkul>> getMatkul() async {
    final response = await http.get(
      Uri.parse('$baseUrl/getmatkul'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> list = data['data'];
      return list.map((item) => Matkul.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data mata kuliah');
    }
  }
}

// === View Page ===
class MatkulViewPage extends StatefulWidget {
  const MatkulViewPage({super.key});

  @override
  State<MatkulViewPage> createState() => _MatkulViewPageState();
}

class _MatkulViewPageState extends State<MatkulViewPage> {
  final MatkulService _matkulService = MatkulService();
  List<Matkul> matkulList = [];
  List<bool> selected = [];
  bool isLoading = true;
  String? error;

  Future<void> fetchMatkul() async {
    try {
      final result = await _matkulService.getMatkul();
      setState(() {
        matkulList = result;
        selected = List.generate(result.length, (_) => false);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMatkul();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF6FF),
      appBar: AppBar(
        title: const Text('Daftar Mata Kuliah'),
        backgroundColor: Colors.blue,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : matkulList.isEmpty
                  ? const Center(child: Text("Tidak ada mata kuliah."))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              itemCount: matkulList.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final matkul = matkulList[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      child: Text(
                                        matkul.id.toString(),
                                        style: const TextStyle(
                                            color: Colors.blue),
                                      ),
                                    ),
                                    title: Text(matkul.namaMatkul),
                                    subtitle: Text('${matkul.sks} sks'),
                                    trailing: Checkbox(
                                      value: selected[index],
                                      activeColor: Colors.blue,
                                      onChanged: (val) {
                                        setState(() {
                                          selected[index] = val!;
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selected[index] = !selected[index];
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                List<Matkul> selectedMatkul = [];

                                for (int i = 0; i < selected.length; i++) {
                                  if (selected[i]) {
                                    selectedMatkul.add(matkulList[i]);
                                  }
                                }

                                final responseMap = {
                                  "status": true,
                                  "message": "Matkul selected successfully",
                                  "data": {
                                    "list_matkul": selectedMatkul
                                        .map((m) => m.toJson())
                                        .toList(),
                                  }
                                };

                                print(const JsonEncoder.withIndent('  ')
                                    .convert(responseMap));

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Mata kuliah disimpan")),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Simpan yang Terpilih",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}



class matkul extends StatelessWidget {
  const matkul ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Mata Kuliah',
      debugShowCheckedModeBanner: false,
      home: const MatkulViewPage(),
    );
  }
}
