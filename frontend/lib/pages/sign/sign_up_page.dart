import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:smartify/pages/authorization/authorization_page.dart';
import 'package:smartify/pages/welcome/welcome_page.dart';
import 'package:smartify/pages/api_server/api_server.dart';
import 'package:smartify/l10n/app_localizations.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int currentStep = 0;
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;

  bool get hasMinLength => passwordController.text.length >= 8;
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(passwordController.text);
  bool get hasSymbol => RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(passwordController.text);

  double get passwordStrength {
    int metCriteria = [hasMinLength, hasNumber, hasSymbol].where((c) => c).length;
    return metCriteria / 3;
  }

  Color get strengthColor {
    if (passwordStrength < 0.34) return const Color.fromRGBO(214, 44, 1, 1);
    if (passwordStrength < 0.67) return const Color.fromRGBO(250, 174, 22, 1);
    return const Color.fromRGBO(73, 130, 0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        foregroundColor: null,
        title: Text(
          AppLocalizations.of(context)!.createAccount,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF54D0C0) : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: [
            _buildEmailStep(),
            _buildVerifyStep(),
            _buildPasswordStep(),
            _buildSuccessStep(),
          ][currentStep],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int activeStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 24,
          height: 4,
          decoration: BoxDecoration(
            color: index <= activeStep ? Colors.tealAccent[100] : Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.enterYourEmail,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildProgressIndicator(0),
            ],
          ),
        ),
        SizedBox(height: 40),
        Text(AppLocalizations.of(context)!.email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.exampleEmail,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final success = await ApiService.registration_emailValidation(
                emailController.text
              );
              if (success) {
                setState(() => currentStep = 1);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.emailError)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF54D0C0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.createAccount, style: const TextStyle(color: Colors.white)),
          ),
        ),
        const Spacer(),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text.rich(
              TextSpan(
                text: AppLocalizations.of(context)!.termsAndPrivacy,
                style: const TextStyle(fontSize: 12),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context)!.confirmYourEmail,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepIndicator(active: true),
            SizedBox(width: 4),
            _buildStepIndicator(active: true),
            SizedBox(width: 4),
            _buildStepIndicator(active: false),
          ],
        ),
        SizedBox(height: 30),
        Text(
          "${AppLocalizations.of(context)!.weSentCodeTo}\n${emailController.text}, ${AppLocalizations.of(context)!.enterItBelow}",
          style: const TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.code,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                PinCodeTextField(
                  length: 5,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10),
                    fieldHeight: 48,
                    fieldWidth: 65.4,
                    activeColor: Colors.grey.shade300,
                    selectedColor: Colors.teal,
                    inactiveColor: Colors.grey.shade300,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: false,
                  controller: codeController,
                  onChanged: (value) {},
                  appContext: context,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF54D0C0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final success = await ApiService.registration_codeValidation(
                emailController.text,
                codeController.text,
              );
              if (success) {
                setState(() => currentStep = 2);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Неверный код или ошибка соединения')),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.confirmEmail, style: const TextStyle(color: Colors.white)),
          ),
        ),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignUpPage(),
              ),
            );
          },
          child: Text.rich(
            TextSpan(
              text: AppLocalizations.of(context)!.didNotReceiveEmail + ' ',
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)!.sendToAnotherAddress,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text.rich(
              TextSpan(
                text: AppLocalizations.of(context)!.termsAndPrivacy,
                style: const TextStyle(fontSize: 12),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator({required bool active}) {
    return Container(
      width: 20,
      height: 4,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFADE2DF) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

Widget _buildPasswordStep() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 10),
      Center(
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.chooseNewPassword,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildProgressIndicator(2),
          ],
        ),
      ),
      SizedBox(height: 30),
      Text(AppLocalizations.of(context)!.password, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      SizedBox(height: 8),
      TextField(
        controller: passwordController,
        obscureText: !isPasswordVisible,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
      SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LinearProgressIndicator(
          value: passwordStrength,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          minHeight: 8,
        ),
      ),
      SizedBox(height: 16),
      _buildCriteria(AppLocalizations.of(context)!.min8Characters, hasMinLength),
      _buildCriteria(AppLocalizations.of(context)!.atLeastOneDigit, hasNumber),
      _buildCriteria(AppLocalizations.of(context)!.atLeastOneSpecialCharacter, hasSymbol),
      const Spacer(),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: passwordStrength == 1.0
          ? () async {
              final success = await ApiService.registration_password(emailController.text, passwordController.text);
              if (success) {
                setState(() => currentStep = 3); 
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(AppLocalizations.of(context)!.registrationError)),
                );
              }
            }
          : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: passwordStrength == 1.0 ? const Color(0xFF54D0C0) : const Color(0xFFB2DFDB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: const Color(0xFFB2DFDB),
          ),
          child: Text(AppLocalizations.of(context)!.continueText),
        ),
      ),
      const Spacer(),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text.rich(
              TextSpan(
                text: AppLocalizations.of(context)!.termsAndPrivacy,
                style: const TextStyle(fontSize: 12),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
    ],
  );
}

  Widget _buildCriteria(String label, bool met) {
    return Row(
      children: [
        Icon(met ? Icons.check_circle_rounded : Icons.radio_button_unchecked, color: met ? const Color.fromRGBO(73, 130, 0, 1) : Colors.grey),
        SizedBox(width: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: met ? Colors.black : Colors.grey)),
      ],
    );
  }

  Widget _buildSuccessStep() {
  return Column(
    children: [
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check, size: 40, color: Color.fromRGBO(21, 203, 189, 1)),
            SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.successRegistration,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.exploreEducationWithOneClick,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthorizationPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF54D0C0),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppLocalizations.of(context)!.login, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Text.rich(
          TextSpan(
            text: AppLocalizations.of(context)!.termsAndPrivacy,
            style: const TextStyle(fontSize: 12),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}
@override
void dispose() {
  emailController.dispose();
  codeController.dispose();
  passwordController.dispose();
  super.dispose();
}
}