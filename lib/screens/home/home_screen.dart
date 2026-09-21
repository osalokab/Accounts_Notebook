import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../models/account.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/account_icons.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/account_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/help_accordion_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    await context.read<CategoryProvider>().loadCategories();
    await context.read<CurrencyProvider>().loadCurrencies();
    await context.read<AccountProvider>().loadAccounts();
    final count = await NotificationService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadNotifications = count;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();

    final selectedCategory = categoryProvider.selectedCategory;
    final selectedCurrency = currencyProvider.selectedCurrency;
    final currencySymbol = selectedCurrency?.symbol ?? (AppStrings.isArabic ? 'محلي' : 'Local');

    final accounts = accountProvider.accounts;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: _isSearching
            ? Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    hintText: AppStrings.searchAccounts,
                    hintStyle: const TextStyle(color: Colors.black45, fontSize: 13),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.black54, size: 20),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _searchController.clear();
                        accountProvider.setSearchQuery('');
                      },
                    ),
                  ),
                  onChanged: (val) {
                    accountProvider.setSearchQuery(val);
                  },
                ),
              )
            : InkWell(
                onTap: () => _showCategoryPicker(context),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedCategory?.name ?? (AppStrings.isArabic ? 'عام' : 'General'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ),
              ),
        actions: [
          // Search Icon
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: AppStrings.search,
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  accountProvider.setSearchQuery('');
                }
              });
            },
          ),

          // Add Account Button
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: AppStrings.addNewAccount,
            onPressed: () => _showAddAccountDialog(context),
          ),

          // Notifications Bell
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRoutes.notifications);
                  _refreshData();
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.debit,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          // Sort Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: AppStrings.sortAccounts,
            onSelected: (val) {
              switch (val) {
                case 'name_asc':
                  accountProvider.setSorting(AccountSortField.name, SortOrder.ascending);
                  break;
                case 'name_desc':
                  accountProvider.setSorting(AccountSortField.name, SortOrder.descending);
                  break;
                case 'balance_asc':
                  accountProvider.setSorting(AccountSortField.balance, SortOrder.ascending);
                  break;
                case 'balance_desc':
                  accountProvider.setSorting(AccountSortField.balance, SortOrder.descending);
                  break;
                case 'date_desc':
                  accountProvider.setSorting(AccountSortField.date, SortOrder.descending);
                  break;
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'name_asc', child: Text(AppStrings.isArabic ? 'ترتيب حسب الاسم (أ - ي)' : 'Name (A - Z)')),
              PopupMenuItem(value: 'name_desc', child: Text(AppStrings.isArabic ? 'ترتيب حسب الاسم (ي - أ)' : 'Name (Z - A)')),
              PopupMenuItem(value: 'balance_desc', child: Text(AppStrings.isArabic ? 'ترتيب حسب الرصيد (الأعلى أولاً)' : 'Balance (High to Low)')),
              PopupMenuItem(value: 'balance_asc', child: Text(AppStrings.isArabic ? 'ترتيب حسب الرصيد (الأقل أولاً)' : 'Balance (Low to High)')),
              PopupMenuItem(value: 'date_desc', child: Text(AppStrings.isArabic ? 'ترتيب حسب الأحدث نشاطاً' : 'Recent Activity')),
            ],
          ),
        ],
      ),
      body: accountProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : accounts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_outlined, size: 70, color: AppColors.primaryLight.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.addAmountPrompt,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.orCreateAccount,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withValues(alpha: 0.8)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.person_add_alt_1),
                        label: Text(AppStrings.addNewAccount),
                        onPressed: () => _showAddAccountDialog(context),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      return AccountCard(
                        account: account,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.accountDetails,
                            arguments: account,
                          ).then((_) => _refreshData());
                        },
                        onEdit: () => _showEditAccountDialog(context, account),
                        onDelete: () => _confirmDeleteAccount(context, account),
                        onSettle: () => _showSettleAccountDialog(context, account),
                      );
                    },
                  ),
                ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: AppColors.bottomBar,
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, -1)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Help Button (?)
            IconButton(
              tooltip: AppStrings.userGuide,
              icon: const Text(
                '؟',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => HelpAccordionDialog.show(context),
            ),

            // Center: Balance Summary (عليك: X   لك: Y \n [العملة])
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${AppStrings.youOwe}: ${AppFormatters.formatAmount(accountProvider.totalPayable)}   ${AppStrings.owedToYou}: ${AppFormatters.formatAmount(accountProvider.totalReceivable)}',
                  style: const TextStyle(
                    color: AppColors.bottomBarText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currencySymbol,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            // Right: Add Transaction Button (+)
            IconButton(
              tooltip: AppStrings.isArabic ? 'إضافة مبلغ' : 'Add Transaction',
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 34,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addTransaction).then((_) => _refreshData());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    final categoryProvider = context.read<CategoryProvider>();
    final categories = categoryProvider.categories;
    final currencySymbol = context.read<CurrencyProvider>().selectedCurrency?.symbol ?? (AppStrings.isArabic ? 'محلي' : 'Local');

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        children: categories.map((cat) {
          return SimpleDialogOption(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              '${cat.name} ($currencySymbol)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: cat.id == categoryProvider.selectedCategory?.id
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: cat.id == categoryProvider.selectedCategory?.id
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
            onPressed: () {
              categoryProvider.selectCategory(cat);
              context.read<AccountProvider>().setFilterCategory(cat.id);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedIcon = 'person';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(AppStrings.addNewAccount),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () async {
                      final picked = await AccountIcons.showIconPicker(context, selectedCode: selectedIcon);
                      if (picked != null) {
                        setDialogState(() {
                          selectedIcon = picked;
                        });
                      }
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                          child: Icon(AccountIcons.getIcon(selectedIcon), size: 30, color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.chooseAccountIcon,
                          style: const TextStyle(fontSize: 12, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: AppStrings.accountName),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(labelText: AppStrings.phone),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesCtrl,
                    decoration: InputDecoration(labelText: AppStrings.notes),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.cancel)),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    final defaultCurr = context.read<CurrencyProvider>().selectedCurrency?.id ?? 1;
                    final defaultCat = context.read<CategoryProvider>().selectedCategory?.id ?? 1;
                    await context.read<AccountProvider>().addAccount(
                      Account(
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                        iconCode: selectedIcon,
                        currencyId: defaultCurr,
                        categoryId: defaultCat,
                      ),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                child: Text(AppStrings.save),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditAccountDialog(BuildContext context, Account account) {
    final nameCtrl = TextEditingController(text: account.name);
    final phoneCtrl = TextEditingController(text: account.phone);
    final notesCtrl = TextEditingController(text: account.notes);
    String selectedIcon = account.iconCode ?? 'person';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(AppStrings.editAccount),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () async {
                      final picked = await AccountIcons.showIconPicker(context, selectedCode: selectedIcon);
                      if (picked != null) {
                        setDialogState(() {
                          selectedIcon = picked;
                        });
                      }
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                          child: Icon(AccountIcons.getIcon(selectedIcon), size: 30, color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.chooseAccountIcon,
                          style: const TextStyle(fontSize: 12, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: AppStrings.accountName),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(labelText: AppStrings.phone),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesCtrl,
                    decoration: InputDecoration(labelText: AppStrings.notes),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.cancel)),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    await context.read<AccountProvider>().updateAccount(
                          account.copyWith(
                            name: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            notes: notesCtrl.text.trim(),
                            iconCode: selectedIcon,
                          ),
                        );
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                child: Text(AppStrings.save),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, Account account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteAccount),
        content: Text(
          AppStrings.isArabic
              ? 'هل أنت متأكد من حذف الحساب "${account.name}"؟ سيتم حذف جميع عملياته المالية نهائياً.'
              : 'Are you sure you want to delete "${account.name}"? All associated transactions will be removed.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.debit),
            onPressed: () async {
              await context.read<AccountProvider>().deleteAccount(account.id!);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showSettleAccountDialog(BuildContext context, Account account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.settleAccount),
        content: Text(
          '${AppStrings.currentBalance}: ${AppFormatters.formatAmount(account.currentBalance)}\n\n'
          '${AppStrings.isArabic ? "اختر طريقة التسوية:" : "Select settlement method:"}\n'
          '${AppStrings.isArabic ? "1- دمج الحساب في رصيد مرحل واحد وحذف العمليات السابقة." : "1- Consolidate account into a single carried-forward balance."}\n'
          '${AppStrings.isArabic ? "2- تصفير الحساب بالكامل (0.0)." : "2- Reset account balance to zero (0.0)."}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.cancel)),
          OutlinedButton(
            onPressed: () async {
              await context.read<AccountProvider>().settleAccount(account.id!, keepBalance: true);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(AppStrings.isArabic ? 'ترحيل الرصيد' : 'Carry Forward'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.debit),
            onPressed: () async {
              await context.read<AccountProvider>().settleAccount(account.id!, keepBalance: false);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(AppStrings.isArabic ? 'تصفير الحساب' : 'Zero Balance'),
          ),
        ],
      ),
    );
  }
}
