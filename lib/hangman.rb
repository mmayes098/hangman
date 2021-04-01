require "yaml"

class Hangman
  dict = File.read("5desk.txt").split

  DICTIONARY = dict.select { |ele| ele.length >= 5 && ele.length <= 12 }

  def self.random_word
    DICTIONARY.sample
  end

  def initialize
    @secret_word = Hangman.random_word.downcase
    @guess_word = Array.new(@secret_word.length, "_")
    @attempted_chars = []
    @remaining_incorrect_guesses = @secret_word.length + 2
    load_game
  end

  def secret_word
    @secret_word
  end

  def guess_word
    @guess_word
  end

  def attempted_chars
    @attempted_chars
  end

  def remaining_incorrect_guesses
    @remaining_incorrect_guesses
  end

  def already_attempted?(char)
    if @attempted_chars.include?(char)
      true
    else
      false
    end
  end

  def get_matching_indices(char)
    indices = []
    @secret_word.each_char.with_index do |letter, i|
      if letter == char
        indices << i
      end
    end

    return indices
  end

  def fill_indices(char, indices)
    indices.each { |num| @guess_word[num] = char }
  end

  def try_guess(char)
    if self.already_attempted?(char)
      puts "That has already been attempted"
      return false
    else
      @attempted_chars << char
    end

    indices = self.get_matching_indices(char)

    if indices.length == 0
      @remaining_incorrect_guesses -= 1
    else
      self.fill_indices(char, indices)
    end

    true
  end

  def ask_user_for_guess
    puts "Enter a letter (or type 'save' to save your game): "
    char = gets.chomp.downcase
    if char == 'save'
      File.open('savegame.yml', 'w') do |file|
        file.write(YAML.dump(self))
      end
      puts "File saved!"
      exit
    end 
    self.try_guess(char)
  end

  def load_game
    puts "Would you like to load a previously saved game? Y or N"
    load = gets.chomp.downcase
    if load == "y"
      if File.exist?("savegame.yml")
        save = YAML.load_file("savegame.yml")
        @secret_word = save.secret_word
        @guess_word = save.guess_word
        @attempted_chars = save.attempted_chars
        @remaining_incorrect_guesses = save.remaining_incorrect_guesses
      else
        puts "No save game exists!"
      end
    end
  end

  def win?
    if @guess_word == @secret_word.split("")
      puts "WIN"
      return true
    end

    false
  end

  def lose?
    if @remaining_incorrect_guesses == 0
      puts "LOSE"
      return true
    end

    false
  end

  def game_over?
    if self.win? || self.lose?
      puts @secret_word
      return true
    end

    false
  end

end