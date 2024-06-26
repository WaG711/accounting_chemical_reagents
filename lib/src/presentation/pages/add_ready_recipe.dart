import 'package:accounting_chemical_reagents/src/domain/model/ready_recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/model/ready_recipe_reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/reagent.dart';
import 'package:accounting_chemical_reagents/src/domain/model/reagents_recipe.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/ready_recipe_reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/ready_recipe_repository.dart';
import 'package:accounting_chemical_reagents/src/domain/repository/reagent_repository.dart';
import 'package:accounting_chemical_reagents/src/presentation/widgets/my_widgets.dart';
import 'package:flutter/material.dart';

class AddReadyRecipe extends StatefulWidget {
  const AddReadyRecipe({super.key});

  @override
  State<AddReadyRecipe> createState() => _AddReadyRecipeState();
}

class _AddReadyRecipeState extends State<AddReadyRecipe> {
  final TextEditingController _textEditingController = TextEditingController();
  final List<ReagentsRecipe> _reagentsReadyRecipe = [];
  Reagent? _selectedReagent;
  int? _quantity;
  String _name = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      appBar: _buildAppBar(),
      body: _buildReagentsReadyRecipe(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Добавить рецепт',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            MyWidgets.openBottomDrawer(context);
          },
        ),
      ],
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildReagentsReadyRecipe() {
    return Column(
      children: [
        Expanded(child: _buildResources()),
        _buildRowNameReadyRecipe(),
        _buildInterfaceReagentsReadyRecipe()
      ],
    );
  }

  Widget _buildResources() {
    if (_reagentsReadyRecipe.isEmpty) {
      return const Center(
        child: Text(
          'Добавьте реагент',
          style: TextStyle(fontSize: 28),
        ),
      );
    }

    return ListView.builder(
      itemCount: _reagentsReadyRecipe.length,
      itemBuilder: (context, index) {
        ReagentsRecipe element = _reagentsReadyRecipe[index];
        return Dismissible(
          key: UniqueKey(),
          child: Card(
            color: const Color.fromARGB(255, 239, 246, 255),
            child: ListTile(
              title: FutureBuilder<Reagent>(
                future: ReagentRepository().getReagentById(element.reagentId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Ошибка: ${snapshot.error}');
                  } else {
                    return Text(
                        '${snapshot.data!.formula} • ${snapshot.data!.name}',
                        style: const TextStyle(fontSize: 21));
                  }
                },
              ),
              subtitle: Text('Количество: ${element.quantity}',
                  style: const TextStyle(fontSize: 17)),
              trailing: IconButton(
                onPressed: () {
                  _showUpdateReagentsReadyRecipeDialog(element, index);
                },
                icon: const Icon(Icons.change_circle_rounded, size: 40),
              ),
            ),
          ),
          onDismissed: (direction) {
            setState(() {
              _reagentsReadyRecipe.removeAt(index);
            });
          },
        );
      },
    );
  }

  void _showUpdateReagentsReadyRecipeDialog(ReagentsRecipe element, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Center(
                child: Text('Введите количество'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Актуальное количество: ${element.quantity}'),
                  _buildUpdateQuantityTextField(setState),
                ],
              ),
              actions: [
                Center(
                  child: _buildUpdateReagentsReadyRecipeDialogButton(element, index),
                )
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUpdateQuantityTextField(Function setState) {
    return TextField(
      decoration: MyWidgets.buildInputDecoration('Введите количество'),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          _quantity = int.tryParse(value);
        });
      },
    );
  }

  Widget _buildUpdateReagentsReadyRecipeDialogButton(
      ReagentsRecipe element, int index) {
    return ElevatedButton(
      onPressed: () {
        if (_quantity != null) {
          ReagentsRecipe newReagent = ReagentsRecipe(
            reagentId: element.reagentId,
            quantity: _quantity!,
          );
          setState(() {
            _reagentsReadyRecipe[index] = newReagent;
          });
          Navigator.of(context).pop();
        } else {
          MyWidgets.buildErorDialog(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[300],
      ),
      child: const Text(
        'Сохранить',
        style: TextStyle(color: Colors.white, fontSize: 22),
      ),
    );
  }

  Widget _buildRowNameReadyRecipe() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 1, 20, 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textEditingController,
            decoration:
                MyWidgets.buildInputDecoration('Название готового рецепта'),
            onChanged: (value) {
              _name = value;
            },
          )
        ],
      ),
    );
  }

  Widget _buildInterfaceReagentsReadyRecipe() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 1, 10, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAddReadyRecipeButton(),
          _buildAddToReagentsReadyRecipeButton()
        ],
      ),
    );
  }

  Widget _buildAddReadyRecipeButton() {
    return ElevatedButton(
        onPressed: () {
          if (_reagentsReadyRecipe.isNotEmpty && _name.isNotEmpty) {
            _addReadyRecipeReagent();
          } else {
            MyWidgets.buildErorDialog(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[300],
        ),
        child: const Text(
          'Сохранить рецепт',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ));
  }

  Future<void> _addReadyRecipeReagent() async {
    ReadyRecipeModel readyRecipe = ReadyRecipeModel(name: _name.trim());
    int readyRecipeId =
        await ReadyRecipeRepository().insertReadyRecipe(readyRecipe);

    for (var element in _reagentsReadyRecipe) {
      ReadyRecipeReagent readyRecipeReagent = ReadyRecipeReagent(
          readyRecipeId: readyRecipeId,
          reagentId: element.reagentId,
          quantity: element.quantity);
      await ReadyRecipeReagentRepository()
          .insertReadyRecipeReagent(readyRecipeReagent);
    }
    setState(() {
      _reagentsReadyRecipe.clear();
      _textEditingController.clear();
    });
  }

  Widget _buildAddToReagentsReadyRecipeButton() {
    return IconButton(
      onPressed: _showAddToReagentsReadyRecipeDialog,
      icon: const Icon(
        Icons.add_rounded,
        size: 40,
      ),
    );
  }

  void _showAddToReagentsReadyRecipeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        _selectedReagent = null;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Center(
                child: Text('Добавление в рецепт'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildReagentDropdown(setState),
                  _buildQuantityTextField(setState),
                ],
              ),
              actions: [
                _buildAddToReagentsReadyRecipeDialogButton(),
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
              value: _selectedReagent?.id,
              items: reagents.map((reagent) {
                return DropdownMenuItem<int>(
                  value: reagent.id,
                  child: Text(reagent.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReagent = reagents.firstWhere((reagent) => reagent.id == value);
                });
              },
              decoration: MyWidgets.buildInputDecoration('Выберите реагент'),
              isExpanded: true,
            );
          }
        });
  }

  Widget _buildQuantityTextField(Function setState) {
    return TextField(
      decoration: MyWidgets.buildInputDecoration('Количество'),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          _quantity = int.tryParse(value);
        });
      },
    );
  }

  Widget _buildAddToReagentsReadyRecipeDialogButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_selectedReagent != null && _quantity != null) {
            int existingIndex = _reagentsReadyRecipe.indexWhere(
                (element) => element.reagentId == _selectedReagent!.id);

            if (existingIndex != -1) {
              setState(() {
                _reagentsReadyRecipe[existingIndex].quantity += _quantity!;
              });
            } else {
              ReagentsRecipe newReagent = ReagentsRecipe(
                reagentId: _selectedReagent!.id!,
                quantity: _quantity!,
              );
              setState(() {
                _reagentsReadyRecipe.add(newReagent);
              });
            }
            Navigator.of(context).pop();
          } else {
            MyWidgets.buildErorDialog(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[300],
        ),
        child: const Text(
          'Добавить в рецепт',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}
