# frozen_string_literal: true
require 'yaml'

# A YAML serializer
module YAMLSerializable
  def to_yaml 
    obj = {}
    instance_variables.map do |var|
      obj[var] = instance_variable_get(var)
    end

    YAML.dump obj
  end

  def from_yaml(string, permitted_classes)
    YAML.load(string, permitted_classes: permitted_classes)
  end
end

# This houses the components of the Hangman game
module Hangman
  include YAMLSerializable

  def start
    loop do
      puts "Start new game (n) or load saved game (s)?"
      begin
        game_option = gets.chomp.downcase
        raise unless game_option == 'n' || game_option == 's'
      rescue StandardError
        puts 'Invalid input! Try again...'
      else
        if game_option == 'n'
          start_new_game
        elsif game_option == 's'
          load_saved_game
        end
      end
    end
  end 

  # This houses the logics of the game
  class Game
    def initialize(game_id, secret_word, available_letters, guessed_letters, incorrect_guesses_remaining)
      @game_id = game_id
      @secret_word = secret_word
      @available_letters = available_letters
      @guessed_letters = guessed_letters
      @incorrect_guesses_remaining = incorrect_guesses_remaining
    end

    def play
      p display_word(@secret_word)
      loop do
        if !display_word(@secret_word).include?('_')
          puts 'You win!'
          return 
        elsif @incorrect_guesses_remaining < 1
          puts 'You lose!'
          puts "The word was '#{@secret_word}'"
          return 
        elsif @secret_word.include?(guess_letter)
          puts 'Correct Guess'
        else
          @incorrect_guesses_remaining -= 1
          puts 'Incorrect Guess'
          puts "#{@incorrect_guesses_remaining} incorrect #{@incorrect_guesses_remaining > 1 ? "guesses" : "guess"} remaining"
        end
        p display_word(@secret_word)
        loop do
          puts 'Quit and save game? (y/n)'
          begin
            answer = gets.chomp.downcase
            raise unless answer == 'y' || answer == 'n'
          rescue StandardError
            puts "Invalid input! Enter 'y' to quit and save or 'n' to continue..."
          else
            if answer == 'y'
              Dir.mkdir('game_saves') unless Dir.exist?('game_saves')
              filename = "game_saves/#{@game_id}.yaml"
              File.open(filename, 'w') do |file|
                file.puts self.to_yaml
              end
              exit
            else
              break
            end
          end
        end
      end
    end

    private

    def guess_letter
      loop do
        puts 'Guess a letter'
        begin
          letter = gets.chomp.downcase
          raise unless @available_letters.include?(letter)
        rescue StandardError
          puts 'Invalid input or letter already guessed! Try again...'
        else
          @available_letters.delete(letter)
          @guessed_letters.push(letter)
          return letter
        end
      end
    end

    def display_word(word)
      display = String.new
      word.each_char { |char| display.concat(@guessed_letters.include?(char) ? "#{char} " : "_ ") }
      display[-1] = ""
      display
    end
  end

  private

  def random_word(filename, min, max)
    dictionary = File.readlines(filename)
    filtered = dictionary.map{ |word| word.chomp }.select{ |word| word.length >= min && word.length <= max }
    last_index = filtered.length - 1
    filtered[rand(0..last_index)]
  end

  def start_new_game
    secret_word = random_word('google-10000-english-no-swears.txt', 5, 12)
    Game.new(Time.now.to_s.gsub(' -0400', '').gsub(' ', '-'), secret_word, ('a'..'z').to_a, [], 6).play
  end

  def load_saved_game
    game_saves = Dir.entries('game_saves').slice(2..-1)
    loop do
      puts "Copy and paste a game to load #{game_saves}"
      begin
        game_save = gets.chomp.downcase
        raise unless game_saves.include?(game_save)
      rescue StandardError
        puts 'Invalid input! Try again...'
      else
        game = self.from_yaml(File.open("game_saves/#{game_save}"), [Hangman::Game])
        game.play
      end
    end
  end
end

include Hangman

start