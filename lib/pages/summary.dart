import 'package:expenses_charts/components/settings_menu.dart';
import 'package:expenses_charts/providers/budget_provider.dart';
import 'package:expenses_charts/providers/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  double _totalMoney = 0.0;
  double _totalWithoutShares = 0.0;
  double _totalShares = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSummary();
    });
  }

  Future<void> _loadSummary() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final budgetProvider = context.read<BudgetProvider>();
      _totalMoney = await budgetProvider.getTotalMoney();
      _totalWithoutShares = await budgetProvider.getTotalWithoutShares();
      _totalShares = await budgetProvider.getTotalShares();
    } catch (e) {
      debugPrint('Error loading summary: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsProvider>();
    
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.account_balance_wallet_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text("Summary"),
        actions: const [
          SettingsMenu(),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadSummary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildSummaryCard(
                        context,
                        title: "Total Amount of Money",
                        value: _totalMoney,
                        currency: settingsState.currency,
                        icon: Icons.account_balance_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(
                        context,
                        title: "Total Without Shares",
                        value: _totalWithoutShares,
                        currency: settingsState.currency,
                        icon: Icons.money_off_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(
                        context,
                        title: "Total Shares",
                        value: _totalShares,
                        currency: settingsState.currency,
                        icon: Icons.trending_up_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required double value,
    required String currency,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "${value.toStringAsFixed(2)} $currency",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

