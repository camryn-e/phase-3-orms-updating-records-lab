# class Student

#   # Remember, you can access your database connection anywhere in this class
#   #  with DB[:conn]

#   attr_accessor :name, :grade
#   attr_reader :id

#   def initialize(name, grade, id = nil)
#     @name = name
#     @grade = grade
#     @id = id
#   end

#   def self.create_table
#     sql = <<-SQL
#     CREATE TABLE IF NOT EXISTS students (
#       id INTEGER PRIMARY KEY, 
#       name TEXT, 
#       grade TEXT
#       )
#       SQL
#     DB[:conn].execute(sql)
#   end

#   def self.drop_table
#     sql = <<-SQL
#     DROP TABLE students
#     SQL
#     DB[:conn].execute(sql)
#   end

#   def save
#     sql = <<-SQL
#       INSERT INTO students (name, grade) 
#       VALUES (?, ?)
#     SQL

#     DB[:conn].execute(sql, self.name, self.grade)

#     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]

#   end

  # def self.create(name, grade)
  #   student = Student.new(name, grade)
  #   student.save
  #   student
  # end

#   def update
#     sql = "UPDATE students SET name = ?, grade = ? WHERE name = ?"
#     DB[:conn].execute(sql, self.name, self.grade, self.name)
#   end

# end

class Student

  attr_accessor :id, :name, :grade

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end


  def self.new_from_db(row)
    # create a new Student object given a row from the database
    id = row[0]
    name = row[1]
    grade = row[2]
    student = self.new(name, grade, id)
    student
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
    SQL

    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end

  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)

  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end