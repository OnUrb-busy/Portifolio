import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/providers/character_provider.dart';
import 'package:flutter_application_1/models/character.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late CharacterProvider characterProvider;
  late FakeFirebaseFirestore fakeFirestore;
  late String userId;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    userId = 'test_user';
    characterProvider = CharacterProvider(firestore: fakeFirestore);
  });

  group('Testes do CharacterProvider', () {
    test(
        'Adicionar XP aumenta o XP e faz subir de nível se o limite for atingido',
        () {
      characterProvider.addXp(userId: userId, xpGained: 110);

      expect(characterProvider.character.xp, equals(10));
      expect(characterProvider.character.level, equals(2));
    });

    test('Aplicar penalidade de XP diminui o XP sem ficar abaixo de zero', () {
      characterProvider.addXp(userId: userId, xpGained: 50);
      characterProvider.applyXpPenalty(userId: userId, penalty: 60);

      expect(characterProvider.character.xp, equals(0));
    });

    test('Equipar item atualiza o slot de equipamento corretamente', () {
      characterProvider.equipItem(
        userId: userId,
        slot: 'Espada',
        item: 'Espada Lendária',
      );

      expect(characterProvider.character.equipment['Espada'],
          equals('Espada Lendária'));
    });

    test('Atualizar HP modifica o HP dentro dos limites válidos', () {
      characterProvider.updateHp(userId: userId, hpChange: -30);

      expect(characterProvider.character.currentHp, equals(40));

      characterProvider.updateHp(userId: userId, hpChange: 100);
      expect(characterProvider.character.currentHp,
          equals(characterProvider.character.totalHp));
    });

    test(
        'Adicionar recompensa adiciona o item ao inventário se ainda não estiver presente',
        () {
      characterProvider.addReward(userId: userId, item: 'Poção de Vida');

      expect(characterProvider.character.inventory, contains('Poção de Vida'));

      // Tenta adicionar o mesmo item novamente
      characterProvider.addReward(userId: userId, item: 'Poção de Vida');

      expect(characterProvider.character.inventory.length, equals(1));
    });
  });
}
