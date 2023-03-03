import 'package:flutter/material.dart';

class TreeNodeData {
  String title;
  bool expanded;
  bool? checked;
  dynamic extra;
  final Color? checkBoxCheckColor;
  final MaterialStateProperty<Color>? checkBoxFillColor;
  final ValueGetter<Color>? backgroundColor;
  final List<Widget>? customActions;
  List<TreeNodeData> children;
  TreeNodeData? parent;

  TreeNodeData({
    required this.title,
    required this.expanded,
    required this.checked,
    required this.children,
    required this.parent,
    this.extra,
    this.checkBoxCheckColor,
    this.checkBoxFillColor,
    this.backgroundColor,
    this.customActions,
  });

  TreeNodeData.from(TreeNodeData other)
      : this(
          title: other.title,
          expanded: other.expanded,
          checked: other.checked,
          extra: other.extra,
          children: other.children,
          parent: other.parent,
        );

  @override
  String toString() {
    return 'TreeNodeData{title: $title, expanded: $expanded, checked: $checked, extra: $extra, '
        'checkBoxCheckColor: $checkBoxCheckColor, checkBoxFillColor: $checkBoxFillColor, '
        'backgroundColor: $backgroundColor, customActions: $customActions, children: $children, parent: $parent}';
  }
}
