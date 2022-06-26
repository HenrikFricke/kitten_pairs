install:
	mix deps.get
	mix ecto.create
	mix ecto.migrate

server:
	mix phx.server

postgres:
	docker run --detach -e POSTGRES_PASSWORD="postgres" -p 5432:5432 --volume=kitten_pairs_db:/var/lib/postgresql/data --name kitten_pairs_db postgres:12

postgres-stop:
	docker stop kitten_pairs_db && docker rm kitten_pairs_db
