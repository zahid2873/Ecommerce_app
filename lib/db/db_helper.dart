import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/order_constant_model.dart';
import '../models/product_model.dart';
import '../models/purchase_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../models/order_model.dart';

class DbHelper {
  static const String collectionAdmin = 'Admins';

  static final _db = FirebaseFirestore.instance;

  static Future<bool> isAdmin(String uid) async {
    final snapshot = await _db.collection(collectionAdmin).doc(uid).get();
    return snapshot.exists;
  }

  static Future<void> addCategory(CategoryModel categoryModel) {
    final doc = _db.collection(collectionCategory).doc();
    categoryModel.categoryId = doc.id;
    return doc.set(categoryModel.toMap());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllCategories() =>
      _db.collection(collectionCategory).snapshots();

  static Future<void> addNewProduct(ProductModel productModel,
      PurchaseModel purchaseModel) {
    final wb = _db.batch();
    final productDoc = _db.collection(collectionProduct).doc();
    final purchaseDoc = _db.collection(collectionPurchase).doc();
    final categoryDoc = _db
        .collection(collectionCategory)
        .doc(productModel.category.categoryId);
    productModel.productId = productDoc.id;
    purchaseModel.productId = productDoc.id;
    purchaseModel.purchaseId = purchaseDoc.id;
    wb.set(productDoc, productModel.toMap());
    wb.set(purchaseDoc, purchaseModel.toMap());
    wb.update(categoryDoc, {
      categoryFieldProductCount:
      (productModel.category.productCount + purchaseModel.purchaseQuantity)
    });
    return wb.commit();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllProducts() =>
      _db.collection(collectionProduct).snapshots();

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getOrderConstants() =>
      _db
          .collection(collectionOrderConstant)
          .doc(documentOrderConstant)
          .snapshots();

  static Future<void> updateOrderConstants(OrderConstantModel model) {
    return _db
        .collection(collectionOrderConstant)
        .doc(documentOrderConstant)
        .set(model.toMap());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllPurchases() =>
      _db.collection(collectionPurchase).snapshots();


  static Future<void> repurchase(PurchaseModel purchaseModel,
      ProductModel productModel) async {
    final wb = _db.batch();
    final purDoc = _db.collection(collectionPurchase).doc();
    purchaseModel.purchaseId = purDoc.id;
    wb.set(purDoc, purchaseModel.toMap());
    final proDoc =
    _db.collection(collectionProduct).doc(productModel.productId);
    wb.update(proDoc, {
      productFieldStock: (productModel.stock + purchaseModel.purchaseQuantity),

      productFieldSalePrice: isPriceChangedField == 'Increase' ? (productModel
          .salePrice + purchaseModel.changedAmount!) : (productModel.salePrice -
          purchaseModel.changedAmount!),

    });
    if (purchaseModel.isPriceChanged == 'Increase') {
      wb.update(proDoc, {

        productFieldSalePrice: (productModel.salePrice +
            purchaseModel.changedAmount!),

      });
    }
    else {
      wb.update(proDoc, {

        productFieldSalePrice: (productModel.salePrice -
            purchaseModel.changedAmount!),

      });
    }

    final snapshot = await _db
        .collection(collectionCategory)
        .doc(productModel.category.categoryId)
        .get();
    final prevCount = snapshot.data()![categoryFieldProductCount];
    final catDoc = _db
        .collection(collectionCategory)
        .doc(productModel.category.categoryId);
    wb.update(catDoc, {
      categoryFieldProductCount: (prevCount + purchaseModel.purchaseQuantity)
    });
    return wb.commit();
  }

  static Future<void> updateProductField(String productId,
      Map<String, dynamic> map) {
    return _db.collection(collectionProduct).doc(productId).update(map);
  }


  static Future<bool> doesUserExist(String uid) async {
    final snapshot = await _db.collection(collectionUser).doc(uid).get();
    return snapshot.exists;
  }


  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() =>
      _db.collection(collectionUser).snapshots();


  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllOrders() =>
      _db.collection(collectionOrder).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllProductsByCategory(
      CategoryModel categoryModel) =>
      _db
          .collection(collectionProduct)
          .where('$productFieldCategory.$categoryFieldId',
          isEqualTo: categoryModel.categoryId)
          .snapshots();


  static Future<void> updateOrderStatus(String orderId, String status) {
    return _db
        .collection(collectionOrder)
        .doc(orderId)
        .update({orderFieldOrderStatus: status});
  }

  static Future<void> updateNotificationStatus(String id, bool status) {
    return _db
        .collection(collectionNotification)
        .doc(id)
        .update({notificationFieldStatus: status});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllNotifications() =>
      _db.collection(collectionNotification).snapshots();


}