import 'package:flutter/material.dart';

class ProfileNetworkImage extends StatelessWidget {
  const ProfileNetworkImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.person, size: 60, color: Colors.white);
      },
    );
  }
}
