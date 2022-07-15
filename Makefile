DATABASE_NAME = kitten_pairs_db

install:
	mix deps.get
	mix ecto.create
	mix ecto.migrate

start:
	mix phx.server

test:
	mix test

test-watch:
	mix test.watch

postgres:
	podman run --detach -e POSTGRES_PASSWORD="postgres" -p 5432:5432 --volume=$(DATABASE_NAME):/var/lib/postgresql/data --name $(DATABASE_NAME) postgres:12

postgres-stop:
	podman stop $(DATABASE_NAME)
	podman rm $(DATABASE_NAME)
