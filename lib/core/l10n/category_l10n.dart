import 'package:flutter/material.dart';
import 'package:kaku/core/database/app_database.dart';
import 'package:kaku/core/l10n/default_category.dart';
import 'package:kaku/l10n/app_localizations.dart';

extension DefaultCategoryL10n on DefaultCategory {
  String label(AppLocalizations l10n) => switch (this) {
    DefaultCategory.food => l10n.categoryFood,
    DefaultCategory.transport => l10n.categoryTransport,
    DefaultCategory.home => l10n.categoryHome,
    DefaultCategory.health => l10n.categoryHealth,
    DefaultCategory.leisure => l10n.categoryLeisure,
    DefaultCategory.education => l10n.categoryEducation,
    DefaultCategory.shopping => l10n.categoryShopping,
    DefaultCategory.services => l10n.categoryServices,
    DefaultCategory.savings => l10n.categorySavings,
    DefaultCategory.salary => l10n.categorySalary,
    DefaultCategory.freelance => l10n.categoryFreelance,
    DefaultCategory.sales => l10n.categorySales,
    DefaultCategory.gifts => l10n.categoryGifts,
    DefaultCategory.investments => l10n.categoryInvestments,
    DefaultCategory.otherIncome => l10n.categoryOtherIncome,
  };
}

extension CategoryDisplay on Category {
  String displayName(BuildContext context) {
    final key = systemKey;
    if (key == null) return name;
    final match = DefaultCategory.values.where((c) => c.name == key);
    if (match.isEmpty) return name;
    return match.first.label(AppLocalizations.of(context)!);
  }
}