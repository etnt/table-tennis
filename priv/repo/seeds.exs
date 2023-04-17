# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TableTennis.Repo.insert!(%TableTennis.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

TableTennis.App.create_player(%{name: "Stellan",
                                lost: 0,
                                won: 0,
                                rating: 1000,
                                email: "stellan@tabletennis.org"
                               })

TableTennis.App.create_player(%{name: "J-O",
                                lost: 0,
                                won: 0,
                                rating: 1000,
                                email: "waldner@tabletennis.org"
                               })
