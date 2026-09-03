#!/bin/sh
set -eu

# Euro-Office bakes a PostgreSQL cluster into the image. A fresh bind mount or
# named volume over /var/lib/postgresql hides that cluster. Bootstrap only that
# specific empty-volume case; never overwrite a non-empty, unrecognised data dir.
if [ "${DB_HOST:-localhost}" = "localhost" ]; then
  PG_MAJOR="${PG_MAJOR:-16}"
  PG_CLUSTER="${PG_CLUSTER:-main}"
  PG_DATA="/var/lib/postgresql/${PG_MAJOR}/${PG_CLUSTER}"

  if [ ! -s "${PG_DATA}/PG_VERSION" ]; then
    if [ -d "$PG_DATA" ] && [ -n "$(find "$PG_DATA" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
      echo "ERROR: PostgreSQL data directory ${PG_DATA} is non-empty but has no PG_VERSION; refusing to overwrite it." >&2
      exit 1
    fi

    echo "Initializing fresh PostgreSQL ${PG_MAJOR}/${PG_CLUSTER} cluster in ${PG_DATA}..."
    rm -rf "$PG_DATA"
    mkdir -p "$PG_DATA"
    chown postgres:postgres "$PG_DATA"
    chmod 700 "$PG_DATA"

    runuser -u postgres -- "/usr/lib/postgresql/${PG_MAJOR}/bin/initdb" \
      -D "$PG_DATA" \
      --auth-local=peer \
      --auth-host=scram-sha-256 >/dev/null

    # The image build normally creates these before packaging. A fresh volume
    # hides the baked cluster, so recreate the same runtime prerequisites.
    service postgresql start

    db_user="${DB_USER:-eurooffice}"
    db_name="${DB_NAME:-eurooffice}"
    db_pwd="${DB_PWD:-eurooffice}"

    role_exists=$(runuser -u postgres -- psql -X -qAt \
      -v db_user="$db_user" <<'SQL'
SELECT 1 FROM pg_roles WHERE rolname = :'db_user';
SQL
    )

    if [ "$role_exists" != "1" ]; then
      runuser -u postgres -- psql -X -v ON_ERROR_STOP=1 \
        -v db_user="$db_user" -v db_pwd="$db_pwd" <<'SQL'
CREATE ROLE :"db_user" LOGIN PASSWORD :'db_pwd';
SQL
    fi

    db_exists=$(runuser -u postgres -- psql -X -qAt \
      -v db_name="$db_name" <<'SQL'
SELECT 1 FROM pg_database WHERE datname = :'db_name';
SQL
    )

    if [ "$db_exists" != "1" ]; then
      runuser -u postgres -- createdb --owner="$db_user" "$db_name"
    fi

    service postgresql stop
  fi
fi

exec /entrypoint-upstream.sh "$@"
