
GetX Integration:
- GetMaterialApp in main.dart
- Get.put(AuthController()) in main.dart
- Use Get.find<AuthController>() in screens
- Use Obx(() => Text(controller.userName.value))
