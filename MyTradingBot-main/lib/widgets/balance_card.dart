import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final bool isDemo;
  final VoidCallback? onSwitchAccount;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.isDemo,
    this.onSwitchAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isDemo ? 'الرصيد التجريبي (DEMO)' : 'الرصيد الحقيقي (REAL)',
                style: TextStyle(
                  color: isDemo ? Colors.orange : Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '\$${balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (onSwitchAccount != null)
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: Color(0xFFD4AF37), size: 30),
              onPressed: onSwitchAccount,
              tooltip: 'تبديل الحساب',
            ),
        ],
      ),
    );
  }
}
