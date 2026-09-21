import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/account.dart';
import '../../models/currency.dart';
import '../../models/transaction.dart';
import '../../providers/account_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transactionToEdit;
  final Account? preselectedAccount;

  const AddTransactionScreen({
    super.key,
    this.transactionToEdit,
    this.preselectedAccount,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int? _selectedCurrencyId;
  String? _imagePath;
  Account? _selectedAccount;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedAccount != null) {
      _selectedAccount = widget.preselectedAccount;
      _nameController.text = widget.preselectedAccount!.name;
      _selectedCurrencyId = widget.preselectedAccount!.currencyId;
    }

    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _amountController.text = tx.amount.toString();
      _descController.text = tx.description ?? '';
      _selectedDate = tx.date;
      _selectedCurrencyId = tx.currencyId;
      _imagePath = tx.imagePath;

      // Find account name
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final acc = await context.read<AccountProvider>().getAccountById(tx.accountId);
        if (acc != null && mounted) {
          setState(() {
            _selectedAccount = acc;
            _nameController.text = acc.name;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _saveTransaction(String type) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final amount = double.parse(AppValidators.normalizeDigits(_amountController.text.trim()));
    final desc = _descController.text.trim();
    final currencyId = _selectedCurrencyId ??
        context.read<CurrencyProvider>().selectedCurrency?.id ??
        1;

    // Get or create account automatically as per reference app behavior
    final account = _selectedAccount ??
        await context.read<AccountProvider>().getOrCreateAccount(
              name,
              currencyId: currencyId,
            );

    if (widget.transactionToEdit != null) {
      // Update existing
      final updated = widget.transactionToEdit!.copyWith(
        accountId: account.id!,
        amount: amount,
        type: type,
        currencyId: currencyId,
        date: _selectedDate,
        description: desc.isNotEmpty ? desc : null,
        imagePath: _imagePath,
      );
      await context.read<TransactionProvider>().updateTransaction(updated);
    } else {
      // Insert new
      final newTx = TransactionModel(
        accountId: account.id!,
        amount: amount,
        type: type,
        currencyId: currencyId,
        date: _selectedDate,
        description: desc.isNotEmpty ? desc : null,
        imagePath: _imagePath,
      );
      await context.read<TransactionProvider>().addTransaction(newTx);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ العملية بنجاح (${type == TransactionModel.typeDebit ? 'عليه' : 'له'})'),
          backgroundColor: AppColors.credit,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final accountProvider = context.watch<AccountProvider>();
    final currencies = currencyProvider.currencies;

    // Default to selected currency or first default
    _selectedCurrencyId ??= currencyProvider.selectedCurrency?.id ?? (currencies.isNotEmpty ? currencies.first.id : 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionToEdit != null ? 'تعديل عملية' : 'إضافة مبلغ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Name Field with Suggestions
              Autocomplete<Account>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Account>.empty();
                  }
                  return accountProvider.accounts.where((acc) =>
                      acc.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                displayStringForOption: (Account acc) => acc.name,
                onSelected: (Account acc) {
                  setState(() {
                    _selectedAccount = acc;
                    _nameController.text = acc.name;
                    if (acc.currencyId != null) {
                      _selectedCurrencyId = acc.currencyId;
                    }
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  // Link text if not already populated
                  if (_nameController.text.isNotEmpty && controller.text.isEmpty) {
                    controller.text = _nameController.text;
                  }
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'الإسم',
                      prefixIcon: Icon(Icons.person, color: AppColors.primary),
                    ),
                    validator: (val) => AppValidators.requiredField(val, message: 'يرجى إدخال اسم الحساب'),
                    onChanged: (val) {
                      _nameController.text = val;
                      _selectedAccount = null; // User typed a custom or new name
                    },
                  );
                },
              ),
              const SizedBox(height: 14),

              // 2. Amount Field with Calculator Icon
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'المبلغ',
                  prefixIcon: const Icon(Icons.calculate, color: AppColors.primary),
                  suffixText: currencies
                      .firstWhere(
                        (c) => c.id == _selectedCurrencyId,
                        orElse: () => Currency(name: 'محلي', symbol: 'محلي'),
                      )
                      .symbol,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: AppValidators.validAmount,
              ),
              const SizedBox(height: 14),

              // 3. Date & Camera Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppFormatters.formatDisplayDate(_selectedDate),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Camera Icon for invoice/photo
                  IconButton.filledTonal(
                    icon: Icon(
                      _imagePath != null ? Icons.check_circle : Icons.camera_alt,
                      color: _imagePath != null ? AppColors.credit : AppColors.primary,
                    ),
                    onPressed: _pickImage,
                    tooltip: 'التقاط صورة للسند أو الفاتورة',
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 4. Details / Description
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'التفاصيل',
                  prefixIcon: Icon(Icons.notes, color: AppColors.primary),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // 5. Currency Selection Radio Row (Matching image15)
              const Text(
                'العملة:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                children: currencies.map((curr) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<int>(
                        value: curr.id!,
                        groupValue: _selectedCurrencyId,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _selectedCurrencyId = val;
                          });
                        },
                      ),
                      Text(curr.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 6. Big Action Buttons: "عليه" (Debit) & "له" (Credit) (Matching image15!)
              Row(
                children: [
                  // Button: "له" (Credit / Green up arrow)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _saveTransaction(TransactionModel.typeCredit),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_drop_up, color: AppColors.credit, size: 28),
                          SizedBox(width: 6),
                          Text('له', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Button: "عليه" (Debit / Red down arrow)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _saveTransaction(TransactionModel.typeDebit),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_drop_down, color: AppColors.debit, size: 28),
                          SizedBox(width: 6),
                          Text('عليه', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
