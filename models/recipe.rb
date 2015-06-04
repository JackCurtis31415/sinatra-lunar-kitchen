require "pg"
require "net/http"

require "pry"


  def db_connection
    begin
      connection = PG.connect(dbname: "recipes")
      yield(connection)

    rescue PG::UniqueViolation
      @error_string = "UniqueViolation: url is either a duplicate, or null"

    ensure
      connection.close
    end
  end


class Recipe

  attr_reader  :id, :name, :instructions, :description
  
  def initialize(id, name, instructions, description)
    @id = id
    @name = name
    @instructions = instructions
    @description = description

  end

  def ingredients
    @ingredients = []

    ingredients_result =  db_connection { |conn| conn.exec("SELECT *  FROM ingredients WHERE recipe_id = #{@id}") }

    ingredients_result.each do |ingredient|

      an_ingredient_object = Ingredient.new(ingredient["id"], ingredient["name"], ingredient["recipe_id"] )

      @ingredients << an_ingredient_object

    end

    return @ingredients

  end
  
  def self.find(request_id)

    find_result =  db_connection { |conn| conn.exec("SELECT * FROM recipes WHERE recipes.id = #{request_id} ") }

    a_recipe_instance = Recipe.new(find_result[0]["id"], find_result[0]["name"], find_result[0]["instructions"],
                                   find_result[0]["description"] )
     
  end
  
  def self.all

    @recipes_array = []

    recipes_result =  db_connection { |conn| conn.exec("SELECT * FROM recipes") }

    recipes_result.each do |recipe|

      a_recipe_instance = Recipe.new(recipe["id"], recipe["name"], recipe["instructions"],
                        recipe["description"] )

      @recipes_array << a_recipe_instance

    end

    return @recipes_array
    
  end
end

