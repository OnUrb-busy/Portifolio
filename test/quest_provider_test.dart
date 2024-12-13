import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_application_1/providers/quest_provider.dart';
import 'package:flutter_application_1/providers/character_provider.dart';
import 'package:mocktail/mocktail.dart';

// Mock para CharacterProvider
class MockCharacterProvider extends Mock implements CharacterProvider {}

void main() {
  late QuestProvider questProvider;
  late FakeFirebaseFirestore fakeFirestore;
  late MockCharacterProvider mockCharacterProvider;
  late String userId;

  setUpAll(() {
    // Registra valores padrão para tipos utilizados nos matchers
    registerFallbackValue('');
    registerFallbackValue(0);
  });

  setUp(() {
    // Inicializa mocks e variáveis antes de cada teste
    fakeFirestore = FakeFirebaseFirestore();
    mockCharacterProvider = MockCharacterProvider();
    userId = 'test_user';
    questProvider = QuestProvider(
      userId: userId,
      characterProvider: mockCharacterProvider,
      firestore: fakeFirestore,
    );
  });

  group('Testes do QuestProvider', () {
    test('Renovar quests cria uma nova lista de quests', () async {
      await questProvider.checkAndRenewQuests();

      expect(questProvider.quests.length, equals(3));
      expect(questProvider.quests[0].name, equals('30 flexões'));
      expect(questProvider.quests[1].name, equals('60 agachamentos'));
      expect(questProvider.quests[2].name, equals('40 abdominais'));
    });

    test('Completar quest marca a quest como concluída', () {
      questProvider.quests.add(Quest(
        name: 'Teste de Quest',
        description: 'Descrição de Teste',
        rewardPoints: 50,
        penaltyPoints: 10,
      ));

      questProvider.completeQuest(0);

      expect(questProvider.quests[0].isCompleted, isTrue);
    });
  });
}
