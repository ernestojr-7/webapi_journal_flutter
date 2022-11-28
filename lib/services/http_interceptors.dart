import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor implements InterceptorContract {
  Logger logger = Logger(printer: PrettyPrinter(methodCount: 0));

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    logger.v("Requisição para: ${data.baseUrl}\n${data.headers}");
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    // verificando ocorrencia de sucesso ou erro
    if (data.statusCode ~/ 100 == 2) {
      logger.i(
          "Resposta de ${data.url}\nStatus da resposta: ${data.statusCode}\nCabeçalho: ${data.headers}\nCorpo: ${data.body}");
    } else {
      logger.e(
          "Resposta de ${data.url}\nStatus da resposta: ${data.statusCode}\nCabeçalho: ${data.headers}\nCorpo: ${data.body}");
    }

    return data;
  }
}