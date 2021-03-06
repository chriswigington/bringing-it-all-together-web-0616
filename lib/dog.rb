require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(hash)
    dog = self.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL 
      SELECT * FROM dogs WHERE id = #{id};
    SQL

    Dog.new_from_db(DB[:conn].execute(sql)[0])
  end

  def self.find_or_create_by(name:, breed:)
    # if it exists, .new_from_db, else .create
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"
    row = DB[:conn].execute(sql, name, breed)
    if !row.empty?
      self.new_from_db(row[0])
    else
      self.create(name:name, breed:breed)
    end
  end

  def self.new_from_db(row)
    Dog.new(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end