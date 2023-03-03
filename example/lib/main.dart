import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_treeview_plus/flutter_treeview_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Treeview Plus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Treeview Plus'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final treeData = <TreeNodeData>[];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final strOrganizationChart = await rootBundle.loadString('assets/organization_chart.json');
      final organizationChartJson = json.decode(strOrganizationChart);
      final organizationChart = OrganizationChart(
        data: (organizationChartJson['data'] as List<dynamic>?)?.map((e) {
          return ItemOrganizationChart.fromJson(e);
        }).toList(),
      );
      final data = organizationChart.data ?? [];
      treeData.addAll(
        List.generate(
          data.length,
          (index) => mapOrganizationChartToTreeNodeData(data[index], null),
        ),
      );
      debugPrint('treeData: $treeData');
      setState(() {});
    });
    super.initState();
  }

  TreeNodeData mapOrganizationChartToTreeNodeData(ItemOrganizationChart itemOrganizationChart, TreeNodeData? parent) {
    final children = itemOrganizationChart.children ?? [];
    final treeNodeData = TreeNodeData(
      title: itemOrganizationChart.name ?? '-',
      expanded: itemOrganizationChart.isExpanded,
      checked: itemOrganizationChart.isChecked,
      children: [],
      parent: parent,
    );
    final nestedChildren = children.isEmpty
        ? <TreeNodeData>[]
        : children.map((e) => mapOrganizationChartToTreeNodeData(e, treeNodeData)).toList();
    treeNodeData.children = nestedChildren;
    return treeNodeData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: treeData.isEmpty
          ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : FlutterTreeviewPlus(
              data: treeData,
              showCheckBox: true,
              manageParentState: true,
            ),
    );
  }
}

class OrganizationChart {
  final List<ItemOrganizationChart>? data;

  OrganizationChart({required this.data});

  @override
  String toString() {
    return 'OrganizationChart{data: $data}';
  }
}

class ItemOrganizationChart {
  final int? id;
  final int? pid;
  final String? name;
  final List<ItemOrganizationChart>? children;
  bool isChecked;
  bool isExpanded;

  ItemOrganizationChart({
    required this.id,
    required this.pid,
    required this.name,
    required this.children,
    this.isChecked = false,
    this.isExpanded = false,
  });

  factory ItemOrganizationChart.fromJson(Map<String, dynamic> json) {
    return ItemOrganizationChart(
      id: json['id'],
      pid: json['id'],
      name: json['name'],
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => ItemOrganizationChart.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'ItemOrganizationChart{id: $id, pid: $pid, name: $name, children: $children, isChecked: $isChecked, '
        'isExpanded: $isExpanded}';
  }
}
