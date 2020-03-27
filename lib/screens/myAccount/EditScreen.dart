import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pikobar_flutter/blocs/authentication/Bloc.dart';
import 'package:pikobar_flutter/components/DialogTextOnly.dart';
import 'package:pikobar_flutter/constants/Dictionary.dart';
import 'package:pikobar_flutter/constants/Navigation.dart';
import 'package:pikobar_flutter/constants/UrlThirdParty.dart';
import 'package:pikobar_flutter/screens/myAccount/VerificationScreen.dart';
import 'package:pikobar_flutter/utilities/Connection.dart';
import 'package:pikobar_flutter/utilities/Validations.dart';

class Edit extends StatefulWidget {
  final AsyncSnapshot<DocumentSnapshot> state;
  Edit({this.state});
  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  String verificationID, smsCode;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    _nameController.text = widget.state.data['name'];
    _emailController.text = widget.state.data['email'];
    _phoneNumberController.text = widget.state.data['phone_number'] != null
        ? widget.state.data['phone_number'].toString().substring(3)
        : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text(Dictionary.edit),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    buildTextField(
                        title: Dictionary.name,
                        controller: _nameController,
                        isEdit: false),
                    SizedBox(
                      height: 20,
                    ),
                    buildTextField(
                        title: Dictionary.email,
                        controller: _emailController,
                        isEdit: false),
                    SizedBox(
                      height: 20,
                    ),
                    buildPhoneField(
                        title: Dictionary.phoneNumber,
                        controller: _phoneNumberController,
                        validation: Validations.phoneValidation,
                        isEdit: true,
                        hintText: Dictionary.phoneNumberPlaceholder),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            RaisedButton(
              color: Color(0xff27AE60),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              onPressed: _onSaveProfileButtonPressed,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Text(
                  Dictionary.save,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _onSaveProfileButtonPressed() async {
    if (_formKey.currentState.validate()) {
      try {
        bool isConnected =
            await Connection().checkConnection(UrlThirdParty.urlGoogle);
        if (isConnected) {
           _scaffoldState.currentState.showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  content: Row(
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Container(
                        margin: EdgeInsets.only(left: 15.0),
                        child: Text(Dictionary.loading),
                      )
                    ],
                  ),
                  duration: Duration(seconds: 5),
                ),
              );
          await Firestore.instance
              .collection('users')
              .document(widget.state.data['id'])
              .updateData({
            'phone_number': Dictionary.inaCode + _phoneNumberController.text
          });
          _scaffoldState.currentState.hideCurrentSnackBar();
          showDialog(
              context: context,
              builder: (BuildContext context) => DialogTextOnly(
                    description: Dictionary.updateProfile,
                    buttonText: Dictionary.ok,
                    onOkPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ));
          // await sendCodeToPhoneNumber();
        }
      } catch (error) {
        await showDialog(
            context: context,
            builder: (BuildContext context) => DialogTextOnly(
                  description: error.toString(),
                  buttonText: Dictionary.ok,
                  onOkPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                ));
      }
    }
  }

  Widget buildTextField(
      {String title,
      TextEditingController controller,
      String hintText,
      validation,
      TextInputType textInputType,
      TextStyle textStyle,
      bool isEdit}) {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 15.0, color: Color(0xff828282)),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            child: TextFormField(
              style: isEdit
                  ? TextStyle(
                      color: Colors.black,
                    )
                  : TextStyle(color: Color(0xffBDBDBD)),
              enabled: isEdit,
              validator: validation,
              controller: controller,
              decoration: InputDecoration(
                  hintText: hintText,
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Color(0xffE0E0E0), width: 1.5)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Color(0xffE0E0E0), width: 1.5))),
              keyboardType:
                  textInputType != null ? textInputType : TextInputType.text,
            ),
          )
        ],
      ),
    );
  }

  Widget buildPhoneField(
      {String title,
      TextEditingController controller,
      String hintText,
      validation,
      TextInputType textInputType,
      TextStyle textStyle,
      bool isEdit}) {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 15.0, color: Color(0xff828282)),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 60,
                width: MediaQuery.of(context).size.width / 7,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xffE0E0E0), width: 1.5)),
                child: Center(
                    child: Text(
                  Dictionary.inaCode,
                  style: TextStyle(fontSize: 15),
                )),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  style: isEdit
                      ? TextStyle(color: Colors.black)
                      : TextStyle(color: Color(0xffBDBDBD)),
                  enabled: isEdit,
                  validator: validation,
                  controller: controller,
                  decoration: InputDecoration(
                      hintText: hintText,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Color(0xffE0E0E0), width: 1.5)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Color(0xffE0E0E0), width: 1)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Color(0xffE0E0E0), width: 2))),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> sendCodeToPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential user) {
      _scaffoldState.currentState.hideCurrentSnackBar();

      showDialog(
          context: context,
          builder: (BuildContext context) => DialogTextOnly(
                description: 'No hp telah tersimpan',
                buttonText: "OK",
                onOkPressed: () async {
                  await Firestore.instance
                      .collection('users')
                      .document(widget.state.data['id'])
                      .updateData({
                    'phone_number':
                        Dictionary.inaCode + _phoneNumberController.text
                  });
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // To close the dialog
                  // To close the dialog
                },
              ));
      setState(() {
        print(
            'Inside _sendCodeToPhoneNumber: signInWithPhoneNumber auto succeeded: $user');
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      _scaffoldState.currentState.hideCurrentSnackBar();

      showDialog(
          context: context,
          builder: (BuildContext context) => DialogTextOnly(
                description: 'Nomor telepon salah silahkan cek kembali',
                buttonText: "OK",
                onOkPressed: () {
                  Navigator.of(context).pop(); // To close the dialog
                },
              ));
      setState(() {
        print(
            'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this.verificationID = verificationId;
      _scaffoldState.currentState.hideCurrentSnackBar();

      showDialog(
          context: context,
          builder: (BuildContext context) => DialogTextOnly(
                description: "Kode terkirim ke nomor " +
                    Dictionary.inaCode +
                    _phoneNumberController.text,
                buttonText: "OK",
                onOkPressed: () async {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Verification(
                              phoneNumber: _phoneNumberController.text,
                              uid: widget.state.data['id'],
                            )),
                  );
                },
              ));
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationID = verificationId;
      _scaffoldState.currentState.hideCurrentSnackBar();

      showDialog(
          context: context,
          builder: (BuildContext context) => DialogTextOnly(
                description: "Waktu habis silahkan coba lagi",
                buttonText: "OK",
                onOkPressed: () {
                  Navigator.of(context).pop(); // To close the dialog
                },
              ));
      print("time out");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: Dictionary.inaCode + _phoneNumberController.text,
        timeout: const Duration(seconds: 120),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }
}