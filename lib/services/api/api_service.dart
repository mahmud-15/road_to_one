import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:road_project_flutter/utils/log/app_log.dart';
import '../../config/api/api_end_point.dart';
import '../../utils/constants/app_string.dart';
import '../../utils/log/api_log.dart';
import '../storage/storage_services.dart';
import 'api_response_model.dart';

class ApiService2 {
  static Future<Response<dynamic>?> get(
    String url, {
    Map<String, dynamic>? header,
  }) async {
    final dio = Dio();
    final mainHeader = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${LocalStorage.token}",
    };
    appLog("Url: $url\nHeader: ${header ?? mainHeader}");
    try {
      final response = await dio.get(
        url,
        options: Options(headers: header ?? mainHeader),
      );
      appLog(response);
      return response;
    } on DioException catch (e) {
      // 👇 THIS IS WHERE 400 LIVES
      appLog("Dio Error!");
      appLog("Status: ${e.response?.statusCode}");
      appLog("Data: ${e.response?.data}");
      return e.response;
    } on Exception catch (e) {
      appLog(e);
      return null;
    }
  }

  static Future<Response<dynamic>?> post(
    String url, {
    required Map<dynamic, dynamic> body,
    Map<String, dynamic>? header,
  }) async {
    final dio = Dio();
    final mainHeader = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${LocalStorage.token}",
    };

    appLog("Url: $url\nHeader: ${header ?? mainHeader}\nBody: $body");

    try {
      final response = await dio.post(
        url,
        data: body,
        options: Options(headers: header ?? mainHeader),
      );
      appLog(response);

      return response;
    } on DioException catch (e) {
      // 👇 THIS IS WHERE 400 LIVES
      appLog("Dio Error!");
      appLog("Status: ${e.response?.statusCode}");
      appLog("Data: ${e.response?.data}");
      return e.response;
    } on Exception catch (e) {
      appLog(e);
      return null;
    }
  }

  static Future<Response<dynamic>?> formDataImage(
    String url, {
    required String image,
    Map<String, dynamic>? header,
    required bool isPost,
  }) async {
    final dio = Dio();
    final mainHeader = {"Authorization": "Bearer ${LocalStorage.token}"};

    appLog("Url: $url\nHeader: ${header ?? mainHeader}");
    final formdata = FormData.fromMap({
      'image': [await MultipartFile.fromFile(image, filename: image)],
    });
    try {
      Response response;
      if (isPost) {
        response = await dio.post(
          url,
          data: formdata,
          options: Options(headers: header ?? mainHeader),
        );
      } else {
        response = await dio.patch(
          url,
          data: formdata,
          options: Options(headers: header ?? mainHeader),
        );
      }

      appLog(response);

      return response;
    } on DioException catch (e) {
      // 👇 THIS IS WHERE 400 LIVES
      appLog("Dio Error!");
      appLog("Status: ${e.response?.statusCode}");
      appLog("Data: ${e.response?.data}");
      return e.response;
    } on Exception catch (e) {
      appLog(e);
      return null;
    }
  }
}

class ApiService {
  static final Dio _dio = _getMyDio();

  /// ========== [ HTTP METHODS ] ========== ///
  static Future<ApiResponseModel> post(
    String url, {
    dynamic body,
    Map<String, String>? header,
  }) => _request(url, "POST", body: body, header: header);

  static Future<ApiResponseModel> get(
    String url, {
    Map<String, String>? header,
  }) => _request(url, "GET", header: header);

  static Future<ApiResponseModel> put(
    String url, {
    dynamic body,
    Map<String, String>? header,
  }) => _request(url, "PUT", body: body, header: header);

  static Future<ApiResponseModel> patch(
    String url, {
    dynamic body,
    Map<String, String>? header,
  }) => _request(url, "PATCH", body: body, header: header);

  static Future<ApiResponseModel> delete(
    String url, {
    dynamic body,
    Map<String, String>? header,
  }) => _request(url, "DELETE", body: body, header: header);

