import 'package:agromapping/view_models/contatos_view_model.dart';
import 'package:agromapping/ui/widgets/product_form_view_model.dart';
import 'package:agromapping/view_models/busca_view_model.dart';
import 'package:agromapping/view_models/editar_perfil_view_model.dart';
import 'package:agromapping/view_models/estoque_view_model.dart';
import 'package:agromapping/view_models/gerenciar_feiras_view_model.dart';
import 'package:agromapping/view_models/pedidos_view_model.dart';
import 'package:agromapping/view_models/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'ui/screens/login_screen.dart';
import 'utils/colors.dart';
import 'view_models/cart_view_model.dart';
import 'view_models/feiras_view_model.dart';
import 'view_models/home_view_model.dart';
import 'view_models/login_view_model.dart';
import 'view_models/my_products_view_model.dart';
import 'view_models/register_view_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Key _key = UniqueKey();

  void restart() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LoginViewModel()),
          ChangeNotifierProvider(create: (_) => RegisterViewModel()),
          ChangeNotifierProvider(create: (_) => HomeViewModel()),
          ChangeNotifierProvider(create: (_) => FeirasViewModel()),
          ChangeNotifierProvider(create: (_) => CartViewModel()),
          ChangeNotifierProvider(create: (_) => ProfileViewModel()),
          ChangeNotifierProvider(create: (_) => ProductFormViewModel()),
          ChangeNotifierProvider(create: (_) => MyProductsViewModel()),
          ChangeNotifierProvider(create: (_) => ContatosViewModel()),
          ChangeNotifierProvider(create: (_) => PedidosViewModel()),
          ChangeNotifierProvider(create: (_) => BuscaViewModel()),
          ChangeNotifierProvider(create: (_) => EditarPerfilViewModel()),
          ChangeNotifierProvider(create: (_) => EstoqueViewModel()),
          ChangeNotifierProvider(create: (_) => GerenciarFeirasViewModel()),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'AgroMapping',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: backgroundColor,
            primaryColor: primaryColor,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              labelStyle: const TextStyle(color: subtitleColor),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: textColor,
            ),
          ),
          home: const LoginScreen(),
        ),
      ),
    );
  }
}
