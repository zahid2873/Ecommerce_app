
import 'date_model.dart';
const String collectionPurchase='Purchases';

const String purchaseFieldId='purchaseId';
const String purchaseFieldProductId='productId';
const String purchaseFieldQuantity='purchaseQuantity';
const String purchaseFieldPrice='purchasePrice';
const String changedFieldAmount='changedAmount';
const String isPriceChangedField='isPriceChanged';

const String purchaseFieldDateModel='dateModel';


class PurchaseModel{

  String? purchaseId;
  String ? productId;
  String ? isPriceChanged;
  num purchaseQuantity;
  num purchasePrice;
  num ? changedAmount;
  DateModel dateModel;

  PurchaseModel({
    this.purchaseId,
    this.productId,
    this.isPriceChanged,
    this.changedAmount,
    required this.purchaseQuantity,
    required this.purchasePrice,
    required this.dateModel,
  });

  Map<String,dynamic>toMap(){
    return <String,dynamic>{
      purchaseFieldId:purchaseId,
      purchaseFieldProductId:productId,
      isPriceChangedField : isPriceChanged,
      purchaseFieldQuantity:purchaseQuantity,
      purchaseFieldPrice:purchasePrice,
      changedFieldAmount: changedAmount,
      purchaseFieldDateModel:dateModel.toMap(),
    };
  }

  factory PurchaseModel.fromMap(Map<String,dynamic>map)=>PurchaseModel(
    purchaseId:map[purchaseFieldId],
    productId:map[purchaseFieldProductId],
    isPriceChanged:map[isPriceChangedField],

    purchaseQuantity: map[purchaseFieldQuantity],
    purchasePrice:map[purchaseFieldPrice],
    changedAmount:map[changedFieldAmount],

    dateModel: DateModel.fromMap(map[purchaseFieldDateModel]),
  );
}