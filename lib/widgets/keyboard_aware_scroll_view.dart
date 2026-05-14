import 'package:flutter/material.dart';

/// Klavye açıldığında otomatik olarak scroll eden ve input alanlarını
/// klavyenin üstünde tutan widget
class KeyboardAwareScrollView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const KeyboardAwareScrollView({
    super.key,
    required this.child,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      padding:
          padding ??
          EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            // Klavye açıkken ekstra padding ekle
            bottom: bottomInset > 0 ? bottomInset + 16 : 16,
          ),
      child: child,
    );
  }
}

/// Form sayfaları için özel Scaffold wrapper
/// Klavye açıldığında otomatik olarak içeriği yukarı kaydırır
class KeyboardAwareScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  const KeyboardAwareScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.drawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      body: GestureDetector(
        // Klavye dışına tıklandığında klavyeyi kapat
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: body,
      ),
    );
  }
}
