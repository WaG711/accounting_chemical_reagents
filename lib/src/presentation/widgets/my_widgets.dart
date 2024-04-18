import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:flutter/material.dart';

class MyWidgets {
  static Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_rounded),
            title: const Text(
              'Собрать рецепт',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/recipe');
            },
          ),
          ListTile(
            leading: const Icon(Icons.warehouse_rounded),
            title: const Text(
              'Управление складом',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/warehouse');
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber_rounded),
            title: const Text(
              'Создать реагент',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  String name = '';
                  String formula = '';
                  return AlertDialog(
                    title: const Center(
                      child: Text('Создайте реагент'),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(labelText: 'Название'),
                          onChanged: (value) {
                            name = value;
                          },
                        ),
                        TextField(
                          decoration: const InputDecoration(labelText: 'Формула'),
                          onChanged: (value) {
                            formula = value;
                          },
                        ),
                      ],
                    ),
                    actions: [
                      Center(
                        child: ElevatedButton(
                            onPressed: () {
                              if (name.isNotEmpty && formula.isNotEmpty) {
                                Reagent reagent = Reagent(name: name, formula: formula);
                                ReagentRepository().insertReagent(reagent);
                                Navigator.of(context).pop();
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Ошибка"),
                                      content: const Text("Все поля должны быть заполнены"),
                                      actions: [
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("OK",
                                            style: TextStyle(
                                              color: Colors.black
                                            ),),
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[400]),
                            child: const Text(
                              'Создать реагент',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 22),
                            )),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
