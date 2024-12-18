// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

extension HomeCardPadding on Widget {
  Widget withHomeCardStyle(BuildContext context) {
    return Card(
      //elevation: 0,
      shadowColor: Colors.transparent,
      color: Theme.of(context).colorScheme.primary.withOpacity(
            Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.075,
          ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? null
              : Theme.of(context).colorScheme.primary,
        ),
        child: this,
      ),
    );
  }
}
