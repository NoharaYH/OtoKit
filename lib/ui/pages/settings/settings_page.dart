import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/shared/navigation_provider.dart';
import '../../design_system/kit_shared/confirm_button.dart';
import '../../../kernel/services/storage_service.dart';
import '../../../kernel/di/injection.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _dfTokenController = TextEditingController();
  final _lxnsTokenController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dfToken = await getIt<StorageService>().read(
      StorageService.kDivingFishToken,
    );
    final lxnsToken = await getIt<StorageService>().read(
      StorageService.kLxnsToken,
    );

    if (mounted) {
      setState(() {
        _dfTokenController.text = dfToken ?? '';
        _lxnsTokenController.text = lxnsToken ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    // 增加感知延迟
    await Future.delayed(const Duration(milliseconds: 600));

    await getIt<StorageService>().save(
      StorageService.kDivingFishToken,
      _dfTokenController.text,
    );
    await getIt<StorageService>().save(
      StorageService.kLxnsToken,
      _lxnsTokenController.text,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('设置已保存', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueAccent,
        ),
      );
      context.read<NavigationProvider>().closeSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 毛玻璃背景背板
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),
          // 真正的界面层
          SafeArea(
            child: Stack(
              children: [
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.only(
                          top: 80,
                          left: 24,
                          right: 24,
                          bottom: 24,
                        ),
                        children: [
                          const Text(
                            '账号绑定设置',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeader('水鱼查分器 (Diving-Fish)'),
                          TextField(
                            controller: _dfTokenController,
                            decoration: const InputDecoration(
                              labelText: 'Import Token',
                              hintText: '请输入水鱼个人资料中的 Import Token',
                              border: OutlineInputBorder(),
                              helperText: '用于上传成绩到水鱼查分器',
                            ),
                          ),
                          const SizedBox(height: 24),

                          _buildSectionHeader('落雪查分器 (LXNS)'),
                          TextField(
                            controller: _lxnsTokenController,
                            decoration: const InputDecoration(
                              labelText: '开发者 Token',
                              hintText: '请输入落雪开发者中心的 Token',
                              border: OutlineInputBorder(),
                              helperText: '用于上传成绩到落雪查分器',
                            ),
                          ),

                          const SizedBox(height: 40),
                          ConfirmButton(
                            text: '保存配置',
                            icon: Icons.save,
                            state: _isSaving
                                ? ConfirmButtonState.loading
                                : ConfirmButtonState.ready,
                            onPressed: _saveSettings,
                          ),
                        ],
                      ),
                // 左上角返回键
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 28,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      context.read<NavigationProvider>().closeSettings();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
