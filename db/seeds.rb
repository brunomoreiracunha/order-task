# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

user = User.create(email: "bruno@email.com", password: "123456")

10.times do 
    User.create(email: Faker::Internet.email, password: "123456")
end

5.times do |i|
    Board.create(user: user, name: "Quadro de Tarefa #{i + 1}")
end

Board.find_each do |quadro|
    5.times { |i| List.create(board: quadro, title: "Lista de Tarefas #{i + 1}", position: i)}

    quadro.reload.lists.each do |lista|
        5.times { |i| Item.create(list: lista, title: "Tarefa #{i + 1}", description: "Descrição da Tarefa #{i + 1}", position: i) }
    end
end