import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/character_provider.dart';

class QuestScreen extends StatelessWidget {
  final List<Map<String, dynamic>> quests = [
    {
      'title': 'Run 5km',
      'description': 'Complete a 5km run.',
      'strength': 10,
      'experience': 20
    },
    {
      'title': 'Do 50 push-ups',
      'description': 'Perform 50 push-ups.',
      'strength': 15,
      'experience': 25
    },
    {
      'title': 'Swim for 30 minutes',
      'description': 'Swim continuously for 30 minutes.',
      'strength': 12,
      'experience': 18
    },
  ];

  @override
  Widget build(BuildContext context) {
    final characterProvider = Provider.of<CharacterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Quests'),
      ),
      body: ListView.builder(
        itemCount: quests.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10.0),
            child: ListTile(
              title: Text(quests[index]['title']),
              subtitle: Text(quests[index]['description']),
              trailing: ElevatedButton(
                onPressed: () {
                  // Ao completar a quest, aumentar os atributos do personagem
                  characterProvider.increaseStrength();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${quests[index]['title']} completed!')),
                  );
                },
                child: Text('Complete'),
              ),
            ),
          );
        },
      ),
    );
  }
}
