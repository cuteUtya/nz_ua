import 'package:adobe_spectrum/Components/text_field.dart';
import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adobe_spectrum/Components/button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);
    return Container(
      color: design.colors.gray.shade100,
      padding: design.layout.spacing600.horizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: design.layout.spacing500.bottom,
            child: Text.rich(
              TextSpan(
                children: [
                  design.typography.text(
                    'Sign in',
                    size: design.typography.fontSize300.value,
                    semantic: TextSemantic.heading,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: design.layout.spacing400.bottom,
            child: AdobeTextField(
              label: 'Username (required)',
            ),
          ),
          Padding(
            padding: design.layout.spacing75.bottom,
            child: AdobeTextField(
              label: 'Password (required)',
              inputType: InputFieldType.password,
            ),
          ),
          Padding(
            padding: design.layout.spacing300.bottom,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontFamily: 'Adobe Clean',
                    fontSize: design.typography.fontSize50.value,
                    color: design.colors.gray.shade700,
                  ),
                ),
              ],
            ),
          ),
          AdobeButton(
            label: 'Login',
          )
        ],
      ),
    );
  }
}
