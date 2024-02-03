import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class AddDebtorPopup extends StatefulWidget {
  final int adminId;
  final Function(List<Map<String, dynamic>>, int) onDebtorAdded;
  const AddDebtorPopup({super.key,required this.adminId,required this.onDebtorAdded});

  @override
  // ignore: library_private_types_in_public_api
  _AddDebtorPopupState createState() => _AddDebtorPopupState();
}

class _AddDebtorPopupState extends State<AddDebtorPopup> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String mobile;
  String address = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Debtor'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) {
                name = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Mobile'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a mobile number';
                }
                final RegExp mobileRegex = RegExp(r'^\d{10}$');

                if (!mobileRegex.hasMatch(value)) {
                  return 'Invalid mobile number';
                }

                return null;
              },
              onSaved: (value) {
                mobile = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Address'),
              onSaved: (value) {
                address = value ?? '';
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      print('Name: $name, Mobile: $mobile, Address: $address');
                      const String apiUrl = 'https://wpoc2ga7ki.execute-api.ap-southeast-1.amazonaws.com/dev/v1/AddDebtor';
                      try {
                        final response = await http.post(
                          Uri.parse(apiUrl),
                          body: {
                            'AdminID':widget.adminId.toString(),
                            'Name': name,
                            'Mobile': mobile,
                            'Address': address,
                          },
                        );
                        if (response.statusCode == 200) {
                          Map<String, dynamic> responseData = json.decode(response.body);
                          if (responseData['status'] == true){
                            Fluttertoast.showToast(
                              msg: "Debtor Creation Successful",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 2,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                            );
                            List<Map<String, dynamic>> newDebtors = (responseData['ActiveDebtors'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                            widget.onDebtorAdded(newDebtors, responseData['ActiveDebtorsCount']);
                          }
                          else{
                            Fluttertoast.showToast(
                              msg: "Debtor Creation Failed",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 2,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                          } else {
                          Fluttertoast.showToast(
                              msg: "Some Error Occoured",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 2,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                        }
                      } catch (e) {
                        Fluttertoast.showToast(
                              msg: "Server Error",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 2,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Create'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}