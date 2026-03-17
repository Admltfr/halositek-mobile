import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halositek/app/modules/auth/widgets/hero_bg.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(body: Stack(children: [HeroBg(size: size)]));
  }
}
