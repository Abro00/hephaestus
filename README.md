# Бот Гефест
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://gitlab.edu.rnds.pro/nambrosimov/hephaestus/-/blob/main/LICENSE)

В среднем на создание задачи в JIRA, фиксацию в чате информации о создании задачи тратит 5 минут. Таких задач в проекте может быть довольно много. При этом после обсуждения задачи в чате во время создания в JIRA теряется контекст: в рамках какого обсуждения родилась задача.

Этот проект предназначен для упрощения процесса создания задачи. Основная концепция — возможность создать задачу не выходя из чата, написав сообщение боту, и получить в ответ номер новой задачи и ссылку на нее.

## Установка и запуск

### Вручную

1. Клонируйте репозиторий

GitLab:
```bash
git clone https://gitlab.edu.rnds.pro/nambrosimov/hephaestus
cd hephaestus
```

GitHub:
```bash
git clone https://github.com/Abro00/hephaestus-bot
cd hephaestus-bot
```
2. Создайте Телеграм бота, написав [@BotFather](https://t.me/BotFather)
3. Указажите имя и токен бота в __credentials.yml.enc__ (подобнее в разделе __Начальная конфигурация__).
4. Запустите прекомпиляцию стилей
```bash
rails assets:precompile
```
5. Запустите двумя отдельными процессами (в разных окнах терминала)

бота
```bash
rails telegram:bot:poller
```
и сервер с приложением
```bash
rails s
```

### С использованием Docker

1. Клонируйте репозиторий

GitLab:
```bash
git clone https://gitlab.edu.rnds.pro/nambrosimov/hephaestus
cd hephaestus
```

GitHub:
```bash
git clone https://github.com/Abro00/hephaestus-bot
cd hephaestus-bot
```
2. Создайте Телеграм бота, написав [@BotFather](https://t.me/BotFather)
3. Указажите имя и токен бота в __credentials.yml.enc__ (подобнее в разделе __Начальная конфигурация__)
4. Если у вас имеется свой __production key base__ укажите его в соответствующей переменной окружения в __docker-compose.yml__
5. Запустите контейнер
```bash
docker-compose up -d --build
```
### Начальная конфигурация

__*Отключите режим приватности в групповых чатах для бота*__

Бот имеет возможность создавать задачу без команды, по упоминанию. Для того, чтобы бот имел возможность прослушивать сообщения с упоминанием, а не только команды, отключите в настройках бота у [@BotFather](https://t.me/BotFather) режим приватности. [Подробнее](https://core.telegram.org/bots#privacy-mode)

__*Укажите имя и токен бота*__

В соответствии с примером __credentials.yml.example__ с помощью команды
```bash
EDITOR="nano" rails credentials:edit
```
>Если config/master.key отсутствует, необходимо удалить имеющийся файл credentials.yml.enc после чего данная команда сгенерирует новый ключ и файл с данными.

Откроется текстовый редактор, необходимо внести изменения, сохранить их и закрыть редактор. Вместо __nano__ можно использовать любой другой.
(в случае с VSCode необходимо добавить также опцию __--wait__)
```bash
EDITOR="code --wait" rails credentials:edit
```

__*Добавить в переменные окружения POSTGRES_USER и POSTGRES_PASSWORD или указать их в config/database.yml*__

## Использование

Перед подключением чата к проекту добавьте бота в групповой чат в Телеграме.

Для добавления задач в проекте JIRA потребуется аккаунт с соответствующими правами. Создайте аккаунт или испоьзуйте имеющийся. Для доступа к аккаунту вместо пароля используйте JIRA API token, который можно получить следуя [инструкции](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/).

## Создание задачи с помощью бота

После добавления бота в чат проекта и установки соединения, создать задачу в проекте можно отправив сообщение по шаблону
```
@<bot_username> <issue_summary>

<issue_description>
```
При успешном создании бот вернет ссылку на новую задачу.

Этот шаблон доступен по команде __/help@<bot_username>__

## Зависимости

* [Ruby on Rails](https://rubyonrails.org/) >= 7.0.3
* [PostgreSQL](https://postgresql.org/) >= 14.4
