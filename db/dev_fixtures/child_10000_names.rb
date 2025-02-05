# frozen_string_literal: true

def read_file(filename)
  f = File.open(filename, 'r')

  names = []
  f.each_line do |line|
    l = line.delete("\n").delete("\r")
    names.push(l)
  end
  f.close
  names
end

def get_random_user
  users = %w[primero primero_cp]
  User.find_by_user_name(users.sample)
end

def create_children(id, num_children, names, lastnames)
  relation = %w[mother father aunt uncle brother sister]

  (0..num_children).each do |i|
    {
      "#{id}#{i}" => lambda do |c|
        randommonth = rand(10..11)
        randomday = rand(1..29)

        c.module_id = 'primeromodule-cp'
        c.status = %w[open closed].sample
        c.record_state = [true, false].sample
        c.created_at = DateTime.new(2014, randommonth, randomday)
        # random name and last name
        c.name_first = (names[rand(names.size - 1)]).to_s
        c.name_last = " #{lastnames[rand(lastnames.size - 1)]}"
        c.name_nickname = (names[rand(names.size - 1)]).to_s
        c.name_other = (lastnames[rand(lastnames.size - 1)]).to_s
        c.sex = %w[male female].sample
        c.age = rand(5..30).to_s
        c.consent_for_tracing = true
        c.family_details_section = [
          {
            unique_id: "#{id}#{i}-1",
            relation_name: "#{c.name_first}1",
            relation_nickname: "#{c.name_nickname}1",
            relation: relation.sample
          }
        ]
      end
    }.each do |k, v|
      default_owner = get_random_user
      c = Child.find_by_unique_identifier(k) || Child.new_with_user_name(default_owner, { unique_identifier: k })
      v.call(c)
      puts "Child #{c.new? ? 'created' : 'updated'}: #{c.unique_identifier} name: #{c.name_first} #{c.name_last}, name_nickname: #{c.name_nickname}, name_other: #{c.name_other}"
      c.save!
    end
  end
end

Child.all.each(&:destroy)

path = 'db/dev_fixtures/names/'
# 1:Arabic names, 2:East african names, 3: English names, 4: Spanish names
number_of_children = [4000, 3000, 2000, 1000]
ids = %w[ara ea eng spa]
names = [read_file("#{path}arabic_names.csv"),
         read_file("#{path}swahili_names.csv"),
         read_file("#{path}english_names.csv"),
         read_file("#{path}spanish_names.csv")]

lastnames = [read_file("#{path}arabic_surnames.csv"),
             read_file("#{path}arabic_surnames.csv"),
             read_file("#{path}english_surnames.csv"),
             read_file("#{path}spanish_surnames.csv")]

4.times do |i|
  create_children(ids[i], number_of_children[i], names[i], lastnames[i])
end
