import 'package:flutter/material.dart';

class NameAppDropDown<T> extends StatefulWidget {
  final Widget? child;
  final void Function(T, int)? onChange;
  final Function(T, int)? onClicked;
  final Color? backgroundColor;
  final List<SSDropdownItem<T>>? items;
  final SSDropdownStyle dropdownStyle;
  final SSDropdownButtonStyle dropdownButtonStyle;
  final Icon? icon;
  final bool hideIcon;
  final bool leadingIcon;
  final Color? colorIcon;
  final Color? colorBorderSide;
  final bool? enable;

  const NameAppDropDown({
    Key? key,
    this.backgroundColor,
    this.onClicked,
    this.hideIcon = true,
    @required this.child,
    @required this.items,
    this.dropdownStyle = const SSDropdownStyle(),
    this.dropdownButtonStyle = const SSDropdownButtonStyle(),
    this.icon,
    this.leadingIcon = false,
    this.onChange,
    this.colorIcon,
    this.colorBorderSide,
    this.enable = true,
  }) : super(key: key);

  @override
  NameAppDropDownState createState() => NameAppDropDownState();
}

class NameAppDropDownState<T> extends State<NameAppDropDown<T>>
    with TickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  AnimationController? _animationController;
  Animation<double>? _expandAnimation;
  Animation<double>? _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _expandAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    var style = widget.dropdownButtonStyle;
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        width: style.width,
        height: style.height,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: OutlinedButton(
          clipBehavior: Clip.none,
          style: OutlinedButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            side: BorderSide(
              width: 1,
              color: (_isOpen ? Color(0xffD1DFFF) : widget.colorBorderSide) ??
                  Colors.white,
              style: BorderStyle.solid,
            ),
            backgroundColor: widget.backgroundColor ?? Colors.grey,
          ),
          onPressed: widget.enable! ? _toggleDropdown : null,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 44,
            child: Row(
              mainAxisAlignment:
                  style.mainAxisAlignment ?? MainAxisAlignment.spaceBetween,
              textDirection:
                  widget.leadingIcon ? TextDirection.rtl : TextDirection.ltr,
              children: [
                widget.child!,
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Visibility(
                    visible: !widget.hideIcon,
                    child: RotationTransition(
                      turns: _rotateAnimation!,
                      child: widget.icon ??
                          Icon(
                            Icons.arrow_drop_down_sharp,
                            color: widget.colorIcon ?? const Color(0xff556998),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    // find the size and position of the current widget
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    var size = renderBox!.size;

    var offset = renderBox.localToGlobal(Offset.zero);
    var topOffset = offset.dy + size.height + 5;
    return OverlayEntry(
      // full screen GestureDetector to register when a
      // user has clicked away from the dropdown
      builder: (context) => GestureDetector(
        onTap: () => _toggleDropdown(close: true),
        behavior: HitTestBehavior.translucent,
        // full screen container to register taps anywhere and close drop down
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: topOffset,
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.99,
                child: Padding(
                  padding: const EdgeInsets.only(right: 28),
                  child: CompositedTransformFollower(
                    offset: widget.dropdownStyle.offset ??
                        Offset(0, size.height + 5),
                    link: _layerLink,
                    showWhenUnlinked: false,
                    child: Material(
                      elevation: widget.dropdownStyle.elevation ?? 0,
                      borderRadius: widget.dropdownStyle.borderRadius ??
                          BorderRadius.zero,
                      color: widget.dropdownStyle.color,
                      child: ConstrainedBox(
                        constraints: widget.dropdownStyle.constraints ??
                            BoxConstraints(
                              maxHeight: (MediaQuery.of(context).size.height) -
                                  topOffset -
                                  15,
                            ),
                        child: ListView(
                          padding:
                              widget.dropdownStyle.padding ?? EdgeInsets.zero,
                          shrinkWrap: true,
                          children: widget.items!.asMap().entries.map((item) {
                            return InkWell(
                              excludeFromSemantics: true,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              onHover: (hover) {
                                if (item.value.onHover != null) {
                                  item.value.onHover!(hover);
                                }
                              },
                              onTap: widget.onClicked != null
                                  ? widget.onClicked!(
                                      item.value.value as T, item.key)
                                  : () {
                                      widget.onChange!(
                                          item.value.value as T, item.key);
                                      _toggleDropdown();
                                    },
                              child: Column(
                                children: [
                                  item.value,
                                  Divider(
                                    color: Colors.grey,
                                    thickness: 0.5,
                                    height: 0.5,
                                    indent: 8,
                                    endIndent: 8,
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDropdown({bool close = false}) async {
    if (_isOpen || close) {
      await _animationController!.reverse();
      _overlayEntry!.remove();
      setState(() {
        _isOpen = false;
      });
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context)!.insert(_overlayEntry!);
      setState(() => _isOpen = true);
      _animationController!.forward();
    }
  }
}

class SSDropdownItem<T> extends StatelessWidget {
  final T? value;
  final Function? onHover;
  final Widget? child;

  const SSDropdownItem({Key? key, this.value, this.onHover, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child!;
  }
}

class SSDropdownButtonStyle {
  final MainAxisAlignment? mainAxisAlignment;
  final ShapeBorder? shape;
  final double? elevation;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;
  final double? width;
  final double? height;
  final Color? primaryColor;

  const SSDropdownButtonStyle({
    this.mainAxisAlignment,
    this.backgroundColor,
    this.primaryColor,
    this.constraints,
    this.height,
    this.width,
    this.elevation,
    this.padding,
    this.shape,
  });
}

class SSDropdownStyle {
  final BorderRadius? borderRadius;
  final double? elevation;
  final Color? color;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;

  /// position of the top left of the dropdown relative to the top left of the button
  final Offset? offset;

  ///button width must be set for this to take effect
  final double? width;

  const SSDropdownStyle({
    this.constraints,
    this.offset,
    this.width,
    this.elevation,
    this.color,
    this.padding,
    this.borderRadius,
  });
}
