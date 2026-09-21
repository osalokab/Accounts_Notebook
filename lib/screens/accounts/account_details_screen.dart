import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../models/account.dart';
import '../../models/currency.dart';
import '../../models/transaction.dart';
import '../../providers/account_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/pdf_service.dart';
import '../../services/sharing_service.dart';
import '../../utils/account_icons.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/transaction_card.dart';

class AccountDetailsScreen extends StatefulWidget {
  final Account account;

  const AccountDetailsScreen({super.key, required this.account});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late Account _currentAccount;

  @override
  void initState() {
    super.initState();
    _currentAccount = widget.account;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final updatedAcc = await context.read<AccountProvider>().getAccountById(_currentAccount.id!);
    if (updatedAcc != null && mounted) {
      setState(() {
        _currentAccount = updatedAcc;
      });
    }
    if (mounted) {
      await context.read<TransactionProvider>().loadTransactionsForAccount(
            _currentAccount.id!,
            _currentAccount.initialBalance,
          );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transProvider = context.watch<TransactionProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final settings = context.watch<SettingsProvider>().settings;

    final currency = currencyProvider.currencies
            .where((c) => c.id == _currentAccount.currencyId)
            .firstOrNull ??
        Currency(name: AppStrings.isArabic ? 'محلي' : 'Local', symbol: AppStrings.isArabic ? 'محلي' : 'Local');

    final statement = transProvider.statementWithRunningBalance;

    // Filter statement by search query if active
    final filteredStatement = _searchController.text.trim().isEmpty
        ? statement
        : statement.where((item) {
            final tx = item['transaction'] as TransactionModel;
            final q = _searchController.text.trim().toLowerCase();
            return (tx.description?.toLowerCase().contains(q) ?? false) ||
                tx.amount.toString().contains(q) ||
                AppFormatters.formatDisplayDate(tx.date).contains(q);
          }).toList();

    return Scaffold(
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
                    hintText: AppStrings.searchStatement,
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
                        setState(() {});
                      },
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              )
            : Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white24,
                    child: _currentAccount.iconCode != null && _currentAccount.iconCode!.isNotEmpty
                        ? Icon(AccountIcons.getIcon(_currentAccount.iconCode), size: 18, color: Colors.white)
                        : Text(
                            _currentAccount.name.isNotEmpty ? _currentAccount.name[0] : '؟',
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_currentAccount.name, overflow: TextOverflow.ellipsis)),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: AppStrings.search,
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: AppStrings.exportPdf,
            onPressed: () async {
              await PdfService.printStatement(
                account: _currentAccount,
                statement: statement,
                settings: settings,
                currency: currency,
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (val) async {
              switch (val) {
                case 'edit':
                  _showEditAccountDialog();
                  break;
                case 'share_text':
                  await SharingService.shareAccountText(
                    account: _currentAccount,
                    statement: statement,
                    currencySymbol: currency.symbol,
                  );
                  break;
                case 'share_pdf':
                  final bytes = await PdfService.generateAccountStatementPdf(
                    account: _currentAccount,
                    statement: statement,
                    settings: settings,
                    currency: currency,
                  );
                  await SharingService.sharePdfBytes(
                    bytes: bytes,
                    filename: 'كشف_حساب_${_currentAccount.name}',
                  );
                  break;
                case 'settle':
                  _showSettleDialog();
                  break;
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'edit', child: Text(AppStrings.editAccount)),
              PopupMenuItem(value: 'share_text', child: Text(AppStrings.isArabic ? 'مشاركة كنص' : 'Share as Text')),
              PopupMenuItem(value: 'share_pdf', child: Text(AppStrings.isArabic ? 'مشاركة كملف PDF' : 'Share as PDF')),
              PopupMenuItem(value: 'settle', child: Text(AppStrings.settleAccount)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Account Summary Header Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: _currentAccount.iconCode != null && _currentAccount.iconCode!.isNotEmpty
                          ? Icon(AccountIcons.getIcon(_currentAccount.iconCode), color: Colors.white, size: 26)
                          : Text(
                              _currentAccount.name.isNotEmpty ? _currentAccount.name[0] : '؟',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentAccount.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_currentAccount.phone != null && _currentAccount.phone!.isNotEmpty)
                          Text(
                            _currentAccount.phone!,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الرصيد: ${AppFormatters.formatAmount(_currentAccount.currentBalance)} ${currency.symbol}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _currentAccount.currentBalance > 0
                            ? const Color(0xFFFFAAAA) // reddish white
                            : _currentAccount.currentBalance < 0
                                ? const Color(0xFFAAFFAA) // greenish white
                                : Colors.white,
                      ),
                    ),
                    Text(
                      _currentAccount.currentBalance > 0
                          ? 'عليه (مطلوب منه)'
                          : _currentAccount.currentBalance < 0
                              ? 'له (مطلوب له)'
                              : 'الحساب متوازن',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: transProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStatement.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long, size: 60, color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            const Text(
                              'لا توجد عمليات مسجلة لهذا الحساب',
                              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('إضافة مبلغ'),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.addTransaction,
                                  arguments: _currentAccount,
                                ).then((_) => _loadData());
                              },
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredStatement.length,
                          // Render reverse so newest appears on top while running balance stays mathematically correct
                          itemBuilder: (context, index) {
                            final reverseIndex = filteredStatement.length - 1 - index;
                            final item = filteredStatement[reverseIndex];
                            final tx = item['transaction'] as TransactionModel;
                            final running = item['running_balance'] as double;

                            return TransactionCard(
                              transaction: tx,
                              runningBalance: running,
                              currencySymbol: currency.symbol,
                              onEdit: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.addTransaction,
                                  arguments: tx,
                                ).then((_) => _loadData());
                              },
                              onDelete: () => _confirmDeleteTransaction(tx.id!),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addTransaction,
            arguments: _currentAccount,
          ).then((_) => _loadData());
        },
      ),
    );
  }

  void _confirmDeleteTransaction(int txId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف العملية'),
        content: const Text('هل أنت متأكد من حذف هذه العملية؟ سيتم تحديث الرصيد تلقائياً.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.debit),
            onPressed: () async {
              await context.read<TransactionProvider>().deleteTransaction(txId);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showSettleDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسوية / إغلاق الحساب'),
        content: const Text(
          'يمكنك ترحيل الرصيد كعملية افتتاحية واحدة أو تصفير الحساب نهائياً.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          OutlinedButton(
            onPressed: () async {
              await context.read<AccountProvider>().settleAccount(_currentAccount.id!, keepBalance: true);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('ترحيل الرصيد'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.debit),
            onPressed: () async {
              await context.read<AccountProvider>().settleAccount(_currentAccount.id!, keepBalance: false);
              if (ctx.mounted) Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('تصفير الحساب'),
          ),
        ],
      ),
    );
  }

  void _showEditAccountDialog() {
    final nameCtrl = TextEditingController(text: _currentAccount.name);
    final phoneCtrl = TextEditingController(text: _currentAccount.phone);
    final notesCtrl = TextEditingController(text: _currentAccount.notes);
    String selectedIcon = _currentAccount.iconCode ?? 'person';

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
                    final updated = _currentAccount.copyWith(
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      notes: notesCtrl.text.trim(),
                      iconCode: selectedIcon,
                    );
                    await context.read<AccountProvider>().updateAccount(updated);
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadData();
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
}
