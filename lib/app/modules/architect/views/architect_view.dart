import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/architect_controller.dart';

class ArchitectView extends GetView<ArchitectController> {
  const ArchitectView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ArchitectView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ArchitectView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
