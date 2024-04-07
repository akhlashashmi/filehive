import 'package:flutter/material.dart';

customNavigationRailDestination({
  required IconData icon,
  required String label,
  required BuildContext context,
  required bool isListEmpty,
}) {
  return NavigationRailDestination(
    icon: Icon(icon),
    label: Text(
      label,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onBackground,
          ),
    ),
    // disabled: (isListEmpty) ? true : false,
  );
}