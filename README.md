# TableTennis

Revisiting my old Table Tennis Score System, now as a tool
to learn Elixir+Phoenix.

At the end of this README I have some notes I've jotted down
while learning the ropes of this cool framework.


## Run

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Notes

### Overview
Phoenix is a web development framework written in Elixir which
implements the server-side Model View Controller (MVC) pattern.

The Phoenix endpoint pipeline takes a request,
routes it to a controller to access the Model (Business Logic),
which then calls a view module to render a template.

### Model 
The Model will be responsible to host all of your business logic
and business domain. It typically interacts directly with the database.

### Controller
Controllers act as intermediary modules. Their functions,
called actions, are invoked from the router in response to
HTTP requests. The actions, in turn, gather all the necessary
data (e.g from the Model) and perform all the necessary steps
before invoking the view layer. Phoenix controllers also
build on the Plug package, and are themselves plugs.

### View
The view interface from the controller is simple – the controller
calls a view function with the connections assigns, and the
functions job is to return a HEEx template.
We call any function that accepts an assigns parameter and
returns a HEEx template to be a function component.


### Create the project:

    mix phx.new table_tennis
    cd table_tennis
    mix phx.gen.html App Player players name:string won:integer lost:integer rating:integer
    mix phx.gen.html App Match matches player1:string player2:string score1:integer score2:integer
    mix ecto.migrate

### Postgres 

If POSTGRES table already exist when: mix ecto.migrate:

    psql -U postgres -c 'DROP DATABASE IF EXISTS table_tennis_dev;'

or perhaps better:

    mix ecto.drop

to undo e.g a migration:

    mix ecto.rollback

Working with psql:

    psql table_tennis_dev  -  connect to the
    \dt  -  list tables
    \d players  -  list the fields in the 'players' table

Working with Ecto from the shell:

    alias TableTennis.Repo
    import Ecto.Query
    # Check what SQL is generated
    query = from "players", select: [:name]
    Repo.to_sql(:all, query)