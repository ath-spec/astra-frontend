import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/asset_connection_provider.dart';

class BanksLinkingProgressScreen extends ConsumerWidget {
  const BanksLinkingProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AssetConnectionState>(assetConnectionProvider, (previous, next) {
      if (next.step == AssetConnectionStep.banksLinking) {
        context.pushReplacement('/banks-linking');
      }
    });

    return const Scaffold(
      backgroundColor: Color(0xFF0B0F19),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                    strokeWidth: 4,
                  ),
                ),
                SizedBox(height: 36),
                Text(
                  'Linking all your accounts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Please be patient this might take a while',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
