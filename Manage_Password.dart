import 'package:flutter/material.dart';
import 'package:nehhdc_app/Model_Screen/APIs_Screen.dart';
import 'package:nehhdc_app/Setting_Screen/Setting_Screen.dart';

class Manage_Password extends StatefulWidget {
  final String? password;
  final int minLength;
  final int minDigits;
  final int minSpecialChars;

  Manage_Password({
    this.password,
    this.minLength = 8,
    this.minDigits = 1,
    this.minSpecialChars = 1,
  });

  @override
  _Manage_PasswordState createState() => _Manage_PasswordState();
}

class _Manage_PasswordState extends State<Manage_Password> {
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String errorMessage = '';
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool currentvalidate = false;
  bool newvalidate = false;
  bool confirmvalidate = false;

  void _togglePasswordVisibility(bool isCurrentPassword) {
    setState(() {
      if (isCurrentPassword) {
        _obscureCurrentPassword = !_obscureCurrentPassword;
      } else {
        _obscureNewPassword = !_obscureNewPassword;
      }
    });
  }

  void _validatePasswords() {
    setState(() {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        errorMessage = "Passwords do not match";
      } else {
        errorMessage = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(ColorVal),
        title: Text(
          "Manage Password",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPasswordField(
                label: "Current Password",
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                toggleVisibility: () => _togglePasswordVisibility(true),
              ),
              SizedBox(height: 10),
              _buildPasswordField(
                label: "New Password",
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                toggleVisibility: () => _togglePasswordVisibility(false),
              ),
              SizedBox(height: 10),
              _buildPasswordField(
                label: "Confirm Password",
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                toggleVisibility: () => setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                }),
                onChanged: _validatePasswords,
              ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    changepassword();
                  },
                  child: Text(
                    "Reset Password",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    VoidCallback? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 2),
            Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        SizedBox(height: 5),
        Container(
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              width: 0,
              color: Colors.grey,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: toggleVisibility,
                ),
              ),
              onChanged: onChanged != null ? (_) => onChanged() : null,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  void changepassword() async {
    setState(() {
      currentvalidate = _currentPasswordController.text.isEmpty;
      newvalidate = _newPasswordController.text.isEmpty;
      confirmvalidate = _confirmPasswordController.text.isEmpty;

      if (currentvalidate || newvalidate || confirmvalidate) {
        errorMessage = 'Please fill all fields';
        return;
      } else if (_newPasswordController.text !=
          _confirmPasswordController.text) {
        errorMessage = 'Passwords do not match';
      } else if (_newPasswordController.text.length < widget.minLength ||
          _newPasswordController.text.replaceAll(RegExp(r'[0-9]'), '').length <
              widget.minDigits ||
          _newPasswordController.text
                  .replaceAll(RegExp(r'[!@#$%^&*(),.?":{}|<>]'), '')
                  .length <
              widget.minSpecialChars) {
        errorMessage = 'Password does not meet requirements';
      } else {
        plaesewaitmassage(context);
        ManagePassword managePassword = ManagePassword();
        managePassword
            .managePasswordApi(
          context,
          _currentPasswordController.text,
          _newPasswordController.text,
          _confirmPasswordController.text,
        )
            .then((_) {
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          errorMessage = '';
        }).catchError((error) {
          errorMessage = 'Failed to change password: $error';
        });
      }
    });
  }
}
