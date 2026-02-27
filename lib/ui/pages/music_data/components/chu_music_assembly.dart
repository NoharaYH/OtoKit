import 'package:flutter/material.dart';
import '../../../design_system/constants/strings.dart';

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
            UiStrings.chuMusicDev,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
