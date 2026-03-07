/// 领域服务：将 HTML 解析为分数记录列表。
/// 实现在 infrastructure/parsers，domain/application 仅依赖此接口。
abstract class HtmlRecordParser {
  List<Map<String, dynamic>> parse(String html);
}
