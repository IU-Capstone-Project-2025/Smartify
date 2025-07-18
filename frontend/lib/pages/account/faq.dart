import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text('FAQ', style: theme.textTheme.titleLarge),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildSectionHeader(context, '📌 Общие вопросы'),
          _buildTile(
            context,
            'Что такое Smartify?',
            'Smartify — это интеллектуальная образовательная платформа для старшеклассников (9–11 классы), которая помогает выбрать карьерный путь, вуз, подготовиться к ЕГЭ и найти подходящего репетитора. Всё в одном месте.',
          ),
          _buildTile(
            context,
            'Для кого предназначена платформа?',
            'Для учеников 9–11 классов из России, которые хотят чётко спланировать своё будущее: от выбора профессии до поступления в университет.',
          ),
          _buildTile(
            context,
            'Сколько стоит использование платформы?',
            'Базовый функционал бесплатен. Некоторые функции (например, доступ к расширенной аналитике или персональные консультации) могут быть доступны по подписке — об этом будет сообщено отдельно.',
          ),

          _buildSectionHeader(context, '🧠 Об искусственном интеллекте'),
          _buildTile(
            context,
            'Как работает ИИ в Smartify?',
            'ИИ анализирует ваши интересы, оценки и цели, чтобы:\n'
            '• рекомендовать профессии, подходящие именно вам\n'
            '• подобрать вузы с реальными шансами на поступление\n'
            '• составить персональный план подготовки к экзаменам',
          ),
          _buildTile(
            context,
            'Можно ли доверять рекомендациям?',
            'Да, рекомендации основаны на реальных данных (ваши баллы, интересы, требования вузов) и прозрачной логике. Вы также можете просмотреть объяснение, почему предлагается та или иная профессия.',
          ),

          _buildSectionHeader(context, '🎓 О карьере и вузах'),
          _buildTile(
            context,
            'Чем отличается профориентация Smartify от других сервисов?',
            'Мы предлагаем конкретные профессии (например, детский хирург, а не просто врач), объясняем, почему они вам подходят, и сразу показываем нужные предметы для поступления.',
          ),
          _buildTile(
            context,
            'Можно ли выбрать вуз по бюджету или региону?',
            'Да. Вы можете фильтровать вузы по регионам, наличию бюджетных мест, специальностям, проходным баллам и т. д.',
          ),

          _buildSectionHeader(context, '📚 О подготовке к ЕГЭ'),
          _buildTile(
            context,
            'Смогу ли я получить индивидуальный план подготовки?',
            'Да. На основе выбранной профессии и вуза Smartify рекомендует предметы и распределяет учебную нагрузку на неделю.',
          ),
          _buildTile(
            context,
            'Есть ли встроенные тесты?',
            'Да. Мини-тесты помогают быстро проверить знания и откорректировать план подготовки.',
          ),
          _buildTile(
            context,
            'Можно ли синхронизировать расписание с Google Календарём?',
            'Да. Вы можете автоматически перенести расписание занятий в Google Calendar.',
          ),

          _buildSectionHeader(context, '👩‍🏫 О репетиторах'),
          _buildTile(
            context,
            'Как вы находите репетиторов?',
            'Мы используем данные с hh.ru, чтобы находить реальных преподавателей с подробными анкетами, включая опыт, образование и стиль преподавания.',
          ),
          _buildTile(
            context,
            'Можно ли фильтровать список репетиторов?',
            'Да. Мы предоставляем фильтры по предметам, уровню преподавания и цене, чтобы вы могли выбрать подходящий вариант.',
          ),

          _buildSectionHeader(context, '⚙️ Дополнительные вопросы'),
          _buildTile(
            context,
            'Что такое “предсказание баллов”?',
            'ИИ оценивает ваш текущий уровень подготовки и прогнозирует вероятные баллы на ЕГЭ. Это помогает понять, где нужно усилиться.',
          ),
          _buildTile(
            context,
            'Можно ли пользоваться Smartify с компьютера?',
            'Пока нет, наша платформа адаптирована под мобильные устройства.',
          ),
          _buildTile(
            context,
            'Платформа точно будет бесплатной?',
            'Основной функционал — да. Некоторые расширенные возможности могут быть доступны по подписке, но мы всегда будем предлагать полезный базовый набор функций бесплатно.',
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'Smartify © 2025',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String question, String answer) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        collapsedBackgroundColor: theme.cardColor,
        backgroundColor: theme.cardColor,
        title: Text(question, style: theme.textTheme.bodyMedium),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(answer, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
