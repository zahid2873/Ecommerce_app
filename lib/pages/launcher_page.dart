import 'package:ecommerce_app/pages/dashboard_page.dart';
import 'package:flutter/material.dart';

import '../auth/authservice.dart';
import 'login_page.dart';

class LauncherPage extends StatelessWidget {
  static const String routeName = '/launcher';
  const LauncherPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, (){
      if(AuthService.currentUser != null){
        Navigator.pushReplacementNamed(context, DashboardPage.routeName);
      }else{
        Navigator.pushReplacementNamed(context, LoginPage.routeName);
      }
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(),),
    );
  }
}
