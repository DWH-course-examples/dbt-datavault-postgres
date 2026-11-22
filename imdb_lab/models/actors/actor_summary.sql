{{ config(order_by='(updated_at, id, name)',
    engine='MergeTree()', materialized='incremental',
    unique_key='id', incremental_strategy='append') }}

with actor_summary as (
    select
        id,
        any(actor_name) as name,
        uniqExact(movie_id) as num_movies,
        avg(rank) as avg_rank,
        uniqExact(genre) as genres,
        uniqExact(director_name) as directors,
        max(created_at) as updated_at
    from (
        select
            {{ source('imdb', 'actors') }}.id as id,
            concat({{ source('imdb', 'actors') }}.first_name, ' ', {{ source('imdb', 'actors') }}.last_name) as actor_name,
            {{ source('imdb', 'movies') }}.id as movie_id,
            {{ source('imdb', 'movies') }}.rank as rank,
            genre,
            concat({{ source('imdb', 'directors') }}.first_name, ' ', {{ source('imdb', 'directors') }}.last_name) as director_name,
            created_at
        from {{ source('imdb', 'actors') }}
        join {{ source('imdb', 'roles') }}
            on {{ source('imdb', 'roles') }}.actor_id = {{ source('imdb', 'actors') }}.id
        left outer join {{ source('imdb', 'movies') }}
            on {{ source('imdb', 'movies') }}.id = {{ source('imdb', 'roles') }}.movie_id
        left outer join {{ source('imdb', 'genres') }}
            on {{ source('imdb', 'genres') }}.movie_id = {{ source('imdb', 'movies') }}.id
        left outer join {{ source('imdb', 'movie_directors') }}
            on {{ source('imdb', 'movie_directors') }}.movie_id = {{ source('imdb', 'movies') }}.id
        left outer join {{ source('imdb', 'directors') }}
            on {{ source('imdb', 'directors') }}.id = {{ source('imdb', 'movie_directors') }}.director_id
    )
    group by id
)
select *
from actor_summary
{% if is_incremental() %}
where id > (select max(id) from {{ this }}) or updated_at > (select max(updated_at) from {{ this }})
{% endif %}
