import 'package:adobe_spectrum/Components/button.dart';
import 'package:adobe_spectrum/Components/text_field.dart';
import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:nz_ua/Components/localization.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:nz_ua/nzsiteapi/types.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    Key? key,
    required this.nzApi,
  }) : super(key: key);

  final NzApi nzApi;

  @override
  State<StatefulWidget> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String email = '';
  bool pending = false;

  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);

    return Container(
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
                    appLocalization.forgot_password,
                    size: design.typography.fontSize300.value,
                    semantic: TextSemantic.heading,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: design.layout.spacing300.bottom,
            child: AdobeTextField(
              label: appLocalization.email_required,
              onChange: (c) => email = c,
              inputType: InputFieldType.email,
            ),
          ),
          AdobeButton(
            label: appLocalization.send_code,
            isPending: pending,
            onClick: () {
              setState(() => pending = true);
              widget.nzApi.sendRecoverCode(email);
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          )
        ],
      ),
    );
  }
}
