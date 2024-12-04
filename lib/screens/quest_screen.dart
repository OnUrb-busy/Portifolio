import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/quest_provider.dart';
import '../providers/character_provider.dart';

class QuestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final questProvider = Provider.of<QuestProvider>(context);
    final characterProvider =
        Provider.of<CharacterProvider>(context, listen: false);

    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quests'),
        ),
        body: Center(
          child: Text(
            'Erro: Usuário não autenticado.',
            style: TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (questProvider.quests.isEmpty) {
        await questProvider.loadQuests(userId);
        if (questProvider.quests.isEmpty) {
          questProvider.generateDailyQuests(userId);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Quests'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.blueGrey[800],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Status Geral',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                        'Quests Completadas: ${questProvider.quests.where((q) => q.isCompleted).length}'),
                    Text(
                        'Quests Pendentes: ${questProvider.quests.where((q) => !q.isCompleted && !q.isCancelled).length}'),
                    Text(
                        'XP Real Ganhado: ${questProvider.quests.where((q) => q.isCompleted).fold<int>(0, (sum, q) => sum + q.rewardPoints)}'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: questProvider.quests.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: questProvider.quests.length,
                    itemBuilder: (context, index) {
                      final quest = questProvider.quests[index];

                      return Card(
                        color: quest.isCompleted
                            ? Colors.green[100]
                            : quest.isCancelled
                                ? Colors.red[100]
                                : null,
                        child: ListTile(
                          title: Text(quest.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quest.isCancelled
                                    ? 'Tempo esgotado! Quest cancelada.'
                                    : 'Tempo restante: ${quest.remainingTime}s\n${quest.description}',
                              ),
                              if (!quest.isCancelled && !quest.isCompleted)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Recompensa: +${quest.rewardPoints} XP\nPunição: -${quest.penaltyPoints} XP',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                          trailing: quest.isCompleted
                              ? Icon(Icons.check, color: Colors.green)
                              : quest.isCancelled
                                  ? Icon(Icons.close, color: Colors.red)
                                  : ElevatedButton(
                                      onPressed: () {
                                        questProvider.completeQuest(
                                            userId, index);
                                        characterProvider.addXp(
                                            userId: userId,
                                            xpGained: quest.rewardPoints);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Quest completada! Você ganhou ${quest.rewardPoints} XP.')),
                                        );
                                      },
                                      child: Text('Completar'),
                                    ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
