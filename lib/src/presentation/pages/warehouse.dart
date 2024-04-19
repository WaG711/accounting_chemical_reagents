import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/model/warehouse.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/recipe_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/warehouse_repository.dart';
import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class Warehouse extends StatefulWidget {
  const Warehouse({super.key});

  @override
  State<Warehouse> createState() => _WarehouseState();
}

class _WarehouseState extends State<Warehouse> {
  late Future<List<WarehouseModel>> _fetchDataFuture;
  Reagent? selectedReagent;
  int? quantity;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchWarehouseData();
  }

  Future<List<WarehouseModel>> _fetchWarehouseData() async {
    return WarehouseRepository().getElements();
  }

  void _refreshData() {
    setState(() {
      _fetchDataFuture = _fetchWarehouseData();
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Управление складом',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green[300],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildWaitingRecipes() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Ожидающие рецепты',
            style: TextStyle(fontSize: 20),
          ),
        ),
        Expanded(
            child: FutureBuilder<List<RecipeModel>>(
          future: RecipeRepository().getRecipes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Ошибка: ${snapshot.error}');
            } else {
              List<RecipeModel>? recipes = snapshot.data;
              if (recipes == null || recipes.isEmpty) {
                return const Center(
                  child: Text(
                    'Пусто',
                    style: TextStyle(fontSize: 28),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    RecipeModel recipe = recipes[index];
                    return ListTile(
                      key: UniqueKey(),
                      title: Text('Рецепт ${recipe.id}'),
                      subtitle: Text('Реагенты: ${recipe.reagents.join(", ")}'),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Принять'),
                      ),
                    );
                  },
                );
              }
            }
          },
        ))
      ],
    );
  }

  Widget _buildAddToWarehouseButton() {
    return ElevatedButton(
      onPressed: _showAddToWarehouseDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[300],
      ),
      child: const Text(
        'Добавить на склад',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _showAddToWarehouseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        selectedReagent = null;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Center(
                child: Text('Добавление на склад'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildReagentDropdown(setState),
                  _buildQuantityTextField(setState),
                ],
              ),
              actions: [
                _buildAddToWarehouseDialogButton(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildReagentDropdown(Function setState) {
    return FutureBuilder<List<Reagent>>(
      future: ReagentRepository().getReagents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        } else {
          List<Reagent> reagents = snapshot.data!;
          return DropdownButtonFormField<int>(
            value: selectedReagent?.id,
            items: reagents.map((reagent) {
              return DropdownMenuItem<int>(
                value: reagent.id,
                child: Text(reagent.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedReagent = reagents.firstWhere((reagent) => reagent.id == value);
              });
            },
            decoration: const InputDecoration(
              labelText: 'Выберите реагент',
            ),
          );
        }
      },
    );
  }

  Widget _buildQuantityTextField(Function setState) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Количество',
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          quantity = int.tryParse(value);
        });
      },
    );
  }

  Widget _buildAddToWarehouseDialogButton() {
    return ElevatedButton(
      onPressed: () {
        if (selectedReagent != null && quantity != null) {
          WarehouseModel warehouse = WarehouseModel(
            reagentId: selectedReagent!.id!,
            quantity: quantity!,
          );
          WarehouseRepository().insertElement(warehouse);
          _refreshData();
          Navigator.of(context).pop();
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Ошибка'),
                content: const Text('Все поля должны быть заполнены'),
                actions: [
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  )
                ],
              );
            },
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[300],
      ),
      child: const Text(
        'Добавить на склад',
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }

  Widget _buildInterfaceWarehouseResource() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Ресурсы на складе',
            style: TextStyle(fontSize: 20),
          ),
          _buildAddToWarehouseButton(),
        ],
      ),
    );
  }

  Widget _buildResources() {
    return FutureBuilder<List<WarehouseModel>>(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        } else {
          List<WarehouseModel>? elements = snapshot.data;
          if (elements == null || elements.isEmpty) {
            return const Center(
              child: Text(
                'Пусто',
                style: TextStyle(fontSize: 28),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: elements.length,
              itemBuilder: (context, index) {
                WarehouseModel element = elements[index];
                return Dismissible(
                  key: UniqueKey(),
                  child: Card(
                    child: ListTile(
                      title: FutureBuilder<Reagent>(
                        future: ReagentRepository().getReagentById(element.reagentId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Ошибка: ${snapshot.error}');
                          } else {
                            return Text('${snapshot.data!.name} - ${snapshot.data!.formula}');
                          }
                        },
                      ),
                      subtitle: Text('Количество: ${element.quantity}'),
                      trailing: IconButton(
                        onPressed: () {
                          _refreshData();
                        },
                        icon: const Icon(Icons.update),
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    WarehouseRepository().deleteElement(element.id!);
                    _refreshData();
                  },
                );
              },
            );
          }
        }
      },
    );
  }

  Widget _buildWarehouseResources() {
    return Column(
      children: [
        _buildInterfaceWarehouseResource(),
        Expanded(child: _buildResources())
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      endDrawer: MyWidgets.buildDrawer(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildWaitingRecipes()),
          Expanded(child: _buildWarehouseResources()),
        ],
      ),
    );
  }
}
