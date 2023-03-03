import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_treeview_plus/bloc/treeview_bloc.dart';

import 'tree_node_data.dart';

class TreeNode extends StatefulWidget {
  final TreeNodeData data;
  final TreeNodeData parent;
  final State? parentState;

  final bool lazy;
  final Widget icon;
  final bool showCheckBox;
  final bool showActions;
  final bool contentTappable;
  final double offsetLeft;
  final int? maxLines;

  final Function(TreeNodeData node) onTap;
  final void Function(bool? checked, TreeNodeData node) onCheck;

  final void Function(TreeNodeData node) onExpand;
  final void Function(TreeNodeData node) onCollapse;

  final Future Function(TreeNodeData node) load;
  final void Function(TreeNodeData node) onLoad;

  final void Function(TreeNodeData node) remove;
  final void Function(TreeNodeData node, TreeNodeData parent) onRemove;

  final void Function(TreeNodeData node) append;
  final void Function(TreeNodeData node, TreeNodeData parent) onAppend;

  const TreeNode({
    Key? key,
    required this.data,
    required this.parent,
    this.parentState,
    required this.offsetLeft,
    this.maxLines,
    required this.showCheckBox,
    required this.showActions,
    required this.contentTappable,
    required this.icon,
    required this.lazy,
    required this.load,
    required this.append,
    required this.remove,
    required this.onTap,
    required this.onCheck,
    required this.onLoad,
    required this.onExpand,
    required this.onAppend,
    required this.onRemove,
    required this.onCollapse,
  }) : super(key: key);

  @override
  State<TreeNode> createState() => _TreeNodeState();
}

