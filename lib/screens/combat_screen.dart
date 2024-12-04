import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/combat_provider.dart';
import '../providers/character_provider.dart';

class CombatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final combatProvider = Provider.of<CombatProvider>(context);
    final characterProvider =
        Provider.of<CharacterProvider>(context, listen: false);

    // Obtendo o userId do usuário autenticado
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // Caso o usuário não esteja autenticado, retorna uma mensagem de erro
      return Scaffold(
        appBar: AppBar(
          title: Text('Combate'),
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
        title: Text('Combate'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'HP do Jogador: ${characterProvider.character.currentHp} / ${characterProvider.character.totalHp}',
            style: TextStyle(fontSize: 20, color: Colors.green),
          ),
          Text(
            'HP do Inimigo: ${combatProvider.enemyHealth}',
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  combatProvider
                      .attackEnemy(characterProvider.character.totalStrength);

                  // Atualiza o HP do personagem
                  characterProvider.updateHp(userId: userId, hpChange: -10);

                  if (combatProvider.enemyHealth <= 0) {
                    final int xpReward = combatProvider.calculateXpReward();
                    final String itemReward =
                        combatProvider.generateItemReward();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Vitória! Você ganhou $xpReward XP e o item: $itemReward'),
                      ),
                    );

                    // Adiciona recompensa ao personagem
                    characterProvider.addXp(userId: userId, xpGained: xpReward);
                    characterProvider.addReward(
                        userId: userId, item: itemReward);
                    combatProvider.resetCombat();
                  } else if (characterProvider.character.currentHp <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Derrota! Você perdeu 10 XP!'),
                      ),
                    );

                    // Remove XP do personagem em caso de derrota
                    characterProvider.addXp(userId: userId, xpGained: -10);
                    combatProvider.resetCombat();
                  }
                },
                child: Text('Atacar'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  combatProvider.resetCombat();
                },
                child: Text('Resetar Combate'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
