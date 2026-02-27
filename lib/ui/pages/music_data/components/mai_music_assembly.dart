import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../design_system/constants/colors.dart';
import '../../../../application/mai/mai_music_provider.dart';
import '../../../design_system/constants/sizes.dart';
import '../../../design_system/kit_music_data/kit_music_sync_prompt.dart';
import '../../../design_system/constants/strings.dart';

class MaiMusicAssembly extends StatelessWidget {
  const MaiMusicAssembly({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MaiMusicProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!provider.hasData) {
          return Stack(
            children: [
              const Center(
                child: Text(
                  UiStrings.currentNoMusicData,
                  style: TextStyle(color: UiColors.grey500, fontSize: 14),
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.symmetric(horizontal: UiSizes.spaceS),
                child: KitMusicSyncPrompt(
                  phase: provider.syncPhase,
                  current: provider.syncCurrent,
                  total: provider.syncTotal,
                  onConfirm: () => provider.sync(),
                  onCancel: () {},
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: UiSizes.cardContentPadding,
            vertical: UiSizes.spaceS,
          ),
          itemCount: provider.musics.length,
          itemBuilder: (context, index) {
            final music = provider.musics[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  music.basicInfo.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(music.basicInfo.artist),
                trailing: Text(
                  music.basicInfo.type,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: UiColors.grey500,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
