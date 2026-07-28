import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

String? getStringImage(File? file) {
  if (file == null) return null;
  return base64Encode(file.readAsBytesSync());
}

const baseURL = 'http://localhost:8000/api';

const loginURL = '$baseURL/login';
const registerURL = '$baseURL/register';
const logoutURL = '$baseURL/logout';
const userURL = '$baseURL/user';

const postsURL = '$baseURL/posts';

const commentsURL = '$baseURL/comments';

String getCleanImageUrl(String? raw) {
  if (raw == null || raw.isEmpty) return '';

  if (raw.contains('profiles/')) {
    final filename = raw.split('profiles/').last;
    return 'http://localhost:8000/storage/profiles/$filename';
  }

  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    return raw;
  }

  return 'http://localhost:8000/storage/$raw';
}

String getCleanPostImageUrl(String? raw) {
  if (raw == null || raw.isEmpty) return '';

  if (raw.contains('posts/')) {
    return 'http://localhost:8000/storage/posts/${raw.split('posts/').last}';
  }

  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    return raw;
  }

  return 'http://localhost:8000/storage/$raw';
}

Widget buildBase64Image(String? imageString, {double width = 100, double height = 100, BoxFit fit = BoxFit.cover}) {
  if (imageString == null || imageString.isEmpty) {
    return const Icon(Icons.person, size: 50);
  }

  try {
    if (imageString.startsWith('http://') || imageString.startsWith('https://')) {
      return Image.network(
        imageString,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    }

    String cleanBase64 = imageString;
    if (cleanBase64.contains(',')) {
      cleanBase64 = cleanBase64.split(',').last;
    }

    return Image.memory(
      base64Decode(cleanBase64),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
    );
  } catch (e) {
    return const Icon(Icons.person, size: 50);
  }
}

const serverError = 'Error del servidor';
const unauthorized = 'No autorizado';
const somethingWentWrong = 'Algo salió mal, intente de nuevo';

InputDecoration kInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    contentPadding: const EdgeInsets.all(10),
    border: const OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: Colors.black),
    ),
  );
}

TextButton kTextButton(String label, Function onPressed) {
  return TextButton(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
      padding: WidgetStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(vertical: 10),
      ),
    ),
    onPressed: () => onPressed(),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white),
    ),
  );
}

Row kLoginRegisterHint(String text, String label, Function onTap) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(text),
      GestureDetector(
        child: Text(
          ' $label',
          style: const TextStyle(color: Colors.blue),
        ),
        onTap: () => onTap(),
      ),
    ],
  );
}
