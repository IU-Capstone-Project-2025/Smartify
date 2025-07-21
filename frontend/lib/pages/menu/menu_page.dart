import 'package:flutter/material.dart';
import 'package:smartify/l10n/app_localizations.dart';

class MenuPage  extends StatelessWidget{
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.menu,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Container(
        child: Text(AppLocalizations.of(context)!.body),
      ),
    );
  }
}