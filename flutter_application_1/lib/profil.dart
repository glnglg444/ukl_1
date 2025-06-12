import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController namaController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController teleponController = TextEditingController();
  String gender = 'Laki-laki';

  final String profilUrl = 'https://learn.smktelkom-mlg.sch.id/ukl1/api/profil';
  final String updateUrl = 'https://learn.smktelkom-mlg.sch.id/ukl1/api/update';

  Future<void> fetchProfil() async {
    final response = await http.get(Uri.parse(profilUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        namaController.text = data['nama_pelanggan'];
        alamatController.text = data['alamat'];
        teleponController.text = data['telepon'];
        gender = data['gender'];
      });
    }
  }

  Future<void> updateProfil() async {
    final response = await http.post(
      Uri.parse(updateUrl),
      body: {
        'nama_pelanggan': namaController.text,
        'alamat': alamatController.text,
        'gender': gender,
        'telepon': teleponController.text,
      },
    );

    final result = json.decode(response.body);
    final msg = result['message'] ?? 'Update Gagal';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchProfil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 4,
                offset: Offset(2, 2),
              )
            ],
          ),
          width: 350,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blueGrey[400],
                  child: Icon(Icons.person, size: 60, color: Colors.grey[200]),
                ),
                SizedBox(height: 20),
                Divider(color: Colors.black45),
                SizedBox(height: 20),
                buildTextField(namaController, 'Nama Pelanggan'),
                SizedBox(height: 12),
                buildTextField(alamatController, 'Alamat'),
                SizedBox(height: 12),
                // Gender input pakai Dropdown, tapi pakai TextField untuk styling seragam sesuai wireframe
                Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.grey[500],
                  child: DropdownButton<String>(
                    value: gender,
                    dropdownColor: Colors.grey[500],
                    underline: SizedBox(),
                    isExpanded: true,
                    style: TextStyle(color: Colors.black),
                    items: ['Laki-laki', 'Perempuan']
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        gender = value!;
                      });
                    },
                  ),
                ),
                SizedBox(height: 12),
                buildTextField(teleponController, 'Telepon', keyboardType: TextInputType.phone),
                SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      elevation: 0,
                    ),
                    onPressed: updateProfil,
                    child: Text('Update Profil', style: TextStyle(color: Colors.black)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Container(
      height: 40,
      color: Colors.grey[500],
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54),
          border: InputBorder.none,
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}