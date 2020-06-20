import 'package:flutter/material.dart';
import 'package:ngo_app/authentication.dart';
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

  DialogBox dialogBox=DialogBox();

  final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _email = "";
  String _password = "";

  List<Widget> createInputs() {
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

  void validateAndSubmit() async{
    if(validateAndSave()){
      try{
        if(_formType==FormType.login){
          String userId= await widget.auth.SignIn(_email, _password);
          //dialogBox.information(context, "Congratulations", "Logged In Successfully");
          print("Login userId= " +userId);
        }
        else{
          String userId= await widget.auth.SignUp(_email, _password);
          //dialogBox.information(context, "Congratulations", "Your account has been Created Successfully");
          print("Register userId= " +userId);
        }
        widget.onSignedIn();
      }
      catch(e){
        dialogBox.information(context, "Error", e.toString());
        print("Error = "+e.toString());
      }
    }
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
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: createInputs() + createButtons(),
          ),
        ),
      ),
    );
  }
}
