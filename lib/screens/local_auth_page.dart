import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:passwordmanager/screens/home_page.dart';
import 'package:passwordmanager/services/local_auth_service.dart';

class LocalAuthPage extends StatefulWidget {
  const LocalAuthPage({Key? key}) : super(key: key);

  @override
  _LocalAuthPageState createState() => _LocalAuthPageState();
}

class _LocalAuthPageState extends State<LocalAuthPage> {
  bool isVerified = false;
  bool isLightTheme(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 70,
              ),
              Column(
                children: [
                  Text(
                    'Authentication',
                    style: Theme.of(context).primaryTextTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "To access this app, please scan your biometric.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).primaryTextTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  isVerified
                      ? Lottie.asset(
                    isLightTheme(context)
                        ? 'assets/animation/lightThemeTick.json'
                        : 'assets/animation/darkThemeTick.json',
                    height: 120,
                    width: 200,
                    onLoaded: (composition) {
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      }
                      );
                    },
                  )
                      : IconButton(
                    onPressed: () async {
                      // Simulate fingerprint authentication
                      await LocalAuth.authenticate().then((verified) {
                        setState(() {
                          isVerified = verified;
                        });
                      });
                    },
                    icon: Icon(
                      Icons.fingerprint_rounded,
                      color: Theme.of(context).primaryTextTheme.headlineMedium?.color,
                      size: 80,
                    ),
                  ),
                  Text(
                    "Click",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).primaryTextTheme.bodySmall,
                  ),
                ],
              ),
              SizedBox.fromSize(),
            ],
          ),
        ),
      ),
    );
  }
}
