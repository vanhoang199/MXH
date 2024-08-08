import 'package:flutter/material.dart';
import 'package:instagram_clone_1/providers/user_provider.dart';
import 'package:instagram_clone_1/resources/firestore_methods.dart';
import 'package:provider/provider.dart';

// Create a Form widget.
class FormUpdateProfile extends StatefulWidget {
  const FormUpdateProfile({super.key});

  @override
  FormUpdateProfileState createState() {
    return FormUpdateProfileState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class FormUpdateProfileState extends State<FormUpdateProfile> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _bio = TextEditingController();

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _username.text = Provider.of<UserProvider>(context).getUser.username;
    _email.text = Provider.of<UserProvider>(context).getUser.email;
    _bio.text = Provider.of<UserProvider>(context).getUser.bio;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _username.dispose();
    _email.dispose();
    _bio.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cập nhật hồ sơ người dùng'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    label: Text(
                      'Tên người dùng',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontStyle: FontStyle.italic),
                    ),
                    icon: Icon(Icons.person)),
                controller: _username,
                // initialValue:
                //     Provider.of<UserProvider>(context).getUser.username,
                style: const TextStyle(fontSize: 22),

                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Không được bỏ trống trường họ tên';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                    label: Text(
                      'Email',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontStyle: FontStyle.italic),
                    ),
                    icon: Icon(Icons.email)),
                controller: _email,
                style: const TextStyle(
                  fontSize: 22,
                ),
                //initialValue: Provider.of<UserProvider>(context).getUser.email,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  RegExp emailRegex = RegExp(r'^[a-zA-Z0-9_.+-]+@gmail.com$');
                  if (value == null || value.isEmpty) {
                    return 'Không được bỏ trống email';
                  } else if (!emailRegex.hasMatch(value)) {
                    return 'Nhập đúng định dạnh email\nVD: abc@gmail.com';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                    label: Text(
                      'Nghề nghiệp',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontStyle: FontStyle.italic),
                    ),
                    icon: Icon(Icons.badge)),
                controller: _bio,
                style: const TextStyle(fontSize: 22),
                //initialValue: Provider.of<UserProvider>(context).getUser.bio,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Không được bỏ trống nghề nghiệp';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Đang trong quá trình cập nhật')),
                      );
                      await FirestoreMethods().updateProfile(
                          _username.text, _email.text, _bio.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cập nhật thành công')),
                      );
                    }
                  },
                  child: const Center(child: Text('Cập nhật ')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
