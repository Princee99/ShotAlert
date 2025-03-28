import 'package:get/get.dart';

class CodeController extends GetxController {
  var code = " ".obs;
  updatecode(String value) {
    code.value = value;
  }
}
