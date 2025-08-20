import 'package:flutter/widgets.dart';
import 'package:tajalwaqaracademy/shared/themes/app_theme.dart';
import 'package:tajalwaqaracademy/core/models/gender.dart';

class Avatar extends StatelessWidget {
  final Gender gender;
  final String pic;
  final Size size;
  const Avatar({
    super.key,
    this.gender = Gender.other,
    this.pic = "assets/images/logo2.png",
    this.size = const Size(55, 55),
  });

  @override
  Widget build(BuildContext context) {
    return pic == 'assets/images/logo2.png' && gender == Gender.other
        ? Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size.height / 4),
              image: DecorationImage(
                image: AssetImage(pic),
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  AppColors.mediumDark54,
                  BlendMode.colorBurn,
                ),
              ),
            ),
          )
        : Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: AssetImage(
                  gender == Gender.male
                      ? "assets/images/u1.png"
                      : "assets/images/u2.png",
                ),
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  AppColors.mediumDark54,
                  BlendMode.colorBurn,
                ),
              ),
            ),
          );
  }
}
