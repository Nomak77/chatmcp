import 'openai_client.dart';
import 'claude_client.dart';
import 'base_llm_client.dart';
import 'package:ChatMcp/provider/provider_manager.dart';
import 'package:logging/logging.dart';

enum LLMProvider { openAI, claude, llama }

class LLMFactory {
  static BaseLLMClient create(LLMProvider provider,
      {required String apiKey, required String baseUrl}) {
    switch (provider) {
      case LLMProvider.openAI:
        return OpenAIClient(apiKey: apiKey, baseUrl: baseUrl);
      case LLMProvider.claude:
        return ClaudeClient(apiKey: apiKey, baseUrl: baseUrl);
      default:
        throw Exception('Unsupported LLM provider');
    }
  }
}

class LLMFactoryHelper {
  static BaseLLMClient createFromModel(String currentModel) {
    // 根据模型名称判断 provider
    final provider = currentModel.startsWith('gpt') ? 'openai' : 'claude';

    // 获取配置信息
    final apiKey =
        ProviderManager.settingsProvider.apiSettings[provider]?.apiKey ?? '';
    final baseUrl =
        ProviderManager.settingsProvider.apiSettings[provider]?.apiEndpoint ??
            '';

    Logger.root.fine(
        'Using API Key: $apiKey for provider: $provider model: $currentModel');

    // 创建 LLM 客户端
    return LLMFactory.create(
        provider == 'openai' ? LLMProvider.openAI : LLMProvider.claude,
        apiKey: apiKey,
        baseUrl: baseUrl);
  }

  static Future<List<String>> getAvailableModels() async {
    List<String> providers = ["claude"];
    List<String> models = [];
    for (var provider in providers) {
      final apiKey =
          ProviderManager.settingsProvider.apiSettings[provider]?.apiKey ?? '';
      final baseUrl =
          ProviderManager.settingsProvider.apiSettings[provider]?.apiEndpoint ??
              '';
      final client = LLMFactory.create(
          provider == "openai" ? LLMProvider.openAI : LLMProvider.claude,
          apiKey: apiKey,
          baseUrl: baseUrl);
      models.addAll(await client.models());
    }

    return models;
  }
}
