import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../providers/character_provider.dart';
import '../models/character.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final characterProvider =
        Provider.of<CharacterProvider>(context, listen: true);
    final character = characterProvider.character;

    // Obtendo o userId do usuário autenticado
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      // Caso o usuário não esteja autenticado
      return Scaffold(
        appBar: AppBar(
          title: Text('Perfil'),
        ),
        body: Center(
          child: Text(
            'Erro: Usuário não autenticado.',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Perfil do Personagem',
              style: TextStyle(fontSize: 24, color: Colors.lightBlueAccent),
            ),
            SizedBox(height: 10),
            _buildStatBar(
                'HP', character.currentHp, character.totalHp, Colors.red),
            _buildStatBar(
                'MP', character.currentMp, character.totalMp, Colors.blue),
            _buildStatBar(
                'XP', character.xp, character.xpToNextLevel, Colors.grey),
            SizedBox(height: 20),
            _buildStatRow('Nível:', '${character.level}'),
            _buildStatRow('Força Total:', '${character.totalStrength}'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    _buildEquipmentSlot(context, userId, 'Sword', character),
                    _buildEquipmentSlot(context, userId, 'Acc', character),
                    _buildEquipmentSlot(context, userId, 'Glove', character),
                    _buildEquipmentSlot(context, userId, 'Ring', character),
                  ],
                ),
                Column(
                  children: [
                    Image.asset(
                      'assets/images/character.png',
                      height: 250,
                    ),
                  ],
                ),
                Column(
                  children: [
                    _buildEquipmentSlot(context, userId, 'Helmet', character),
                    _buildEquipmentSlot(context, userId, 'Chest', character),
                    _buildEquipmentSlot(context, userId, 'Legs', character),
                    _buildEquipmentSlot(context, userId, 'Shield', character),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Equipamentos:',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            _buildEquipmentList(character),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/combat');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/quests');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.shield),
            label: 'Combate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Quests',
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(
      String label, int currentValue, int maxValue, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Row(
        children: [
          Text('$label:'),
          SizedBox(width: 10),
          Expanded(
            child: LinearProgressIndicator(
              value: currentValue / maxValue,
              backgroundColor: Colors.grey[800],
              color: color,
            ),
          ),
          SizedBox(width: 10),
          Text('$currentValue / $maxValue'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18, color: Colors.white)),
          Text(value,
              style: TextStyle(fontSize: 18, color: Colors.lightBlueAccent)),
        ],
      ),
    );
  }

  Widget _buildEquipmentSlot(
      BuildContext context, String userId, String slot, Character character) {
    return GestureDetector(
      onTap: () =>
          _showEquipmentSelectionDialog(context, userId, slot, character),
      child: Column(
        children: [
          Icon(Icons.add_box_outlined, size: 50),
          Text(slot, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _showEquipmentSelectionDialog(
      BuildContext context, String userId, String slot, Character character) {
    final equipmentOptions = _getEquipmentOptions(slot, character);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecione um equipamento para $slot'),
          content: SingleChildScrollView(
            child: ListBody(
              children: equipmentOptions.map((equipment) {
                return GestureDetector(
                  onTap: () {
                    Provider.of<CharacterProvider>(context, listen: false)
                        .equipItem(userId: userId, slot: slot, item: equipment);
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      equipment,
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
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

  List<String> _getEquipmentOptions(String slot, Character character) {
    return character.inventory.where((item) {
      return _equipmentOptionsBySlot[slot]?.contains(item) ?? false;
    }).toList();
  }

  Widget _buildEquipmentList(Character character) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildDynamicEquipmentList(character),
      ),
    );
  }

  List<Widget> _buildDynamicEquipmentList(Character character) {
    final List<String> slots = [
      'Sword',
      'Helmet',
      'Chest',
      'Acc',
      'Legs',
      'Shield',
      'Ring',
      'Glove',
    ];

    return slots.map((slot) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(slot, style: TextStyle(fontSize: 16, color: Colors.white)),
            Text(character.equipment[slot] ?? 'Nenhum',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }).toList();
  }
}

const Map<String, List<String>> _equipmentOptionsBySlot = {
  'Sword': ['Espada Lendária', 'Espada Comum', 'Espada de Pedra'],
  'Helmet': ['Elmo de Guerreiro', 'Elmo de Ferro', 'Elmo de Mago'],
  'Chest': ['Peitoral de Aço', 'Peitoral Mágico'],
  'Acc': ['Anel Mágico', 'Anel de Poder'],
  'Ring': ['Anel de Prata'],
  'Shield': ['Escudo de Bronze'],
};
