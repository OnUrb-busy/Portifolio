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

    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
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
          // Imagem do inimigo centralizada
          Center(
            child: Image.asset(
              'assets/images/enemy.png',
              width: 400,
              height: 400,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'HP do Jogador: ${characterProvider.character.currentHp} / ${characterProvider.character.totalHp}',
            style: TextStyle(fontSize: 20, color: Colors.green),
          ),
          Text(
            'HP do Inimigo: ${combatProvider.enemyHealth}',
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              combatProvider
                  .attackEnemy(characterProvider.character.totalStrength);

              // Atualiza o HP do personagem
              characterProvider.updateHp(userId: userId, hpChange: -10);

              if (combatProvider.enemyHealth <= 0) {
                final int xpReward = combatProvider.calculateXpReward();
                final String itemReward = combatProvider.generateItemReward();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Vitória! Você ganhou $xpReward XP e o item: $itemReward'),
                  ),
                );

                characterProvider.addXp(userId: userId, xpGained: xpReward);
                characterProvider.addReward(userId: userId, item: itemReward);
                combatProvider.resetCombat();
              } else if (characterProvider.character.currentHp <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Derrota! Você perdeu 10 XP!'),
                  ),
                );

                characterProvider.addXp(userId: userId, xpGained: -10);
                combatProvider.resetCombat();
              }
            },
            child: Text('Atacar'),
          ),
        ],
      ),
    );
  }
}
