# frozen_string_literal: true

# This houses the components of the Hangman game
module Hangman

  # This houses the logics of the game
  class Game

    def random_word(filename, min, max)
      dictionary = File.readlines(filename)
      filtered = dictionary.map{ |word| word.chomp }.select{ |word| word.length >= min && word.length <= max }
      last_index = filtered.length - 1
      filtered[rand(0..last_index)]
    end

    def play
      random_word('google-10000-english-no-swears.txt', 5, 12)
    end

  end
end

include Hangman

Game.new.play