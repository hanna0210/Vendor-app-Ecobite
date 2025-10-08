import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ImagePickerView extends StatefulWidget {
  const ImagePickerView({
    required this.image,
    required this.onPickPressed,
    required this.onRemovePressed,
    this.height,
    this.title,
    this.boxFit,
    Key? key,
  }) : super(key: key);

  final File? image;
  final Function onPickPressed;
  final Function onRemovePressed;
  final double? height;
  final String? title;
  final BoxFit? boxFit;

  @override
  State<ImagePickerView> createState() => _ImagePickerViewState();
}

class _ImagePickerViewState extends State<ImagePickerView> {
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        if (widget.title != null) "${widget.title}".text.medium.make(),
        VxBox(
          child: widget.image == null
              ? "Select Image".tr().text.makeCentered().p12()
              :

              //
              Stack(
                  children: [
                    Image.file(
                      fit: widget.boxFit ?? BoxFit.contain,
                      widget.image!,
                      width: double.infinity,
                      height: widget.height ?? (Vx.dp64 * 3),
                    ),

                    //
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        iconSize: 32,
                        icon: Icon(
                          FlutterIcons.close_box_mco,
                          // color: AppColor.primaryColor,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          widget.onRemovePressed();
                        },
                      ),
                    ),
                  ],
                ),
        )
            .color(context.theme.colorScheme.surface)
            .border(color: context.theme.highlightColor)
            .withRounded(value: 2)
            .make()
            .wFull(context)
            .onInkTap(
              () => widget.onPickPressed(),
            ),
      ],
      spacing: 6,
    );
  }
}
