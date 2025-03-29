import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackgroundTexture extends StatelessWidget {
  const BackgroundTexture({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).colorScheme.primary,
        ),
        Opacity(
          opacity: 1.0,
          child: SvgPicture.asset(
            'assets/svg/group-68150.svg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
        ),
        Opacity(
          opacity: 0.7,
          child: SvgPicture.asset(
            'assets/svg/group-68151.svg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
        ),
        Opacity(
          opacity: 0.5,
          child: SvgPicture.asset(
            'assets/svg/group-68152.svg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}

