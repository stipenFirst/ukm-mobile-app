
import 'package:get/get.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final userName = ''.obs;

  void setUserName(String value){
    userName.value = value;
  }

  void setLoading(bool value){
    isLoading.value = value;
  }
}
