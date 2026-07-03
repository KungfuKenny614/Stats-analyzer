import 'package:flutter/material.dart';
import 'package:stats_analyzer/design_system/tokens/colors.dart';
import 'package:stats_analyzer/design_system/tokens/spacing.dart';
import 'package:stats_analyzer/design_system/tokens/typography.dart';

class DataGridColumn {
  final String label;
  final double? width;
  final bool sortable;
  final bool sticky;
  final Alignment alignment;
  final String Function(dynamic) valueBuilder;

  DataGridColumn({
    required this.label,
    this.width,
    this.sortable = false,
    this.sticky = false,
    this.alignment = Alignment.centerLeft,
    required this.valueBuilder,
  });
}

class DataGrid extends StatelessWidget {
  final List<DataGridColumn> columns;
  final List<dynamic> rows;
  final String? emptyMessage;
  final VoidCallback? onRowTap;
  final int? maxHeight;

  const DataGrid({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyMessage,
    this.onRowTap,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: DSColors.border.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: DSColors.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTable(),
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: DSColors.surfaceVariant,
              border: Border(
                bottom: BorderSide(
                  color: DSColors.border.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: columns.map((col) {
                return _buildHeaderCell(col);
              }).toList(),
            ),
          ),
          // Rows
          if (rows.isEmpty)
            SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  emptyMessage ?? 'No data available',
                  style: DSTypography.bodySM.copyWith(
                    color: DSColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              return GestureDetector(
                onTap: () => onRowTap?.call(),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: DSColors.border.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: columns.map((col) {
                      return _buildDataCell(col, row);
                    }).toList(),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(DataGridColumn col) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      width: col.width,
      child: Text(
        col.label,
        style: DSTypography.labelStrong.copyWith(
          color: DSColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDataCell(DataGridColumn col, dynamic row) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.md),
      width: col.width,
      alignment: col.alignment,
      child: Text(
        col.valueBuilder(row),
        style: DSTypography.bodySM,
      ),
    );
  }
}
