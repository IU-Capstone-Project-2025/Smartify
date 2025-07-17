import 'package:flutter/material.dart';
import 'package:smartify/l10n/app_localizations.dart';

class MenuPage  extends StatelessWidget{
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.menu, style: const TextStyle(
          color: Color.fromARGB(255, 168, 222, 170),
          fontSize: 50 ,
          fontWeight: FontWeight.w500
        ),),
      ),
      body: Container(
        child: Text(AppLocalizations.of(context)!.body),
      ),
    );
  }
}