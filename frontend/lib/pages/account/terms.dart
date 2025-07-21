import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Политика\nконфиденциальности',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        toolbarHeight: 72,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Дата последнего обновления: 10 июля 2025 г.\n',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Настоящая Политика конфиденциальности описывает, как приложение Smartify (далее — «Приложение», «мы», «нас») собирает, использует, хранит и защищает персональные данные пользователей. Используя Приложение и регистрируясь в нём, вы соглашаетесь с условиями настоящей Политики.\n',
                  style: theme.textTheme.bodyMedium,
                ),
                _sectionTitle('1. Какие данные мы собираем:'),
                _subsection('1.1. Персональные данные, которые вы предоставляете:'),
                _bullets([
                  'Имя, номер телефона (по желанию).',
                  'Адрес электронной почты (необходим для регистрации).',
                  'Учебные предпочтения и цели (например, выбранные предметы, интересы, профессии).',
                  'Данные для профориентационного теста и результата.',
                  'Данные задач и активности в календаре (раздел "Прогресс").',
                  'Сообщения в чате с репетиторами и техподдержкой.',
                  'При заполнении заявки на репетитора: контактные данные, предмет, комментарии.',
                ], theme),
                const SizedBox(height: 8),
                _subsection('1.2. Данные репетиторов (с их согласия):'),
                _bullets([
                  'Имя, предмет преподавания, контактные данные (телефон, email).',
                  'Сообщения в чате с пользователями.',
                ], theme),
                const SizedBox(height: 8),
                _subsection('1.3. Технические данные:'),
                _bullets([
                  'Устройство, операционная система, язык интерфейса.',
                  'IP-адрес и идентификаторы для аналитики.',
                ], theme),
                const SizedBox(height: 16),
                _sectionTitle('2. Как мы используем данные:'),
                _bullets([
                  'Для предоставления персонализированного опыта и рекомендаций (в разделах "Университеты", "Карьера", "Прогресс").',
                  'Для отображения списка репетиторов и обработки заявок.',
                  'Для поддержки чата и технической помощи.',
                  'Для улучшения работы приложения и аналитики использования (анонимизированно).',
                  'Для соблюдения юридических обязательств (например, хранение согласий на обработку данных).',
                ], theme),
                const SizedBox(height: 16),
                _sectionTitle('3. Хранение и защита данных:'),
                _bullets([
                  'Данные хранятся на защищённых серверах, с применением шифрования и других технических мер.',
                  'Доступ к персональным данным есть только у уполномоченных сотрудников и только в целях, описанных выше.',
                  'Мы не передаём персональные данные третьим лицам без вашего согласия, за исключением случаев, предусмотренных законом.',
                ], theme),
                const SizedBox(height: 16),
                _sectionTitle('4. Права пользователей:'),
                Text(
                  'Вы имеете право:',
                  style: theme.textTheme.bodyMedium,
                ),
                _bullets([
                  'Изменить или удалить данные.',
                  'Отозвать согласие на обработку и удалить аккаунт.',
                  'Ограничить обработку своих данных.',
                ], theme),
                Text(
                  '\nДля этого вы можете обратиться в техническую поддержку через чат или по почте: projectsmartifyapp@gmail.com\n',
                  style: theme.textTheme.bodyMedium,
                ),
                _sectionTitle('5. Использование Cookies и аналитики:'),
                Text(
                  'Мы используем сервисы аналитики, которые могут собирать обезличенную информацию о взаимодействии с приложением. Это помогает нам улучшать функциональность и пользовательский опыт.\n',
                  style: theme.textTheme.bodyMedium,
                ),
                _sectionTitle('6. Дети:'),
                Text(
                  'Приложение не предназначено для использования лицами младше 14 лет без согласия родителей или законных представителей.\n',
                  style: theme.textTheme.bodyMedium,
                ),
                _sectionTitle('7. Изменения политики:'),
                Text(
                  'Мы можем периодически обновлять настоящую Политику. Об изменениях будет сообщено в приложении.\n',
                  style: theme.textTheme.bodyMedium,
                ),
                _sectionTitle('8. Контакты:'),
                Text(
                  'Если у вас есть вопросы или пожелания по поводу обработки ваших данных, свяжитесь с нами:\n\n'
                  'Email: projectsmartifyapp@gmail.com',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      '\n$title',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _subsection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _bullets(List<String> items, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
