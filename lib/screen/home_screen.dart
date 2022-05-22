import 'package:flutter/material.dart';
import 'package:kas_wallet_connector_example_bapp/model/error.dart';
import 'package:kas_wallet_connector_example_bapp/model/tx.dart';
import 'package:kas_wallet_connector_example_bapp/screen/login_screen.dart';
import 'package:kas_wallet_connector_example_bapp/service/kas_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController toController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final _kasService = KasService();
  TransactionResult? txResult;

  Future<void> sendLegacyTransaction() async {
    _formKey.currentState!.validate();

    final to = toController.text;
    final value = valueController.text;
    dynamic res = await _kasService.sendLegacyTransaction(to, value);

    if (res is KasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${res.message}'),
        ),
      );
      return;
    }

    setState(() {
      txResult = TransactionResult.fromJson(res);
      print(txResult);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              icon: Icon(Icons.logout)),
        ],
        centerTitle: true,
        title: Text('Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20.0),
              TxTextFormField(
                controller: toController,
                hintText: 'to',
              ),
              TxTextFormField(
                controller: valueController,
                hintText: 'value',
              ),
              SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: sendLegacyTransaction,
                        child: Text('Submit'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              txResult != null
                  ? Card(
                      elevation: 20,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Container(
                          height: 100,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'transactionHash: ${txResult!.transactionHash}'),
                                SizedBox(height: 5.0),
                                Text('value: ${txResult!.value}'),
                                SizedBox(height: 5.0),
                                Text('to: ${txResult!.to}'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}

class TxTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  const TxTextFormField(
      {Key? key, required this.hintText, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please fill this field';
          }
          return null;
        },
        maxLines: 1,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
