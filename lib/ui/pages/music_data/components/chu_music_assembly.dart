import 'package:flutter/material.dart';

class ChuMusicAssembly extends StatelessWidget {
  const ChuMusicAssembly({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chunithm 曲库开发中',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
