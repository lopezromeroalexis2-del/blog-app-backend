import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constant.dart';
import '../models/api_response.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import 'login.dart';

class PostForm extends StatefulWidget {
  final Post? post;
  final String? title;

  const PostForm({super.key, this.post, this.title});

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _txtControllerBody = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;
  Uint8List? _imageBytes;
  XFile? _pickedFile;

  void _getImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;

    setState(() {
      _pickedFile = image;
      _imageBytes = bytes;
    });
  }

  void _createPost() async {
    ApiResponse response = await createPost(
      _txtControllerBody.text,
      image: _imageBytes != null ? 'data:image/png;base64,${base64Encode(_imageBytes!)}' : null,
    );

    if (response.error == null) {
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  void _editPost(int postId) async {
    ApiResponse response = await editPost(postId, _txtControllerBody.text);

    if (response.error == null) {
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else if (response.error == unauthorized) {
      logout().then((value) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    if (widget.post != null) {
      _txtControllerBody.text = widget.post!.body ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _getImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: _imageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 40, color: Colors.black38),
                                SizedBox(height: 8),
                                Text('Agregar imagen',
                                    style: TextStyle(color: Colors.black38, fontSize: 12)),
                              ],
                            ),
                    ),
                  ),
                ),
                if (_imageBytes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _pickedFile = null;
                            _imageBytes = null;
                          });
                        },
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Quitar imagen'),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _txtControllerBody,
                    keyboardType: TextInputType.multiline,
                    maxLines: 9,
                    validator: (val) =>
                        val!.isEmpty ? 'El contenido es requerido' : null,
                    decoration: const InputDecoration(
                      hintText: '¿En qué estás pensando?',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.black38),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                kTextButton('Publicar', () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _loading = true;
                    });
                    if (widget.post == null) {
                      _createPost();
                    } else {
                      _editPost(widget.post!.id ?? 0);
                    }
                  }
                })
              ],
            ),
    );
  }
}
