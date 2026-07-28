import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constant.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user;
  bool _loading = true;
  bool _updating = false;
  XFile? _imageFile;
  Uint8List? _imageBytes;
  final _picker = ImagePicker();
  final TextEditingController _txtNameController = TextEditingController();

  void _getUser() async {
    ApiResponse response = await getUserDetail();
    if (!mounted) return;

    if (response.error == null) {
      setState(() {
        user = response.data as User;
        _loading = false;
        _txtNameController.text = user?.name ?? '';
      });
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _getImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    final imageBytes = await pickedFile.readAsBytes();
    if (!mounted) return;

    setState(() {
      _imageFile = pickedFile;
      _imageBytes = imageBytes;
    });
  }

  void _updateProfile() async {
    if (_txtNameController.text.isEmpty) return;

    setState(() {
      _updating = true;
    });

    ApiResponse response = await updateUser(
      _txtNameController.text,
      _imageFile,
    );

    if (!mounted) return;

    setState(() {
      _updating = false;
    });

    if (response.error == null) {
      final updatedUser = response.data as User;
      setState(() {
        user = updatedUser;
        _imageFile = null;
        _imageBytes = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado con éxito')),
      );
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
    }
  }

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userImage = user?.image;

    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _getImage();
                    },
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(65),
                        color: Colors.amber,
                      ),
                      child: ClipOval(
                        child: _imageBytes != null
                            ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                            : buildBase64Image(userImage, width: 130, height: 130),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _txtNameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: _updating
                        ? null
                        : () {
                            _updateProfile();
                          },
                    child: _updating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Update',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          );
  }
}
