require 'pry'

class Dog
    
    attr_reader :id, :breed
    attr_accessor :name

    

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    
    def save
        
        sql = <<-SQL
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
        SQL
  
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end


    def self.create(dog_hash)
        new_dog = Dog.new(dog_hash)
        new_dog.save 
        new_dog
    end

    def self.new_from_db(row)
        dog_hash = {:id => row[0], :name => row[1], :breed => row[2]}
        new_dog = Dog.new(dog_hash)
        new_dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
       
        dog_hash = {:id => result[0], :name => result[1], :breed => result[2]}
        Dog.new(dog_hash)
    end

    def self.find_or_create_by(name:, breed:)
        
        sql = "SELECT * FROM dogs WHERE name = ? AND breed =?"
        result = DB[:conn].execute(sql, name, breed)[0]
        
        if result
            dog_hash = {:id => result[0], :name => result[1], :breed => result[2]}
            Dog.new(dog_hash)
        else
            self.create(name: name, breed: breed)
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        result = DB[:conn].execute(sql, name)[0]
        dog_hash = {:id => result[0], :name => result[1], :breed => result[2]}
        Dog.new(dog_hash)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end