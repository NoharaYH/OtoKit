/// 单游戏传分所需 URL/路径配置，由 AppEnv.getTransferConfig 提供。
/// application 层用其构建 VpnStartConfig，不直接引用 kernel/config。
class TransferGameConfig {
  const TransferGameConfig({
    required this.lxnsUploadPath,
    required this.dfUploadPath,
    required this.wahlapBase,
    required this.wahlapAuthLabel,
    required this.genreList,
  });

  final String lxnsUploadPath;
  final String dfUploadPath;
  final String wahlapBase;
  final String wahlapAuthLabel;
  final List<String> genreList;
}
