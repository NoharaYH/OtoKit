import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design_system/constants/colors.dart';
import '../../design_system/constants/animations.dart';
import '../../design_system/kit_shared/kit_bounce_scaler.dart';
import '../../../application/shared/navigation_provider.dart';

/// 设置模块门面容器：Overriding Layer (v4.0)
/// 已重构：移除旧的分页逻辑，采用简洁的垂直卡片式列表。
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: UiAnimations.standard,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          final topPadding = MediaQuery.of(context).padding.top;
          return Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // 1. 全局背景拦截与点击返回
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => _handleBack(),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 12.0 * _fadeAnimation.value,
                        sigmaY: 12.0 * _fadeAnimation.value,
                      ),
                      child: Container(
                        color: UiColors.white.withValues(
                          alpha: 0.25 * _fadeAnimation.value,
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. 核心内容区
                Column(
                  children: [
                    // 顶部填充式列表头：彻底铺满顶端并适配安全区
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: topPadding),
                          GestureDetector(
                            onTap: () => _handleBack(),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              height: 54, // 标准高度对齐
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  KitBounceScaler(
                                    onTap: () => _handleBack(),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new,
                                      size: 20,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "返回首页",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 列表内容区域
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Column(
                          children: [
                            _buildCategoryItem(
                              icon: Icons.sync,
                              title: "成绩同步设置",
                              iconColor: Colors.green,
                              onTap: () {
                                // 待后续连接页面
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildCategoryItem(
                              icon: Icons.settings,
                              title: "应用设置",
                              iconColor: Colors.blue,
                              onTap: () {
                                // 待后续连接页面
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildCategoryItem(
                              icon: Icons.palette,
                              title: "个性化设置",
                              iconColor: Colors.purpleAccent,
                              onTap: () {
                                // 待后续连接页面
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildCategoryItem(
                              icon: Icons.info_outline,
                              title: "应用信息",
                              iconColor: Colors.grey,
                              onTap: () {
                                // 待后续连接页面
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return KitBounceScaler(
      onTap: onTap,
      child: Container(
        height: 54, // 与标准确认按钮高度一致
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack() {
    _fadeController.reverse().then((_) {
      context.read<NavigationProvider>().closeSettings();
    });
  }
}
