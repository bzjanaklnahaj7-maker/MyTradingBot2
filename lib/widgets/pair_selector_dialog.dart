import 'package:flutter/material.dart';
import '../models/instrument_model.dart';

class PairSelectorDialog extends StatefulWidget {
  final List<InstrumentModel> availablePairs;
  final List<String> selectedPairs;
  final int maxSelection;

  const PairSelectorDialog({
    super.key,
    required this.availablePairs,
    required this.selectedPairs,
    this.maxSelection = 4,
  });

  @override
  State<PairSelectorDialog> createState() => _PairSelectorDialogState();
}

class _PairSelectorDialogState extends State<PairSelectorDialog> {
  late List<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedPairs);
  }

  @override
  Widget build(BuildContext context) {
    // تصفية الأزواج
    List<InstrumentModel> otcPairs = widget.availablePairs.where((p) => p.assetId.endsWith('_otc')).toList();
    List<InstrumentModel> stockPairs = widget.availablePairs.where((p) => !p.assetId.endsWith('_otc')).toList();

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('اختيار الأزواج', style: TextStyle(color: Color(0xFFD4AF37))),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView(
          children: [
            if (otcPairs.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('أزواج OTC', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              ...otcPairs.map((p) => _buildPairTile(p.assetId)),
            ],
            if (stockPairs.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('أزواج البورصة', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              ...stockPairs.map((p) => _buildPairTile(p.assetId)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _tempSelected),
          child: const Text('تأكيد', style: TextStyle(color: Color(0xFFD4AF37))),
        ),
      ],
    );
  }

  Widget _buildPairTile(String name) {
    return CheckboxListTile(
      dense: true,
      title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 13)),
      value: _tempSelected.contains(name),
      activeColor: const Color(0xFFD4AF37),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            if (_tempSelected.length < widget.maxSelection) {
              _tempSelected.add(name);
            }
          } else {
            _tempSelected.remove(name);
          }
        });
      },
    );
  }
}
