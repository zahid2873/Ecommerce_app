import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../models/date_model.dart';
import '../models/product_model.dart';
import '../models/purchase_model.dart';
import '../providers/product_provider.dart';
import '../utils/helper_functions.dart';

class ProductRepurchasePage extends StatefulWidget {
  static const String routeName = '/repurchase';
  const ProductRepurchasePage({Key? key}) : super(key: key);

  @override
  State<ProductRepurchasePage> createState() => _ProductRepurchasePageState();
}

class _ProductRepurchasePageState extends State<ProductRepurchasePage> {
  final _quantityController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _changeAmountController = TextEditingController();
  // Initial Selected Value
  String dropdownValue = 'Increase';

  // List of items in our dropdown menu
  var items = [
    'Increase',
    'Decrease',
  ];

  final _formKey = GlobalKey<FormState>();
  DateTime? purchaseDate;
  late ProductModel productModel;
  @override
  void didChangeDependencies() {
    productModel = ModalRoute.of(context)!.settings.arguments as ProductModel;
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Repurchase"),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Text(productModel.productName, style: Theme.of(context).textTheme.headline5,),
              const Divider(height: 2, color: Colors.grey,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _purchasePriceController,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Enter Purchase Price',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field must not be empty';
                    }
                    if (num.parse(value) <= 0) {
                      return 'Price should be greater than 0';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Enter Quantity',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field must not be empty';
                    }
                    if (num.parse(value) <= 0) {
                      return 'Quantity should be greater than 0';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                width: double.infinity,
                height: 75,
                color: Colors.grey.shade200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Any Change in sale Price?(Previous salePrice :${productModel.salePrice})"),
                    SizedBox(height: 2,),
                    DropdownButton(

                      // Initial Value
                      value: dropdownValue,
                      hint: Text('Is price increase or decrease'),

                      // Down Arrow Icon
                      icon: const Icon(Icons.keyboard_arrow_down),

                      // Array list of items
                      items: items.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items,style: TextStyle(fontSize: 14),),
                        );
                      }).toList(),
                      // After selecting the desired option,it will
                      // change button value to selected value
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              if(dropdownValue !='No Change') Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _changeAmountController,
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'How much will increase or decrease',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field must not be empty';
                    }

                    return null;
                  },
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Select Purchase Date'),
                      ),
                      Text(purchaseDate == null
                          ? 'No date chosen'
                          : getFormattedDate(purchaseDate!)),
                    ],
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: _repurchase,
                child: const Text('Re-purchase'),
              )
            ],
          ),
        ),
      ),
    );
  }
  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now(),
    );
    if(date != null) {
      setState(() {
        purchaseDate = date;
      });
    }
  }

  void _repurchase() {
    if(purchaseDate == null) {
      showMsg(context, 'Please select a purchase date');
      return;
    }

    if(_formKey.currentState!.validate()) {
      EasyLoading.show(status: 'Please wait');
      final model = PurchaseModel(
          productId: productModel.productId,
          isPriceChanged: dropdownValue,
          purchaseQuantity: num.parse(_quantityController.text),
          purchasePrice: num.parse(_purchasePriceController.text),
          changedAmount: num.parse(_changeAmountController.text),
          dateModel: DateModel(
              timestamp: Timestamp.fromDate(purchaseDate!),
              day: purchaseDate!.day,
              month: purchaseDate!.month,
              year: purchaseDate!.year),
      );
      Provider.of<ProductProvider>(context,listen: false)
          .repurchase(model, productModel).then((value) {
            EasyLoading.dismiss();
            showMsg(context, 'Repurchase Successfully');
            Navigator.pop(context);
            }).catchError((error){
              EasyLoading.dismiss();
              showMsg(context, "Repurchase Failed");
      });

    }
  }
}
