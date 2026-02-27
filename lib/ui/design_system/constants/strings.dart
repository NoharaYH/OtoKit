class UiStrings {
  // --- Common Actions ---
  static const String confirm = "确认";
  static const String cancel = "取消";
  static const String back = "返回";
  static const String close = "关闭";
  static const String copy = "复制";
  static const String retry = "重试";

  // --- Score Sync ---
  static const String scoreSyncTitle = "成绩同步";
  static const String startImport = "开始传分";
  static const String stopVpn = "停止代理";
  static const String pauseVpn = "暂停传分";
  static const String resumeVpn = "继续传分";
  static const String verifying = "正在验证...";
  static const String verifySuccess = "验证通过，配置已保存";

  // --- Token Form ---
  static const String divingFishAuth = "水鱼 Token 验证";
  static const String lxnsAuth = "落雪 API 验证";
  static const String inputDivingFishToken = "请输入水鱼 Token";
  static const String inputLxnsToken = "请输入落雪 API 密钥";
  static const String tokenHint = "捕获授权码后，同步将在后台自动完成";

  // --- Logs ---
  static const String logTagSystem = "[SYSTEM]";
  static const String logTagError = "[ERROR]";
  static const String logTagDone = "[DONE]";
  static const String logTagVpn = "[VPN]";
  static const String logTagAuth = "[AUTH]";
  static const String logTagStop = "[STOP]";
  static const String logTagCopy = "[COPY]";

  static const String logCopySuccess = "已将控制台内容复制到剪切板";
  static const String logVpnStarted = "服务已启动，正在监听网络包";
  static const String logClipboardReady = "中转链接已复制，请前往微信打开";

  // --- Navigation & Core ---
  static const String navScoreSync = "成绩数据同步";
  static const String navMusicData = "歌曲数据图鉴";
  static const String navComingSoon = "敬请期待";

  // --- Prompts & Common ---
  static const String waitTransferEnd = "请等待当前传分进程结束";
  static const String verifyAndSave = "验证并保存 Token";
  static const String confirmEndTransfer = "是否结束传分？";
  static const String waitingLogs = "等待日志输入...";
  static const String pasteConfirm = "是否要粘贴以下内容？";
  static const String returnToToken = "返回token填写";

  // --- Platform/Mode Names ---
  static const String modeDivingFish = "水鱼";
  static const String modeBoth = "双平台";
  static const String modeLxns = "落雪";
  static const String diffChoiceMai = "选择导入难度";
  static const String diffChoiceChu = "中二传分设置";
  static const String chuDifDev = "中二难度选择器（待开发）";

  // --- Music Sync ---
  static const String pullMusicData = "正在拉取歌曲数据...";
  static const String pullComplete = "拉取完成";
  static const String musicMerge = "合并中...";
  static const String preparing = "准备中...";
  static const String syncing = "正在同步中";
  static const String noMusicDataPrompt = "曲库内暂无歌曲数据\n是否同步？";
  static const String songCountPrefix = "歌曲数: ";
  static const String currentNoMusicData = '当前暂无歌曲数据';
  static const String chuMusicDev = 'Chunithm 曲库开发中';
  // --- Settings ---
  static const String settingsSaved = '设置已保存';
  static const String accountBindSettings = '账号绑定设置';
  static const String divingFishLabel = '水鱼查分器 (Diving-Fish)';
  static const String divingFishImportHint = '请输入水鱼个人资料中的 Import Token';
  static const String divingFishImportHelper = '用于上传成绩到水鱼查分器';
  static const String lxnsLabel = '落雪查分器 (LXNS)';
  static const String lxnsDevTokenLabel = '开发者 Token';
  static const String lxnsDevTokenHint = '请输入落雪开发者中心的 Token';
  static const String lxnsDevTokenHelper = '用于上传成绩到落雪查分器';
  static const String saveConfig = '保存配置';
}
