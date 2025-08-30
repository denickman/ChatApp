import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  /*
    GlobalKey<FormState> создаёт ключ, с помощью которого можно получить состояние формы 
    (FormState) из любого места в этом виджете.
    Благодаря этому можно вызывать методы формы (validate(), save(), reset()) 
    вне виджета Form (например, в методе _submit).
  */

  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';

  void _submit() async {
    print(">> SUBMIT");
    /*
      currentState возвращает объект FormState, который содержит состояние всех полей внутри формы.
      Метод validate() проходит по всем FormField (в нашем случае TextFormField) внутри этой формы и 
      вызывает их validator.
      Если все validator возвращают null, значит данные валидны → validate() возвращает true.
      Если хотя бы один validator возвращает строку (сообщение об ошибке), validate() вернёт false и 
      покажет ошибки под соответствующими полями.
    */
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      print(">> Form is not valid");
      return;
    }
    _form.currentState!.save();

    try {
      if (_isLogin) {
        final userCrendetials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        final userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      }
    } on FirebaseAuthException catch (error) {
      // on ExceptionType catch — Dart позволяет ловить ошибки определённого типа (гибко и удобно).
      // будет вызвано только если ошибка именно FirebaseAuthException
      if (error.code == 'email-already-in-use') {
        // ...
      }
      // ScaffoldMessenger - менеджер для показа временных сообщений (SnackBar) внутри текущего Scaffold.
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message ?? 'Auth failed.')
      ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),

              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              // onSaved вызывается только при вызове _form.currentState!.save().
                              _enteredEmail = value!;
                            },
                          ),

                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              // onSaved вызывается только при вызове _form.currentState!.save().
                              _enteredPassword = value!;
                            },
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                            ),
                            child: Text(_isLogin ? 'Login' : 'Sign up'),
                          ),

                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'Create an account'
                                  : 'I already have an account',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
