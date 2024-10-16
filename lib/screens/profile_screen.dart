import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nome do personagem
          Text(
            'Nome de perfil',
            style: TextStyle(fontSize: 24, color: Colors.lightBlueAccent),
          ),
          SizedBox(height: 10),

          // Equipamentos ao redor do personagem
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  _buildEquipmentSlot(context, 'Sword'),
                  _buildEquipmentSlot(context, 'Acc'),
                  _buildEquipmentSlot(context, 'Glove'),
                  _buildEquipmentSlot(context, 'Wrist'),
                ],
              ),

              // Personagem pixelado
              Column(
                children: [
                  Image.asset(
                    'assets/images/character.png', // Imagem do personagem
                    height: 250,
                  ),
                ],
              ),

              Column(
                children: [
                  _buildEquipmentSlot(context, 'Helmet'),
                  _buildEquipmentSlot(context, 'Chest'),
                  _buildEquipmentSlot(context, 'Legs'),
                  _buildEquipmentSlot(context, 'Boots'),
                ],
              ),
            ],
          ),

          SizedBox(height: 20),

          // Informações de Power LV, Damage, Class
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatInfo('Power LV:', '1190'),
              _buildStatInfo('Damage:', '85.0'),
              _buildStatInfo('Class:', 'D'),
            ],
          ),

          SizedBox(height: 20),

          // Barras de HP e MP
          _buildStatBar('HP', 90, Colors.red),
          _buildStatBar('MP', 9, Colors.blue),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Avatar'),
          BottomNavigationBarItem(icon: Icon(Icons.lock), label: 'Settings'),
        ],
      ),
    );
  }

  // Função para criar os slots de equipamento
  Widget _buildEquipmentSlot(BuildContext context, String item) {
    return GestureDetector(
      onTap: () => _showEquipmentSelectionDialog(context, item),
      child: Column(
        children: [
          Icon(Icons.add_box_outlined, size: 50),
          Text(item),
        ],
      ),
    );
  }

  // Função para exibir o diálogo de seleção de equipamentos
  void _showEquipmentSelectionDialog(BuildContext context, String item) {
    final equipmentOptions = _getEquipmentOptions(item);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecione um equipamento para $item'),
          content: SingleChildScrollView(
            child: ListBody(
              children: equipmentOptions.map((equipment) {
                return _buildEquipmentOption(context, item, equipment);
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Função para obter opções de equipamentos baseadas no slot
  List<String> _getEquipmentOptions(String item) {
    switch (item) {
      case 'Sword':
        return ['Espada Lendária', 'Espada Comum', 'Espada de Pedra'];
      case 'Acc':
        return ['Anel Mágico', 'Anel de Poder', 'Anel de Defesa'];
      case 'Glove':
        return ['Luvas de Agilidade', 'Luvas de Força'];
      case 'Wrist':
        return ['Bracelete Místico', 'Bracelete de Vida'];
      case 'Helmet':
        return ['Elmo de Guerreiro', 'Elmo de Mago'];
      case 'Chest':
        return ['Peitoral de Aço', 'Peitoral Mágico'];
      case 'Legs':
        return ['Calças de Combate', 'Calças Mágicas'];
      case 'Boots':
        return ['Botas de Velocidade', 'Botas de Defesa'];
      default:
        return [];
    }
  }

  Widget _buildEquipmentOption(
      BuildContext context, String item, String equipment) {
    return GestureDetector(
      onTap: () {
        final characterProvider =
            Provider.of<CharacterProvider>(context, listen: false);
        switch (item) {
          case 'Sword':
            characterProvider.equipSword(equipment);
            break;
          case 'Acc':
            characterProvider.equipAcc(equipment);
            break;
          case 'Glove':
            characterProvider.equipGlove(equipment);
            break;
          case 'Wrist':
            characterProvider.equipWrist(equipment);
            break;
          case 'Helmet':
            characterProvider.equipHelmet(equipment);
            break;
          case 'Chest':
            characterProvider.equipChest(equipment);
            break;
          case 'Legs':
            characterProvider.equipLegs(equipment);
            break;
          case 'Boots':
            characterProvider.equipBoots(equipment);
            break;
        }
        Navigator.of(context).pop(); // Fechar o diálogo após a seleção
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          equipment,
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Função para exibir informações de status
  Widget _buildStatInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 18, color: Colors.lightBlueAccent),
        ),
      ],
    );
  }

  // Função para construir as barras de status (HP e MP)
  Widget _buildStatBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Row(
        children: [
          Text('$label:'),
          SizedBox(width: 10),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey,
              color: color,
            ),
          ),
          SizedBox(width: 10),
          Text('$value'),
        ],
      ),
    );
  }
}
