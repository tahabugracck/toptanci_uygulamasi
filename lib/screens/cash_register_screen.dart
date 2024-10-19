import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toptanci_uygulamasi/service/mongodb.dart';
import 'package:intl/intl.dart';
import 'package:toptanci_uygulamasi/widgets/drawers/theme_notifier.dart'; // intl paketini import et

class CashRegisterScreen extends StatefulWidget {
  const CashRegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CashRegisterScreenState createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends State<CashRegisterScreen> {
  List<Map<String, dynamic>> cashIncomeMovements = [];
  List<Map<String, dynamic>> cashExpenseMovements = [];
  List<Map<String, dynamic>> cardIncomeMovements = [];
  List<Map<String, dynamic>> cardExpenseMovements = [];
  bool isLoading = false;
  String errorMessage = '';
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      cashIncomeMovements = await MongoDatabase.getCashIncomeMovements();
      cashExpenseMovements = await MongoDatabase.getCashExpenseMovements();
      cardIncomeMovements = await MongoDatabase.getCardsIncomeMovements();
      cardExpenseMovements = await MongoDatabase.getCardsExpenseMovements();

      // Calculate totals
      totalIncome = _calculateTotal(cashIncomeMovements) +
          _calculateTotal(cardIncomeMovements);
      totalExpense = _calculateTotal(cashExpenseMovements) +
          _calculateTotal(cardExpenseMovements);
    } catch (e) {
      if (kDebugMode) {
        print('Veri yükleme hatası: $e');
      }
      setState(() {
        errorMessage = 'Veriler yüklenirken bir hata oluştu: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  double _calculateTotal(List<Map<String, dynamic>> movements) {
    return movements.fold(0.0, (sum, movement) {
      final amount = (movement["amount"] is int)
          ? (movement["amount"] as int).toDouble()
          : double.tryParse(movement["amount"].toString()) ?? 0.0;
      return sum + amount;
    });
  }

  void _showAddMovementDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: AddMovementForm(onSubmit: (movement) async {
            String userId = '66aa2e456d72b0822ad566e8'; // Örnek kullanıcı ID'si

            try {
              DateTime transactionDate;
              if (movement['transactionDate'] != null) {
                try {
                  transactionDate = DateFormat('dd/MM/yyyy')
                      .parse(movement['transactionDate']);
                } catch (e) {
                  if (kDebugMode) {
                    print('Tarih formatı hatalı, düzeltilemedi: $e');
                  }
                  transactionDate = DateTime.now();
                }
              } else {
                transactionDate = DateTime.now();
              }

              if (kDebugMode) {
                print('İşlem Detayları: ${movement.toString()}');
              }

              if (movement['type'] == 'Kart') {
                await MongoDatabase.addCardMovement(userId, {
                  'to_from': movement['to_from'],
                  'amount':
                      double.tryParse(movement['amount'].toString()) ?? 0.0,
                  'transactionDate': transactionDate.toIso8601String(),
                  'description': movement['description'],
                  'incoming': movement['transactionType'] == 'Gelir',
                });
              } else if (movement['type'] == 'Nakit') {
                await MongoDatabase.addCashMovement(userId, {
                  'to_from': movement['to_from'],
                  'amount':
                      double.tryParse(movement['amount'].toString()) ?? 0.0,
                  'transactionDate': transactionDate.toIso8601String(),
                  'description': movement['description'],
                  'incoming': movement['transactionType'] == 'Gelir',
                });
              }
              await loadData();
            } catch (e) {
              if (kDebugMode) {
                print('İşlem eklenirken hata oluştu: $e');
              }
            }
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeNotifier>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hesap Hareketleri'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Kart'),
              Tab(text: 'Nakit'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: loadData,
              tooltip: 'Yenile',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddMovementDialog,
              tooltip: 'Yeni Hareket Ekle',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildCardAndCashView('Kart'),
            _buildCardAndCashView('Nakit'),
          ],
        ),
      ),
    );
  }

  Widget _buildCardAndCashView(String type) {
    final List<Map<String, dynamic>> incomeMovements =
        type == 'Nakit' ? cashIncomeMovements : cardIncomeMovements;
    final List<Map<String, dynamic>> expenseMovements =
        type == 'Nakit' ? cashExpenseMovements : cardExpenseMovements;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Gelir'),
                Tab(text: 'Gider'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMovementList(incomeMovements, '$type Gelirler',
                      Colors.green, true, type),
                  _buildMovementList(expenseMovements, '$type Giderler',
                      Colors.red, false, type),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementList(List<Map<String, dynamic>> movements, String title,
      Color amountColor, bool isIncome, String type) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage.isNotEmpty) {
      return Center(
          child: Text(errorMessage, style: const TextStyle(color: Colors.red)));
    }
    if (movements.isEmpty) {
      return const Center(
          child: Text('Veri bulunamadı',
              style: TextStyle(fontSize: 16, color: Colors.grey)));
    }

    double total = movements.fold(0.0, (sum, movement) {
      final amount = (movement["amount"] is int)
          ? (movement["amount"] as int).toDouble()
          : double.tryParse(movement["amount"].toString()) ?? 0.0;
      return sum + amount;
    });

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: movements.length,
            itemBuilder: (context, index) {
              final movement = movements[index];
              final amount = (movement["amount"] is int)
                  ? (movement["amount"] as int).toDouble()
                  : double.tryParse(movement["amount"].toString()) ?? 0.0;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: amountColor, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(movement["description"] ?? "Açıklama Yok",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tarih: ${movement["date"] ?? "Tarih Yok"}'),
                      Text(
                          'Gönderen: ${movement["to_from"]?.isNotEmpty == true ? movement["to_from"] : "Gönderen bilgisi yoktur."}'),
                    ],
                  ),
                  trailing: Text(
                    NumberFormat.currency(locale: 'tr_TR', symbol: '₺')
                        .format(amount),
                    style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '${isIncome ? 'Toplam Gelir' : 'Toplam Gider'}: ${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(total)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddMovementForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AddMovementForm({super.key, required this.onSubmit});

  @override
  // ignore: library_private_types_in_public_api
  _AddMovementFormState createState() => _AddMovementFormState();
}

class _AddMovementFormState extends State<AddMovementForm> {
  final _formKey = GlobalKey<FormState>();
  String? _type = 'Kart';
  String? _transactionType = 'Gelir';
  DateTime _transactionDate = DateTime.now();
  String _toFrom = '';
  String _description = '';
  String _amount = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _type,
            onChanged: (value) => setState(() => _type = value),
            items: const [
              DropdownMenuItem(value: 'Kart', child: Text('Kart')),
              DropdownMenuItem(value: 'Nakit', child: Text('Nakit')),
            ],
            decoration: const InputDecoration(labelText: 'Kart/Nakit'),
            validator: (value) => value == null ? 'Bu alan gerekli' : null,
          ),
          DropdownButtonFormField<String>(
            value: _transactionType,
            onChanged: (value) => setState(() => _transactionType = value),
            items: const [
              DropdownMenuItem(value: 'Gelir', child: Text('Gelir')),
              DropdownMenuItem(value: 'Gider', child: Text('Gider')),
            ],
            decoration: const InputDecoration(labelText: 'Gelir/Gider'),
            validator: (value) => value == null ? 'Bu alan gerekli' : null,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Tarih'),
            initialValue: formatDate(_transactionDate),
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: _transactionDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (selectedDate != null && selectedDate != _transactionDate) {
                setState(() {
                  _transactionDate = selectedDate;
                });
              }
            },
            validator: (value) =>
                value == null || value.isEmpty ? 'Bu alan gerekli' : null,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Kim tarafından'),
            onChanged: (value) => setState(() => _toFrom = value),
            validator: (value) =>
                value == null || value.isEmpty ? 'Bu alan gerekli' : null,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Açıklama'),
            onChanged: (value) => setState(() => _description = value),
            validator: (value) =>
                value == null || value.isEmpty ? 'Bu alan gerekli' : null,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Miktar'),
            keyboardType: TextInputType.number,
            onChanged: (value) => setState(() => _amount = value),
            validator: (value) =>
                value == null || value.isEmpty ? 'Bu alan gerekli' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                double amount = double.tryParse(_amount) ?? 0.0;
                if (_transactionType == 'Gelir' && amount < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Gelir işlemi için negatif miktar girilemez.')),
                  );
                } else if (_transactionType == 'Gider' && amount > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Gider işlemi için pozitif miktar girilemez.')),
                  );
                } else {
                  widget.onSubmit({
                    'type': _type,
                    'transactionType': _transactionType,
                    'transactionDate': formatDate(_transactionDate),
                    'to_from': _toFrom,
                    'description': _description,
                    'amount': amount,
                  });
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
