import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:librarp_digital/service/api_client.dart';

class NetworkHelper {
  NetworkHelper(
    this.jsonInput,
    this.requestToken,
    this.params, {
    required this.url,
  });
  late Dio client = ApiClient().init();

  final String url;
  final dynamic jsonInput;
  final dynamic params;
  final bool? requestToken;

  Future postForLogin() async {
    try {
      print(url);
      print(jsonInput);
      createCancelDio();

      Response response;
      if (jsonInput == null) {
        response = await client.post(
          url,
          options: Options(contentType: "application/json"),
        );
      } else {
        response = await client.post(
          url,
          data: jsonInput,
          options: Options(contentType: "application/json"),
        );
      }

      print(response.headers);

      cancelDio();
      print("balikan response post login ${response.data}");
      return response.data;
    } on DioException catch (e) {
      cancelDio();
      print('errorDio2: ${e.response?.data}');
      return e.response?.data;
    }
    // } catch (e) {
    //   if (e is PendingApprovalException) {
    //     cancelDio();
    //     print('pending approval: $e');
    //     // Tangani kasus persetujuan yang tertunda
    //     PopupWarning.showAlertDialog(
    //       text: AppConstants.text_oops,
    //       description: e.message,
    //       onPressedRight: () {},
    //     );
    //   }
    //   else {
    //     cancelDio();
    //     if (e is DioException) {
    //       print('errorDio: ${e.response?.data}');
    //       var response = {"code": e.response?.statusCode, "message": e.toString(), "data": null};
    //       return response;
    //     }
    //   }
    // }
  }

  Future postRequest() async {
    try {
      print(url);
      print(jsonInput);
      createCancelDio();

      Response response;
      response = await client.post(
        url,
        data: jsonInput,
        options: Options(contentType: "application/json"),
      );

      cancelDio();
      print("balikan response post $response");

      return response.data;
    } on DioException catch (e) {
      cancelDio();
      print('errorDio2: $e');
      return e.response?.data;
    }
  }

  Future getRequestInit() async {
    try {
      print(url);
      createCancelDio();

      Response responseGet;
      if (jsonInput == null) {
        if (requestToken == false) {
          if (params == null) {
            responseGet = await client.get(
              url,
              options: Options(contentType: "application/json"),
            );
          } else {
            responseGet = await client.get(
              url,
              queryParameters: params,
              options: Options(contentType: "application/json"),
            );
          }
        } else {
          if (params == null) {
            responseGet = await client.get(
              url,
              options: Options(contentType: "application/json"),
            );
          } else {
            responseGet = await client.get(
              url,
              queryParameters: params,
              options: Options(contentType: "application/json"),
            );
          }
        }
      } else {
        if (requestToken == false) {
          responseGet = await client.get(
            url,
            queryParameters: jsonInput,
            options: Options(contentType: "application/json"),
          );
        } else {
          responseGet = await client.get(
            url,
            data: jsonInput,
            options: Options(contentType: "application/json"),
          );
        }
      }

      cancelDio();
      log("balikan response get ${responseGet.data}");
      return responseGet.data;
    } catch (e) {
      print(e);
      cancelDio();
      if (e is DioException) {
        print('errorDio: ${e.response?.data}');
        var response = {
          "code": e.response?.statusCode,
          "message": e.toString(),
          "data": null,
        };
        return response;
      }
    }
  }

  Future getRequest() async {
    try {
      print(url);
      createCancelDio();

      Response responseGet;
      if (jsonInput == null) {
        if (requestToken == false) {
          if (params == null) {
            responseGet = await client.get(
              url,
              options: Options(contentType: "application/json"),
            );
          } else {
            responseGet = await client.get(
              url,
              queryParameters: params,
              options: Options(contentType: "application/json"),
            );
          }
        } else {
          if (params == null) {
            responseGet = await client.get(
              url,
              options: Options(contentType: "application/json"),
            );
          } else {
            responseGet = await client.get(
              url,
              queryParameters: params,
              options: Options(contentType: "application/json"),
            );
          }
        }
      } else {
        if (requestToken == false) {
          if (params == 'google') {
            responseGet = await client.get(
              url,
              queryParameters: jsonInput,
              options: Options(contentType: "application/json"),
            );
          } else if (params == 'apple') {
            responseGet = await client.get(
              url,
              queryParameters: jsonInput,
              options: Options(contentType: "application/json"),
            );
          } else {
            responseGet = await client.get(
              url,
              queryParameters: jsonInput,
              options: Options(contentType: "application/json"),
            );
          }
        } else {
          responseGet = await client.get(
            url,
            data: jsonInput,
            options: Options(contentType: "application/json"),
          );
        }
      }

      cancelDio();
      log("balikan response get ${responseGet.data}");
      return responseGet.data;
    } catch (e) {
      print(e);
      cancelDio();
      if (e is DioException) {
        print('errorDio: ${e.response?.data}');
        var response = {
          "code": e.response?.statusCode,
          "message": e.toString(),
          "data": null,
        };
        return response;
      }
    }
  }

  Future deleteRequest() async {
    try {
      print(url);

      Response responseget;
      responseget = await client.delete(url);

      String data = responseget.data;
      var decodedData = jsonDecode(data);
      print(responseget.data);
      return decodedData;
    } catch (e) {
      print(e);
      var response = {"status": 500, "message": e.toString(), "result": null};
      return response;
    }
  }

  Future putRequest() async {
    try {
      print(url);
      createCancelDio();

      Response responsePut;
      if (jsonInput == null) {
        responsePut = await client.put(url);
        if (requestToken == false) {
          responsePut = await client.put(
            url,
            options: Options(contentType: "application/json"),
          );
        } else {
          responsePut = await client.put(
            url,
            queryParameters: params,
            options: Options(contentType: "application/json"),
          );
        }
      } else {
        if (requestToken == false) {
          responsePut = await client.put(
            url,
            queryParameters: jsonInput,
            options: Options(contentType: "application/json", headers: {}),
          );
        } else {
          responsePut = await client.put(
            url,
            data: jsonInput,
            options: Options(contentType: "application/json"),
          );
        }
      }

      cancelDio();
      print("balikan response put ${responsePut.data}");
      return responsePut.data;
    } on DioException catch (e) {
      cancelDio();
      print('errorDio: ${e.response?.data}');
      return e.response?.data;
    }
  }

  Future patchRequest() async {
    try {
      print(url);
      Response responsePut;

      if (jsonInput == null) {
        responsePut = await client.patch(url);
        if (requestToken == false) {
          responsePut = await client.patch(url);
        } else {
          responsePut = await client.patch(
            url,
            options: Options(contentType: "application/json"),
          );
        }
      } else {
        if (requestToken == false) {
          responsePut = await client.patch(url, data: jsonInput);
        } else {
          responsePut = await client.patch(
            url,
            data: jsonInput,
            options: Options(contentType: "application/json"),
          );
        }
      }

      print("balikan response patch ${responsePut.data}");
      return responsePut.data;
    } on DioException catch (e) {
      print(e);
      var response = {"status": 500, "message": e.toString(), "result": null};
      return response;
    }
  }

  void createCancelDio() {
    final Dio newClient = ApiClient().init();
    client = newClient;
  }

  void cancelDio() {
    client.httpClientAdapter.close(force: true);
  }
}

class PendingApprovalException implements Exception {
  final String message;
  PendingApprovalException(this.message);
}
