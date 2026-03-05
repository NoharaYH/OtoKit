import 'dart:convert';
import 'dart:io';

void main() async {
  print('--- 测试 1：带上 version 和 notes 查询参数 ---');
  final uri1 = Uri.parse(
    'https://maimai.lxns.net/api/v0/maimai/song/list?version=25000&notes=false',
  );
  final request1 = await HttpClient().getUrl(uri1);
  final response1 = await request1.close();
  final content1 = await response1.transform(utf8.decoder).join();
  print('请求 URL: $uri1');
  print('HTTP 状态码: ${response1.statusCode}');

  print('--- 测试 2：把 version 和 notes 作为 Headers 塞入 ---');
  final uri2 = Uri.parse('https://maimai.lxns.net/api/v0/maimai/song/list');
  final request2 = await HttpClient().getUrl(uri2);
  request2.headers.add('version', '25000');
  request2.headers.add('notes', 'false');
  final response2 = await request2.close();
  final content2 = await response2.transform(utf8.decoder).join();
  print('请求 URL: $uri2');
  print('HTTP 状态码: ${response2.statusCode}');
  print('主要 Header: version=25000, notes=false');
}
