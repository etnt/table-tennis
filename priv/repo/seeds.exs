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


alias TableTennis.Repo
alias TableTennis.Accounts.User


Repo.insert!(%User{email: "rune@acme.com",
                   name: "Rune Gustafsson",
                   avatar: "http://acme.com/avatar"})


#Repo.insert!(%Player{nick: "rune",
#                     won: 0,
#                     lost: 0,
#                     rating: 1000})
