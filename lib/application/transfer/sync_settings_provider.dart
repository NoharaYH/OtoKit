import 'package:flutter/material.dart';
import 'transfer_provider.dart';

/// 设置页：传分服务局部逻辑托管 (v1.0)
/// 遵循 "Short-term Memory Lockdown" 规程，严禁将未确认的 UI 状态直接上报全局。
class SyncSettingsProvider extends ChangeNotifier {
  // 局部状态：Token 临时缓存
  String _tempDfToken = "";

  String get tempDfToken => _tempDfToken;

  void updateTempDfToken(String val) {
    if (_tempDfToken == val) return;
    _tempDfToken = val;
    notifyListeners();
  }

  /// 提交并同步至全局 TransferProvider
  /// 此处应包含验证逻辑
  Future<void> saveToGlobal(TransferProvider transfer) async {
    // 阶段 E: 提交验证，并解除隔离
    if (_tempDfToken.isNotEmpty) {
      transfer.updateTokens(df: _tempDfToken);
    }
  }
}
