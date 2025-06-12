import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: RegisterPage()),
  );
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController();
  String gender = "Laki-laki";
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Uint8List? _imageBytes;
  XFile? _pickedFile;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _pickedFile = pickedFile;
        });
      } else {
        setState(() {
          _pickedFile = pickedFile;
          _imageBytes = null;
        });
      }
    }
  }

  Future<void> _register() async {
    var uri = Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl1/api/register');
    var request = http.MultipartRequest('POST', uri);

    request.fields['nama_nasabah'] = namaController.text;
    request.fields['gender'] = gender;
    request.fields['alamat'] = alamatController.text;
    request.fields['telepon'] = teleponController.text;
    request.fields['username'] = usernameController.text;
    request.fields['password'] = passwordController.text;

    if (_pickedFile != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto',
            await _pickedFile!.readAsBytes(),
            filename: _pickedFile!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('foto', _pickedFile!.path),
        );
      }
    }

    var response = await request.send();
    var respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var data = jsonDecode(respStr);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Berhasil Register')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal Register: $respStr')));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imagePreview;
    if (_imageBytes != null) {
      imagePreview = Image.memory(_imageBytes!, height: 100);
    } else if (_pickedFile != null && !kIsWeb) {
      imagePreview = Image.file(File(_pickedFile!.path), height: 100);
    } else {
      imagePreview = const Text('Belum pilih foto');
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(vertical: 36, horizontal: 0),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "REGISTER NASABAH BANK WANDIRI",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: namaController,
                    decoration: InputDecoration(
                      labelText: 'Nama Nasabah',
                       prefixIcon: const Icon(Icons.person), // 👤 icon
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      
                    ),
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: gender,
                    items: const [
                      DropdownMenuItem(
                        value: 'Laki-laki',
                        child: Text('Laki-laki'),
                      ),
                      DropdownMenuItem(
                        value: 'Perempuan',
                        child: Text('Perempuan'),
                      ),
                    ],
                    onChanged: (value) => setState(() => gender = value!),
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: const Icon(Icons.wc), // 🚻
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: alamatController,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      prefixIcon: const Icon(Icons.location_on), // 📍
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      
                    ),
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: teleponController,
                    decoration: InputDecoration(
                      labelText: 'Telepon',
                       prefixIcon: const Icon(Icons.phone), // 📞
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  // --- FOTO DI SINI ---
                  const SizedBox(height: 10),
                  imagePreview,
                  const SizedBox(height: 9),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Pilih Foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 0, 0, 0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person), // 👤 icon
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      
                    ),
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock), // 🔒 icon
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      
                    ),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _register();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 0, 0, 0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('REGISTER'),
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