class _TreeNodeState extends State<TreeNode> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool? _isChecked = false;
  bool _showLoading = false;
  late AnimationController _rotationController;
  final Tween<double> _turnsTween = Tween<double>(begin: -0.25, end: 0.0);

  List<TreeNode> _geneTreeNodes(List list) {
    return List.generate(list.length, (int index) {
      return TreeNode(
        data: list[index],
        parent: widget.data,
        parentState: widget.parentState != null ? this : null,
        remove: widget.remove,
        append: widget.append,
        icon: widget.icon,
        lazy: widget.lazy,
        load: widget.load,
        offsetLeft: widget.offsetLeft,
        maxLines: widget.maxLines,
        showCheckBox: widget.showCheckBox,
        showActions: widget.showActions,
        contentTappable: widget.contentTappable,
        onTap: widget.onTap,
        onCheck: widget.onCheck,
        onExpand: widget.onExpand,
        onLoad: widget.onLoad,
        onCollapse: widget.onCollapse,
        onRemove: widget.onRemove,
        onAppend: widget.onAppend,
      );
    });
  }

  @override
  initState() {
    super.initState();
    _isExpanded = widget.data.expanded;
    _isChecked = widget.data.checked;
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onExpand(widget.data);
        } else if (status == AnimationStatus.reverse) {
          widget.onCollapse(widget.data);
        }
      });
    if (_isExpanded) {
      _rotationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.parentState != null) _isChecked = widget.data.checked;

    bool hasData = widget.data.children.isNotEmpty || (widget.lazy && !_isExpanded);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          splashColor: widget.contentTappable ? null : Colors.transparent,
          highlightColor: widget.contentTappable ? null : Colors.transparent,
          mouseCursor: widget.contentTappable ? SystemMouseCursors.click : MouseCursor.defer,
          onTap: widget.contentTappable
              ? () {
                  if (hasData) {
                    widget.onTap(widget.data);
                    toggleExpansion();
                  } else {
                    _isChecked = _isChecked == null ? null : !_isChecked!;
                    widget.onCheck(_isChecked, widget.data);
                    setState(() {});
                  }
                }
              : () {},
          child: Container(
            margin: const EdgeInsets.only(bottom: 2.0),
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RotationTransition(
                  turns: _turnsTween.animate(_rotationController),
                  child: IconButton(
                    iconSize: 16,
                    icon: hasData ? widget.icon : Container(),
                    onPressed: hasData
                        ? () {
                            widget.onTap(widget.data);
                            toggleExpansion();
                          }
                        : null,
                  ),
                ),
                if (widget.showCheckBox)
                  Checkbox(
                    value: _isChecked,
                    checkColor: widget.data.checkBoxCheckColor,
                    fillColor: widget.data.checkBoxFillColor,
                    tristate: hasData,
                    onChanged: (bool? value) {
                      if (value == null) {
                        _isChecked = false;
                      } else if (_isChecked == null) {
                        _isChecked = true;
                      } else {
                        _isChecked = !_isChecked!;
                      }
                      if (widget.parentState != null) {
                        _checkUncheckChildren(widget.data.children);
                        _checkUncheckParent(widget.parent);
                        BlocProvider.of<TreeviewBloc>(context).add(UpdateTreeviewEvent());
                      }
                      widget.onCheck(_isChecked, widget.data);
                      setState(() {});
                    },
                  ),
                if (widget.lazy && _showLoading)
                  const SizedBox(
                    width: 12.0,
                    height: 12.0,
                    child: CircularProgressIndicator(strokeWidth: 1.0),
                  ),
                Expanded(
                  child: Container(
                    key: ValueKey(widget.data.backgroundColor?.call()),
                    color: widget.data.backgroundColor?.call(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(
                        widget.data.title,
                        maxLines: widget.maxLines ?? 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                if (widget.showActions)
                  TextButton(
                    onPressed: () {
                      widget.append(widget.data);
                      widget.onAppend(widget.data, widget.parent);
                    },
                    child: const Text('Add', style: TextStyle(fontSize: 12.0)),
                  ),
                if (widget.showActions)
                  TextButton(
                    onPressed: () {
                      widget.remove(widget.data);
                      widget.onRemove(widget.data, widget.parent);
                    },
                    child: const Text('Remove', style: TextStyle(fontSize: 12.0)),
                  ),
                if (widget.data.customActions?.isNotEmpty == true) ...widget.data.customActions!,
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _rotationController,
          child: Padding(
            padding: EdgeInsets.only(left: widget.offsetLeft),
            child: Column(children: _geneTreeNodes(widget.data.children)),
          ),
        )
      ],
    );
  }

  void toggleExpansion() {
    if (widget.lazy && widget.data.children.isEmpty) {
      setState(() {
        _showLoading = true;
      });
      widget.load(widget.data).then((value) {
        if (value) {
          _isExpanded = true;
          _rotationController.forward();
          widget.onLoad(widget.data);
        }
        _showLoading = false;
        setState(() {});
      });
    } else {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _rotationController.forward();
      } else {
        _rotationController.reverse();
      }
      setState(() {});
    }
  }

  void _checkUncheckChildren(List<TreeNodeData> children) {
    widget.data.checked = _isChecked;
    for (var child in children) {
      final elementChildren = child.children;
      final hasChildren = elementChildren.isNotEmpty;
      if (hasChildren) {
        child.checked = _isChecked;
        _checkUncheckChildren(elementChildren);
      } else {
        child.checked = _isChecked ?? false;
      }
    }
  }

  void _checkUncheckParent(TreeNodeData parent) {
    final lenChildren = parent.children.length;
    if (lenChildren > 0) {
      bool? isParentChecked;
      var counterFalse = 0;
      var counterTrue = 0;
      var counterNull = 0;
      for (final child in parent.children) {
        final isChecked = child.checked;
        if (isChecked == null) {
          counterNull += 1;
        } else if (isChecked) {
          counterTrue += 1;
        } else {
          counterFalse += 1;
        }
      }
      if (counterTrue == lenChildren || counterNull == lenChildren) {
        isParentChecked = true;
      } else if (counterFalse == lenChildren) {
        isParentChecked = false;
      } else {
        isParentChecked = null;
      }
      parent.checked = isParentChecked;
    }
    if (parent.parent != null) {
      final parentOfParent = parent.parent!;
      _checkUncheckParent(parentOfParent);
    }
  }
}
