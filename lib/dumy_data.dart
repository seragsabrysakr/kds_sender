import 'package:uuid/uuid.dart';

Future<Map<String, dynamic>> generateKdsModel() async {
  final uuid = Uuid();

  // Simulated invoice product item
  final mockProduct = {
    "productNameAr": "شاورما دجاج",
    "productNameEn": "Chicken Shawarma",
  };

  final mockUnit = {"nameAr": "وجبة", "nameEn": "Meal"};

  final mockItem = {
    "product": mockProduct,
    "quantity": 2,
    "unit": mockUnit,
    "variations": [
      {
        "variation": {"variantValueId": 101},
      },
      {
        "variation": {"variantValueId": 102},
      },
    ],
  };

  final mockVariationTranslationTable = [
    {"variantValueId": 101, "languageId": 1, "name": "Spicy Sauce"},
    {"variantValueId": 101, "languageId": 2, "name": "صلصة حارة"},
    {"variantValueId": 102, "languageId": 1, "name": "Extra Cheese"},
    {"variantValueId": 102, "languageId": 2, "name": "جبنة زيادة"},
  ];

  // Unique ID based on current time
  final uniqueId = DateTime.now().millisecondsSinceEpoch;

  final mockInvoice = {
    "id": uniqueId,
    "createdAt": DateTime.now().toIso8601String(),
    "products": [mockItem],
  };

  // Extract modifier names
  List<int> ids =
      (mockItem["variations"] as List?)
          ?.map<int>((e) => e["variation"]["variantValueId"] as int)
          .toList() ??
      [];

  List<String> modifires = [];
  List<String> modifiresEn = [];

  for (var variant in mockVariationTranslationTable) {
    if (ids.contains(variant["variantValueId"])) {
      if (variant["languageId"] == 2) {
        modifires.add(variant["name"] as String);
      } else {
        modifiresEn.add(variant["name"] as String);
      }
    }
  }

  // Construct order data
  final data = {
    "id": mockInvoice["id"],
    "invoiceId": "INV-${mockInvoice["id"]}",
    "order_id": mockInvoice["id"],
    "created_at": mockInvoice["createdAt"],
    "status": "Pending",
    "table_number": "",
    "customer_name": "",
    "items": List.generate(3, (index) {
      return {
        "sortOrder": index + 1,
        "itemGuid": uuid.v4(),
        "customerNo": "P1",
        "itemStatus": "Pending",
        "name": mockProduct["productNameAr"],
        "nameEn": mockProduct["productNameEn"],
        "quantity": mockItem["quantity"].toString(),
        "orderRefId": "INV-${mockInvoice["id"]}",
        "modifires": [mockUnit["nameAr"], ...modifires].toString(),
        "modifiresEn": [mockUnit["nameEn"], ...modifiresEn].toString(),
      };
    }),
  };

  return data;
}
