import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/custom_drop_down/common_drop_down_item.dart';
import 'package:intl_phone_number_input/src/custom_drop_down/common_dropdown_button.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/utils/test/test_helper.dart';
import 'package:intl_phone_number_input/src/widgets/countries_search_list_widget.dart';
import 'package:intl_phone_number_input/src/widgets/input_widget.dart';
import 'package:intl_phone_number_input/src/widgets/item.dart';

/// [SelectorButton]
class SelectorButton extends StatelessWidget {
  final List<Country> countries;
  final Country? country;
  final SelectorConfig selectorConfig;
  final TextStyle? selectorTextStyle;
  final InputDecoration? searchBoxDecoration;
  final bool autoFocusSearchField;
  final String? locale;
  final bool isEnabled;
  final bool isScrollControlled;
  final Color? iconEnabledColor;

  final ValueChanged<Country?> onCountryChanged;

  const SelectorButton({
    Key? key,
    required this.countries,
    required this.country,
    required this.selectorConfig,
    required this.selectorTextStyle,
    required this.searchBoxDecoration,
    required this.autoFocusSearchField,
    required this.locale,
    required this.onCountryChanged,
    required this.isEnabled,
    required this.isScrollControlled,
    this.iconEnabledColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return selectorConfig.selectorType == PhoneInputSelectorType.DROPDOWN
        ? countries.isNotEmpty && countries.length > 1
            ? _buildDropDown(context)
            : Item(
                country: country,
                showFlag: selectorConfig.showFlags,
                useEmoji: selectorConfig.useEmoji,
                leadingPadding: selectorConfig.leadingPadding,
                trailingSpace: selectorConfig.trailingSpace,
                textStyle: selectorTextStyle,
              )
        : MaterialButton(
            key: Key(TestHelper.DropdownButtonKeyValue),
            padding: EdgeInsets.zero,
            minWidth: 0,
            onPressed: countries.isNotEmpty && countries.length > 1 && isEnabled
                ? () async {
                    Country? selected;
                    if (selectorConfig.selectorType ==
                        PhoneInputSelectorType.BOTTOM_SHEET) {
                      selected = await showCountrySelectorBottomSheet(
                          context, countries);
                    } else {
                      selected =
                          await showCountrySelectorDialog(context, countries);
                    }

                    if (selected != null) {
                      onCountryChanged(selected);
                    }
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Item(
                country: country,
                showFlag: selectorConfig.showFlags,
                useEmoji: selectorConfig.useEmoji,
                leadingPadding: selectorConfig.leadingPadding,
                trailingSpace: selectorConfig.trailingSpace,
                textStyle: selectorTextStyle,
              ),
            ),
          );
  }

  Widget _buildDropDown(BuildContext context) {
    return NameAppDropDown<Country>(
      hideIcon: false,
      colorIcon: Colors.grey,
      backgroundColor: Colors.white,
      colorBorderSide: Color(0xffD1DFFF),
      leadingIcon: false,
      enable: true,
      icon: const Icon(
        Icons.arrow_drop_down,
        color: Color(0xff556998),
      ),
      dropdownStyle: SSDropdownStyle(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        elevation: 5,
      ),
      dropdownButtonStyle: SSDropdownButtonStyle(
        elevation: 2,
        backgroundColor: Colors.white,
        height: 50,
        width: MediaQuery.of(context).size.width * 0.32,
      ),
      items: List.generate(
          countries.length,
          (index) => SSDropdownItem<Country>(
                value: country,
                child: CustomDropdownItem(
                    key: Key(TestHelper.DropdownButtonKeyValue),
                    index: index,
                    colorHover: Colors.blue,
                    colorText: const Color(0xff556998),
                    showImage: true,
                    image: countries[index].flagUri,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    value: countries[index].dialCode.toString()),
              )),
      child: Expanded(
        child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Image.asset(
                  country!.flagUri,
                  width: 28.0,
                  height: 25.0,
                  package: 'intl_phone_number_input',
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox.shrink();
                  },
                ),
                SizedBox(width: 5),
                Expanded(
                    child: FittedBox(
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      country!.dialCode.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xff556998)),
                    ),
                  ),
                )),
              ],
            )),
      ),
      onChange: (dynamic value, int index) =>
          isEnabled ? onCountryChanged(countries[index]) : null,
    );
  }

  /// Converts the list [countries] to `DropdownMenuItem`
  List<DropdownMenuItem<Country>> mapCountryToDropdownItem(
      List<Country> countries) {
    return countries.map((country) {
      return DropdownMenuItem<Country>(
        value: country,
        child: Item(
          key: Key(TestHelper.countryItemKeyValue(country.alpha2Code)),
          country: country,
          showFlag: selectorConfig.showFlags,
          useEmoji: selectorConfig.useEmoji,
          textStyle: selectorTextStyle,
          withCountryNames: false,
          trailingSpace: selectorConfig.trailingSpace,
        ),
      );
    }).toList();
  }

  /// shows a Dialog with list [countries] if the [PhoneInputSelectorType.DIALOG] is selected
  Future<Country?> showCountrySelectorDialog(
      BuildContext inheritedContext, List<Country> countries) {
    return showDialog(
      context: inheritedContext,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        content: Directionality(
          textDirection: Directionality.of(inheritedContext),
          child: Container(
            width: double.maxFinite,
            child: CountrySearchListWidget(
              countries,
              locale,
              searchBoxDecoration: searchBoxDecoration,
              showFlags: selectorConfig.showFlags,
              useEmoji: selectorConfig.useEmoji,
              autoFocus: autoFocusSearchField,
            ),
          ),
        ),
      ),
    );
  }

  /// shows a Dialog with list [countries] if the [PhoneInputSelectorType.BOTTOM_SHEET] is selected
  Future<Country?> showCountrySelectorBottomSheet(
      BuildContext inheritedContext, List<Country> countries) {
    return showModalBottomSheet(
      context: inheritedContext,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      builder: (BuildContext context) {
        return Stack(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: DraggableScrollableSheet(
              builder: (BuildContext context, ScrollController controller) {
                return Directionality(
                  textDirection: Directionality.of(inheritedContext),
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Theme.of(context).canvasColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                    ),
                    child: CountrySearchListWidget(
                      countries,
                      locale,
                      searchBoxDecoration: searchBoxDecoration,
                      scrollController: controller,
                      showFlags: selectorConfig.showFlags,
                      useEmoji: selectorConfig.useEmoji,
                      autoFocus: autoFocusSearchField,
                    ),
                  ),
                );
              },
            ),
          ),
        ]);
      },
    );
  }
}
