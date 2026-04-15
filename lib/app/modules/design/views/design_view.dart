import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/design_controller.dart';

class DesignView extends GetView<DesignController> {
  const DesignView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DesignView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DesignView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
