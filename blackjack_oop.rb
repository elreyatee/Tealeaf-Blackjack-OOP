# Ellery Temple Jr.
# 10/29/14
# Blackjack OOP

BLACKJACK = 21

class Card
  attr_reader :suit, :rank

  def initialize
    @suit = ["\u2660", "\u2663", "\u2665", "\u2666"]
    @rank = %w{Ace 2 3 4 5 6 7 8 9 10 Jack Queen King}
  end
end

class Deck
  attr_reader :deck

  def initialize(number_of_decks = 1)
    @deck = []
    card = Card.new

    card.suit.each do |s|
      card.rank.each do |r|
        @deck << {r => s}
      end
    end
    @deck *= number_of_decks
  end

  def <<(card)
    deck.push(card)
  end

  def size
    deck.size
  end

  def deal
    deck.pop
  end

  def shuffle
    puts ".....Shuffling cards....."

    5.times do
      print "....."
      sleep 1 
    end
    puts
    deck.shuffle!  
  end
end

class Player
  class Hand #cannot be instantiated without a player
    include Comparable
    attr_accessor :dealt_cards

    def initialize
      @dealt_cards = [] #player's hand starts out empty
    end

    def <=>(opponent)
      dealt_cards.value <=> opponent.dealt_cards.value
    end

    def each(&block)
      dealt_cards.each {|card| yield}
    end

    def clear
      dealt_cards.clear
    end

    def last
      dealt_cards.last.flatten
    end

    def << card
      dealt_cards.push(card)
    end

    def pop
      dealt_cards.pop
    end

    def to_s
      string = []
      
      dealt_cards.each do |card| #cards are card objects
        card.each do |rank, suit|
          string << "#{rank} of #{suit.encode('utf-8')}"
        end
      end
      string.join(' and ') #won't call join on a single array (single card)
    end

    # check value of cards in a hand
    def value
      sum = 0
      
      dealt_cards.each do |card|
        card.each_key do |rank|
          if rank == 'Ace'
            sum += 11
          elsif rank.to_i == 0
            sum += 10
          else
            sum += rank.to_i
          end
        end
      end

      dealt_cards.select {|card| card.key('Ace')}.count.times do
        sum -= 10 if sum > BLACKJACK 
      end

      sum
    end
  end

  class Bank
    attr_accessor :balance

    def initialize(amount)
      @balance = amount
    end

    def to_s
      puts "Your balance is: $#{self.balance}.00"
    end

    def +(amount) # win money
      balance += amount
    end

    def -(amount) # lose money
      balance -= amount
    end
  end

  attr_accessor :hand, :bank
  attr_reader :name

  def initialize(n)
    @name = n
    @hand = Hand.new
    @bank = Bank.new(500)
  end
end

class Game
  attr_accessor :player, :dealer, :deck
  #   place bet - minimum $5, increments of 5, maximum $100
  #   verify bet
  def initialize
    puts "Welcome to Blackjack!"
    print "Howdy stranger, what's your name? "

    @player = Player.new(gets.chomp)
    @dealer = Player.new('House')
    @deck   = Deck.new(3)

    puts "Nice to meet you #{player.name}. Let's play some Blackjack!"
    puts 
  end

  def start_game
    deck.shuffle

    2.times do 
      player.hand << deck.deal
      dealer.hand << deck.deal
    end
    puts "Dealer's face up card is a #{dealer.hand.last[0]} of #{dealer.hand.last[1]}"
  end

  def player_turn
    puts "Your cards are #{player.hand}. Your total value is #{player.hand.value}."

    case
    when player.hand.value == BLACKJACK
      puts "You got Blackjack!"
    when player.hand.value > BLACKJACK
      puts "Sorry #{player.name}, you're busted!"
    else
      print "Would you like a hit or stay #{player.name}? (H/S)"
      player_choice = gets.chomp.downcase

      if player_choice == 'h'
        player.hand << deck.deal
        player_turn
      end
    end
  end

  def dealer_turn
    puts "The dealer's cards are #{dealer.hand}. Their total value is #{dealer.hand.value}."

    case dealer.hand.value
    when BLACKJACK
      puts "Dealer has Blackjack!"
    when (17..BLACKJACK)
      sleep 1
      puts "=> Dealer stays"
    when (0..16)
      puts "=> Dealer takes a hit"
      sleep 1
      dealer.hand << deck.deal
      dealer_turn
    else
      puts "Dealer has busted."
    end
  end

  def winner
    case
    when player.hand.value > dealer.hand.value || dealer.hand.value > BLACKJACK
      puts "You win!"
    when player.hand.value == dealer.hand.value
      puts "It's a push (tie)!"
    else
      puts "You lose!"
    end
  end

  def replay?
    loop do
      puts "Would you like to play again? (Y/N)"

      answer = gets.chomp.downcase

      return true if answer == 'y'
      return false if answer == 'n'

      puts "Invalid selection. Please try again."
    end
  end

  def clear_game
    player.hand.each do |card|
      deck << card
    end

    dealer.hand.each do |card|
      deck << card
    end

    player.hand.clear
    dealer.hand.clear
  end

  def play
    begin
      start_game
      player_turn

      if player.hand.value <= BLACKJACK
        dealer_turn
        winner
      end
      clear_game

    end until replay? == false
    puts "Thanks for playing #{player.name}"
  end
end

Game.new.play








