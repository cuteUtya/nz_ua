import 'package:adobe_spectrum/Components/text_field.dart';
import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adobe_spectrum/Components/button.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:nz_ua/nzsiteapi/types.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    Key? key,
    required this.state,
    required this.api,
  }) : super(key: key);
  final NeedLoginState state;
  final NzApi api;
  @override
  State<StatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String username = '';
  String password = '';

  bool pending = false;
  bool? success;

  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);
    return Container(
      padding: design.layout.spacing600.horizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Padding(
            padding: design.layout.spacing500.bottom,
            child: Text.rich(
              TextSpan(
                children: [
                  design.typography.text(
                    'Sign in ($success)',
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
              onChange: (s) => username = s,
            ),
          ),
          Padding(
            padding: design.layout.spacing75.bottom,
            child: AdobeTextField(
              label: 'Password (required)',
              onChange: (s) => password = s,
              inputType: InputFieldType.password,
            ),
          ),
          Padding(
            padding: design.layout.spacing300.bottom,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: design.typography.fontSize50.value,
                      color: design.colors.gray.shade700,
                    ),
                  ),
                  onTap: () => widget.api.forgotPassword(),
                ),
              ],
            ),
          ),
          //todo: load state after click
          AdobeButton(
            label: 'Login (pending = $pending)',
            isPending: pending,
            onClick: () async {
              setState(() => pending = true);
              var r = await widget.api.login(
                username,
                password,
              );
              setState(() {
                pending = false;
                success = r;
              });
            },
          ),
          const Spacer(),
          //todo alerts support
          if (widget.state.alerts.isNotEmpty)
            Text(
                '${widget.state.alerts[0].text} (type = ${widget.state.alerts[0].type})'),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
        ],
      ),
    );
  }
}
