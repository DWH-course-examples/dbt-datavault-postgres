# dbt + ClickHouse: материализации imdb

## Окружение
- dbt-core 1.4.0, dbt-clickhouse
- ClickHouse 24.3.18.7 (docker, host `clickhouse`, порт 8123)
- Источник данных: imdb_ijs TSV-датасеты из S3 (~818 тыс. ролей)
- Профиль `clickhouse_imdb`, схема `imdb_dbt` (host `clickhouse` вместо localhost — сервис в docker-сети)

## Модель
`models/actors/actor_summary.sql` — витрина актёров: число фильмов,
средний рейтинг, жанры и режиссёры через пять JOIN по шести таблицам
источника `imdb`. Источники объявлены в `models/actors/schema.yml`.

## Эксперименты

### 1. View (0,43 с)
Модель компилируется в `CREATE VIEW imdb_dbt.actor_summary`. Данные не
материализуются: каждый запрос пересчитывает JOIN заново.

### 2. Table (3,42 с)
`engine='MergeTree()'`, `order_by='(updated_at, id, name)'`.
`SHOW CREATE TABLE` подтверждает физическую таблицу с этим движком.
Пересчёт всего датасета при каждом прогоне.

### 3. Incremental (2,68 с)
`unique_key='id'`, фильтр
`where id > (select max(id) from {{ this }}) or updated_at > (select max(updated_at) from {{ this }})`.
Тест: актёр Clicky McClickHouse (id 845466, 910 ролей) появился в
витрине после точечного прогона; время меньше полной пересборки.
Механика по system.query_log:
1. `actor_summary__dbt_new_data` — пустая таблица + INSERT только изменённых строк (фильтр применён);
2. `actor_summary__dbt_tmp` — перенос старых строк с проверкой `id not in (...)` (защита от дублей/обновлений);
3. перенос новых строк из new_data в tmp;
4. `rename` → `EXCHANGE TABLES` — атомарная подмена, зачистка временных.

### 4. Append (~1 с)
`incremental_strategy='append'`. Актёр Danny DeBito (id 845467, 920 ролей).
В логе только `INSERT INTO imdb_dbt.actor_summary ... SELECT` с тем же
фильтром — промежуточных таблиц и EXCHANGE нет. Требует иммутабельных
данных: повторный прогон создаст дубли (фильтр по max(id) новые id уже
не отсечёт).

## Примечания
- INSERT в roles: порядок столбцов SELECT должен совпадать с реальным
  порядком колонок таблицы (ClickHouse сопоставляет по позициям),
  поэтому используется явный список колонок.
- `__dbt_exchange_test_*` в логе — проверка поддержки EXCHANGE TABLES
  адаптером dbt-clickhouse, не промежуточные таблицы модели.
