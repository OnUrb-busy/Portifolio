import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/providers/combat_provider.dart';

void main() {
  late CombatProvider combatProvider;

  setUp(() {
    combatProvider = CombatProvider();
  });

  group('Testes do CombatProvider', () {
    test('Atacar inimigo reduz a saúde do inimigo', () {
      expect(combatProvider.enemyHealth, 100,
          reason: 'A saúde inicial do inimigo deve ser 100.');

      combatProvider.attackEnemy(30);

      expect(combatProvider.enemyHealth, 70,
          reason:
              'A saúde do inimigo deve ser reduzida para 70 após 30 de dano.');
    });

    test('Atacar inimigo não reduz a saúde abaixo de zero', () {
      combatProvider.attackEnemy(120);

      expect(combatProvider.enemyHealth, 0,
          reason:
              'A saúde do inimigo não deve ser negativa após dano maior que a saúde inicial.');
    });

    test('Reiniciar combate restaura a saúde do inimigo para 100', () {
      combatProvider.attackEnemy(50);

      combatProvider.resetCombat();

      expect(combatProvider.enemyHealth, 100,
          reason:
              'Reiniciar o combate deve restaurar a saúde do inimigo para 100.');
    });

    test('Gerar recompensa de item retorna uma recompensa válida', () {
      const recompensasPossiveis = [
        'Espada Comum',
        'Elmo de Ferro',
        'Anel de Prata',
        'Escudo de Bronze',
      ];

      final recompensa = combatProvider.generateItemReward();

      expect(recompensasPossiveis.contains(recompensa), true,
          reason:
              'A recompensa gerada deve estar na lista de recompensas possíveis.');
    });

    test(
        'Calcular recompensa de XP retorna XP correto com base no nível do inimigo',
        () {
      combatProvider.enemyLevel = 3;

      final recompensaXp = combatProvider.calculateXpReward();

      expect(recompensaXp, 60,
          reason:
              'A recompensa de XP deve ser 3 * 20 para um inimigo de nível 3.');
    });
  });
}
