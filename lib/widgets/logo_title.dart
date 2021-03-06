import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:report_child/styles/text_styles.dart';

class LogoTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SvgPicture.asset("assets/images/children_jumping.svg",
              semanticsLabel: 'Children Jumping'),
        ),
        const SizedBox(height: 20),
        Text(
          "Salvavidas",
          style: Styles.appBarTitleStyle
              .copyWith(fontSize: 40.0, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
