# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# coding: utf-8

Schedule.create(date: '2018-01-01', roomId: '1', contents:'テスト1', functionId: '1')
Schedule.create(date: '2018-01-02', roomId: '1', contents:'テスト1', functionId: '1')
Schedule.create(date: '2018-02-02', roomId: '1', contents:'テスト1', functionId: '1')

Function.create(name: 'parrot', content:'おうむ返しbot')