  static Future<ApiResponseModel> multipartImage(
    String url, {
    Map<String, String> header = const {},
    Map<String, String> body = const {},
    String method = "POST",
    List files = const [],
  }) async {
    FormData formData = FormData();

    for (var item in files) {
      String imageName = item['name'] ?? "image";
      String? imagePath = item['image'];
      if (imagePath != null && imagePath.isNotEmpty) {
        File file = File(imagePath);
        String extension = file.path.split('.').last.toLowerCase();
        String? mimeType = lookupMimeType(imagePath);
        formData.files.add(
          MapEntry(
            imageName,
            await MultipartFile.fromFile(
              imagePath,
              filename: "$imageName.$extension",
              contentType: mimeType != null
                  ? DioMediaType.parse(mimeType)
                  : DioMediaType.parse("image/jpeg"),
            ),
          ),
        );
      }
    }

    body.forEach((key, value) {
      formData.fields.add(MapEntry(key, value));
    });

    final headers = Map<String, String>.from(header);
    headers['Content-Type'] = 'multipart/form-data';

    return _request(url, method, body: formData, header: header);
  }

  static Future<ApiResponseModel> multipart(
    String url, {
    Map<String, String> header = const {},
    Map<String, dynamic> body = const {},
    String method = "POST",
    String imageName = 'image',
    String? imagePath,
  }) async {
    FormData formData = FormData();
    if (imagePath != null && imagePath.isNotEmpty) {
      File file = File(imagePath);
      String extension = file.path.split('.').last.toLowerCase();
      String? mimeType = lookupMimeType(imagePath);

      formData.files.add(
        MapEntry(
          imageName,
          await MultipartFile.fromFile(
            imagePath,
            filename: "$imageName.$extension",
            contentType: mimeType != null
                ? DioMediaType.parse(mimeType)
                : DioMediaType.parse("image/jpeg"),
          ),
        ),
      );
    }

    body.forEach((key, value) {
      formData.fields.add(MapEntry(key, value));
    });

    header['Content-Type'] = "multipart/form-data";

    return _request(url, method, body: formData, header: header);
  }

  /// ========== [ API REQUEST HANDLER ] ========== ///
  static Future<ApiResponseModel> _request(
    String url,
    String method, {
    dynamic body,
    Map<String, String>? header,
  }) async {
    try {
      final response = await _dio.request(
        url,
        data: body,
        options: Options(method: method, headers: header),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static ApiResponseModel _handleResponse(Response response) {
    if (response.statusCode == 201) {
      return ApiResponseModel(200, response.data);
    }
    return ApiResponseModel(response.statusCode, response.data);
  }

  static ApiResponseModel _handleError(dynamic error) {
    try {
      return _handleDioException(error);
    } catch (e) {
      return ApiResponseModel(500, {});
    }
  }

  static ApiResponseModel _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        print("Timeout Error: ${error.message}");
        return ApiResponseModel(408, {"message": AppString.requestTimeOut});

      case DioExceptionType.badResponse:
        return ApiResponseModel(
          error.response?.statusCode,
          error.response?.data,
        );

      case DioExceptionType.connectionError:
        return ApiResponseModel(503, {
          "message": AppString.noInternetConnection,
        });

      default:
        return ApiResponseModel(400, {});
    }
  }
}

/// ========== [ DIO INSTANCE WITH INTERCEPTORS ] ========== ///
Dio _getMyDio() {
  Dio dio = Dio();

  dio.interceptors.add(apiLog());

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options
          ..headers["Authorization"] ??= "Bearer ${LocalStorage.token}"
          ..headers["Content-Type"] ??= "application/json"
          ..connectTimeout = const Duration(seconds: 30)
          ..sendTimeout = const Duration(seconds: 30)
          ..receiveDataWhenStatusError = true
          ..responseType = ResponseType.json
          ..receiveTimeout = const Duration(seconds: 30)
          ..baseUrl = options.baseUrl.startsWith("http")
              ? ""
              : ApiEndPoint.baseUrl;
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ),
  );
  return dio;
}
