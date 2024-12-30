import 'package:flutter_test/flutter_test.dart';
import 'package:ChatMcp/llm/claude_client.dart';
import 'package:ChatMcp/llm/model.dart';
import 'package:dotenv/dotenv.dart';

void main() {
  late ClaudeClient client;
  setUpAll(() {
    var env = DotEnv()..load();
    final apiKey = env['CLAUDE_API_KEY'] ?? '';
    client = ClaudeClient(apiKey: apiKey);
  });

  group('ClaudeClient', () {
    test('chatCompletion returns valid response', () async {
      final request = CompletionRequest(
        model: 'claude-3-5-haiku-latest',
        messages: [
          ChatMessage(
            role: MessageRole.user,
            content: 'Say hello',
          ),
        ],
      );

      final response = await client.chatCompletion(request);
      expect(response.content, isNotNull);
      expect(response.content, isNotEmpty);
    });

    test('genTitle returns valid title', () async {
      final messages = [
        ChatMessage(
          role: MessageRole.user,
          content: 'What is Flutter?',
        ),
        ChatMessage(
          role: MessageRole.assistant,
          content: 'Flutter is a UI framework from Google for building natively compiled applications.',
        ),
      ];

      final title = await client.genTitle(messages);
      expect(title, isNotNull);
      expect(title.length, lessThanOrEqualTo(20));
    });

    test('models returns available models', () async {
      final models = await client.models();
      expect(models, isNotEmpty);
      expect(models.any((model) => model.contains('claude')), isTrue);
    });

    test('chatStreamCompletion yields responses', () async {
      final request = CompletionRequest(
        model: 'claude-3-5-haiku-latest',
        messages: [
          ChatMessage(
            role: MessageRole.user,
            content: 'Count from 1 to 3',
          ),
        ],
      );

      final stream = client.chatStreamCompletion(request);
      int chunks = 0;
      
      await for (final response in stream) {
        expect(response.content, isNotNull);
        chunks++;
      }

      expect(chunks, greaterThan(0));
    });
  });
}