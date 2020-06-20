import 'package:flutter/material.dart';
import 'package:ngo_app/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './dialogBox.dart';

class LoginRegisterPage extends StatefulWidget {
  LoginRegisterPage({this.auth, this.onSignedIn});
  final AuthImplementation auth;
  final VoidCallback onSignedIn;

  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

enum FormType { login, register }

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  DialogBox dialogBox = DialogBox();

  final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _email = "";
  String _password = "";
  String _name="";
  String _address="";
  String _type='';
  String _apiKey='';
  String uid;
  final FirebaseAuth auth=FirebaseAuth.instance;
  Future<String> inputData() async {
    final FirebaseUser user = await auth.currentUser();
    return(user.uid);
    // here you write the codes to input the data into firestore
  }

  List<Widget> createInputs() {
    if (_formType == FormType.login) {
      return [
        SizedBox(
          height: 10.0,
        ),
        logo(),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'E-mail'),
          validator: (value) {
            return value.isEmpty ? 'E-mail is required' : null;
          },
          onSaved: (value) {
            return _email = value;
          },
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: (value) {
            return value.isEmpty ? 'Password is required' : null;
          },
          onSaved: (value) {
            return _password = value;
          },
        ),
        SizedBox(height: 10)
      ];
    } else {
      return [
        SizedBox(
          height: 10.0,
        ),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'E-mail'),
          validator: (value) {
            return value.isEmpty ? 'E-mail is required' : null;
          },
          onSaved: (value) {
            return _email = value;
          },
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: (value) {
            return value.isEmpty ? 'Password is required' : null;
          },
          onSaved: (value) {
            return _password = value;
          },
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(labelText: 'Name of NGO'),
          validator: (value) {
            return value.isEmpty ? 'Name of NGO is required' : null;
          },
          onSaved: (value) {
            return _name = value;
          },
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(labelText: 'Address, City, State'),
          validator: (value) {
            return value.isEmpty ? 'Address is required' : null;
          },
          onSaved: (value) {
            return _address = value;
          },
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(labelText: 'Type of NGO'),
          validator: (value) {
            return value.isEmpty ? 'NGO type is required' : null;
          },
          onSaved: (value) {
            return _type = value;
          },
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(labelText: 'Razorpay Account KEY'),
          validator: (value) {
            return value.isEmpty ? 'API Key is required' : null;
          },
          onSaved: (value) {
            return _apiKey = value;
          },
        ),
        SizedBox(height: 10),
        Text(
          'Create an Account on RazorPay and Enter API key Recieved',
          style: TextStyle(color: Colors.pink,fontSize:12),
        ),
        SizedBox(height: 10),
      ];
    }
  }

  List<Widget> createButtons() {
    if (_formType == FormType.login) {
      return [
        RaisedButton(
            onPressed: validateAndSubmit,
            child: Text(
              "Login",
              style: TextStyle(fontSize: 20),
            ),
            textColor: Colors.white,
            color: Colors.pink),
        FlatButton(
          onPressed: moveToRegister,
          child: Text(
            "Not have an Account? Create Account",
            style: TextStyle(fontSize: 13),
          ),
          textColor: Colors.red,
        ),
      ];
    } else {
      return [
        RaisedButton(
            onPressed: validateAndSubmit,
            child: Text(
              "Create Account",
              style: TextStyle(fontSize: 20),
            ),
            textColor: Colors.white,
            color: Colors.pink),
        FlatButton(
          onPressed: moveToLogin,
          child: Text(
            "Already have an account? Login",
            style: TextStyle(fontSize: 13),
          ),
          textColor: Colors.red,
        ),
      ];
    }
  }

  Widget logo() {
    return Hero(
      tag: 'Hero',
      child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 110,
          child: Icon(Icons.supervised_user_circle)),
    );
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          String userId = await widget.auth.SignIn(_email, _password);
          print("Login userId= " + userId);
        } else {
          String userId = await widget.auth.SignUp(_email, _password);
          print("Register userId= " + userId);
          uid=await inputData();
          saveToDatabase(uid,_email,_name,_address,_type,_apiKey);
        }
        widget.onSignedIn();
      } catch (e) {
        dialogBox.information(context, "Error", e.toString());
        print("Error = " + e.toString());
      }
    }
  }
    void saveToDatabase(id,email,name,address,type,apiKey){
    //var dbTimeKey=DateTime.now();
    print("id");
    print(id);
    DatabaseReference ref=FirebaseDatabase.instance.reference();

    var data = {
      "id":id,
      "email":email,
      "name": name,
      "address": address,
      "type":type,
      "apiKey":apiKey,
    };

    ref.child("NGO").push().set(data);

  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NGO"),
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: Form(
          key: formKey,
          child: ListView(
            children: createInputs() + createButtons(),
          ),
        ),
      ),
    );
  }
}
