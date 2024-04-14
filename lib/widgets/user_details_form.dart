import 'package:ciconia_tracker/service/data_service.dart';
import 'package:flutter/material.dart';

class UserDetailsForm extends StatefulWidget {
  const UserDetailsForm({super.key});

  @override
  State<UserDetailsForm> createState() => _UserDetailsFormState();
}

/// Form to add Full name, email, and phone number and save it in shared preferences

class _UserDetailsFormState extends State<UserDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    _nameController.text = DataService().getNamePreference() ?? '';
    _emailController.text = DataService().getEmailPreference() ?? '';
    _phoneController.text = DataService().getPhonePreference() ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('user_details_form'),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              // const Text('User Details', style: TextStyle(fontSize: 20)),
              // const SizedBox(
              //   height: 20,
              // ),
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Unesite ime i prezime';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border:  const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelText: 'Ime i prezime',
                  suffixIcon: InkWell(
                    child: const Icon(Icons.clear),
                    onTap: () {
                      _nameController.clear();
                    },
                  ),
                ),

              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _emailController,
                validator: (value) {
                  /// if email is not null and not valid return error message
                  /// email check pattern using regex
                  final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (value != null && !emailPattern.hasMatch(value)) {
                    return 'Unesite validan email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border:  const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelText: 'Email',
                  suffixIcon: InkWell(
                    child: const Icon(Icons.clear),
                    onTap: () {
                      _emailController.clear();
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  border:  const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelText: 'Phone Number',
                  suffixIcon: InkWell(
                    child: const Icon(Icons.clear),
                    onTap: () {
                      _phoneController.clear();
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      /// validate form and save to shared preferences
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      DataService().setNamePreference(_nameController.text.trim());
                      DataService().setEmailPreference(_emailController.text.trim());
                      DataService().setPhonePreference(_phoneController.text.trim());
                      Navigator.pop(context);
                    },
                    child: const Text('Sačuvaj'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Odustani')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
