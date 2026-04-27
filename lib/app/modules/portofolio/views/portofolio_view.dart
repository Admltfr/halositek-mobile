import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/portofolio_controller.dart';

class PortofolioView extends GetView<PortofolioController> {
  const PortofolioView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PortofolioView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'PortofolioView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
