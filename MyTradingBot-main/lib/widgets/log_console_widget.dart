import 'package:flutter/material.dart';

class LogConsoleWidget extends StatefulWidget {
  final List<String> logs;

  const LogConsoleWidget({super.key, required this.logs});

  @override
  State<LogConsoleWidget> createState() => _LogConsoleWidgetState();
}

class _LogConsoleWidgetState extends State<LogConsoleWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant LogConsoleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // التمرير التلقائي للأسفل عند إضافة سجل جديد
    if (widget.logs.length > oldWidget.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: widget.logs.isEmpty
          ? const Center(child: Text('لا توجد سجلات بعد...', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              controller: _scrollController,
              itemCount: widget.logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.logs[index],
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.greenAccent,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
