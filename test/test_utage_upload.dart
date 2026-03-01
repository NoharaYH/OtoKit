import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  const token =
      "1819fe2a6c9a53322089f2eafc3909a26f5613bc955199c69e17733b47f88e06244164f5b8a0c01bff5279539266581852c03b05bbf120653569d9a265267103";
  const filePath =
      r"D:\CodeProject\抓包测试\HTML\[SYNC-HTML]-Utage-1772119248647.html";

  print("[TEST] Sending to local page-parser (port 8089)...");
  dynamic records;
  try {
    final htmlContent = await File(filePath).readAsBytes();
    final response = await dio.post(
      "http://localhost:8089/page",
      data: Stream.fromIterable([htmlContent]),
      options: Options(headers: {Headers.contentTypeHeader: "text/plain"}),
    );
    records = response.data;
    print("[SUCCESS] Local Parse Result: ${records.length} records found.");
  } catch (e) {
    print("[ERROR] Local Parse Failed: $e");
    return;
  }

  print(
    "\n[TEST] Pushing parsed JSON to official Diving Fish API (/player/update_records)...",
  );
  try {
    final response = await dio.post(
      "https://www.diving-fish.com/api/maimaidxprober/player/update_records",
      data: records,
      options: Options(
        headers: {
          "Import-Token": token,
          Headers.contentTypeHeader: "application/json",
        },
      ),
    );
    print(
      "[SUCCESS] Diving Fish JSON Push Response: ${response.statusCode} - ${response.data}",
    );
  } catch (e) {
    if (e is DioException) {
      print(
        "[ERROR] JSON Push Failed: ${e.response?.statusCode} - ${e.response?.data}",
      );
    } else {
      print("[ERROR] JSON Push Failed: $e");
    }
  }
}
