import 'package:flutter/material.dart';
import 'package:kaku/shared/widgets/receipt_viewer.dart';

class TransactionDetailListConfig {
  final String title;
  final String? subtitle;
  final bool isImage;

  const TransactionDetailListConfig({
    required this.title,
    this.subtitle,
    this.isImage = false,
  });
}

class TransactionDetailList extends StatelessWidget {
  final List<TransactionDetailListConfig> list;

  const TransactionDetailList({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: cs.outline),
              ),
            ),
            child: Row(
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 18,
                    color: cs.onSurface.withValues(alpha: 0.76),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (item.subtitle != null && !item.isImage)
                  Expanded(
                    child: Text(
                      item.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                if (item.isImage)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: item.subtitle != null
                          ? () => ReceiptViewer.open(
                              context,
                              filePath: item.subtitle!,
                            )
                          : null,
                      icon: Icon(Icons.image),
                      label: Text(
                        item.subtitle != null ? 'Ver recibo' : 'Sin recibo',
                        textAlign: TextAlign.right,
                      ),
                      style: ButtonStyle(alignment: Alignment.centerRight),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
