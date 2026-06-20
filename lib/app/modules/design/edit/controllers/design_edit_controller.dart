import 'package:halositek/app/modules/design/controllers/design_form_controller.dart';

class DesignEditController extends DesignFormController {
  DesignEditController(
    super.catalogService, {
    required super.catalogId,
    super.initialCatalog,
  }) : super(mode: DesignFormMode.edit);
}
