# frozen_string_literal: true

# This houses the components of the Hangman game
module Hangman

  # This houses the logics of the game
  class Game
    def initialize
      @secret_word = ""
      @available_letters = ('a'..'z').to_a
      @guessed_letters = []
      @incorrect_guesses_remaining = 6
    end

    def play
      @secret_word = random_word('google-10000-english-no-swears.txt', 5, 12)
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
      end
    end

    private

    def random_word(filename, min, max)
      dictionary = File.readlines(filename)
      filtered = dictionary.map{ |word| word.chomp }.select{ |word| word.length >= min && word.length <= max }
      last_index = filtered.length - 1
      filtered[rand(0..last_index)]
    end

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
end

include Hangman

Game.new.play