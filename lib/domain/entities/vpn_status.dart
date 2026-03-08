/// VPN 状态，由 VpnRepository.statusStream 产出。
class VpnStatus {
  const VpnStatus({required this.isRunning, this.statusText});

  final bool isRunning;
  final String? statusText;

  /// 仅以 statusText 判定传分结束，避免 VPN 主动关闭（Crawler 拉取前释放隧道）被误判为完成。
  bool get isDone => statusText == 'done' || statusText == '传分完成';
}
