import 'package:flutter/material.dart';

class CustomDropdownItem extends StatefulWidget {
  final int index;
  final BorderRadius? borderRadius;
  final String value;
  final Color? colorText;
  final Color? colorHover;
  final String? image;
  final bool? showImage;
  final EdgeInsetsGeometry? padding;

  const CustomDropdownItem(
      {Key? key,
        required this.index,
        this.borderRadius,
        required this.value,
        this.colorHover,
        this.padding,
        this.showImage,
        this.image,
        this.colorText})
      : super(key: key);

  @override
  State<CustomDropdownItem> createState() => _CustomDropdownItemState();
}

class _CustomDropdownItemState extends State<CustomDropdownItem> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          isHover = true;
        });
      },
      onExit: (event) {
        setState(() {
          isHover = false;
        });
      },
      child: Container(
          padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 15),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter stateSetter) {
                        return Text(
                          widget.value,
                          overflow: TextOverflow.clip,
                          style:
                          widget.colorText == null || widget.colorHover == null
                              ? TextStyle(
                              color: isHover
                                  ? const Color(0xff2F61DB)
                                  : const Color(0xff556998),
                              fontWeight: FontWeight.w500,
                              fontSize: 16)
                              : TextStyle(
                              color: isHover
                                  ? widget.colorHover
                                  : widget.colorText,
                              fontWeight: FontWeight.w500,
                              fontSize: 16),
                        );
                      }),
                ),
                widget.image != null
                    ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Visibility(
                      visible: widget.showImage ?? true,
                      child: Image.asset(
                        widget.image! ,
                        width: 32.0,
                        package: 'intl_phone_number_input',
                        errorBuilder: (context, error, stackTrace) {
                          return SizedBox.shrink();
                        },
                      ),
                ))
                    : Container(),
              ],
            ),
          )),
    );
  }
}
