# Ellery Temple Jr.
# 10/29/14
# Blackjack OOP

class Card
  attr_reader :suit, :rank

  def initialize(r, s)
    @suit = s
    @rank = r
  end
end

class Deck
  attr_reader :cards

  def initialize(number_of_decks = 1)
    @cards = []

    ["\u2660", "\u2663", "\u2665", "\u2666"].each do |suit|
      ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'].each do |rank|
        @cards << Card.new(rank, suit.encode('utf-8'))
      end
    end

    @cards *= number_of_decks
  end

  def shuffle
    puts ".....Shuffling cards....."

    5.times do
      print "....."
      sleep 1 
    end
    puts
    cards.shuffle!  
  end

  def deal
    cards.pop
  end

  def size
    cards.size
  end

  def << card
    cards.push(card)
  end
end

class Player
  class Hand
    include Comparable
    attr_accessor :dealt_cards

    def initialize
      @dealt_cards = []
    end

    def value
      sum = 0
      
      dealt_cards.each do |card|
        if card.rank == 'Ace'
          sum += 11
        elsif card.rank.to_i == 0
          sum += 10
        else
          sum += card.rank.to_i
        end
      end

      dealt_cards.select {|card| card.rank == 'Ace'}.count.times do
        sum -= 10 if sum > 21
      end

      sum
    end

    def to_s
      string = []
      
      dealt_cards.each do |card| #cards are card objects
        string << "#{card.rank} of #{card.suit}"
      end
  
      string.join(' and ') #won't call join on a single array (single card)
    end

    def <=>(opponent)
      dealt_cards.value <=> opponent.dealt_cards.value
    end

    def << card
      dealt_cards.push(card)
    end

    def size
      dealt_cards.size
    end

    def last
      dealt_cards.last
    end

    def each(&block)
      dealt_cards.each {|card| yield}
    end

    def clear
      dealt_cards.clear
    end
  end

  attr_reader :name
  attr_accessor :hand

  def initialize(n)
    @name = n
    @hand = Hand.new
  end
end

class Game
  BLACKJACK = 21

  attr_reader :player, :dealer
  attr_accessor :deck

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

    puts "Dealer's face up card is a #{dealer.hand.last.rank} of #{dealer.hand.last.suit}"
  end

  def player_turn

    v = player.hand.value
    puts "Your cards are #{player.hand}. Your total value is #{v}."

    case v
    when BLACKJACK
      puts "You got Blackjack!"
    when (0..20)
      print "Would you like a hit or stay #{player.name}? (H/S)"
      player_choice = gets.chomp.downcase

      if player_choice == 'h'
        player.hand << deck.deal
        player_turn
      end
    else 
      puts "Sorry #{player.name}, you're busted!"
    end
  end

  def dealer_turn

    v = dealer.hand.value
    puts "The dealer's cards are #{dealer.hand}. Their total value is #{v}."

    case v
    when BLACKJACK
      puts "Dealer has Blackjack!"
    when (17..BLACKJACK)
      sleep 1
      puts "=> Dealer stays"
    when (2..16)
      puts "=> Dealer takes a hit"
      sleep 1
      dealer.hand << deck.deal
      dealer_turn
    else
      puts "Dealer has busted."
    end
  end

  def winner

    pv = player.hand.value
    dv = dealer.hand.value

    case
    when pv > dv || dv > BLACKJACK || (pv == BLACKJACK && player.hand.size == 2)
      puts "You win!"
    when pv == dv
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
    deck = Deck.new(3)
    player.hand.clear
    dealer.hand.clear
  end

  def play
    begin
      start_game
      player_turn
      winner

      if player.hand.value < BLACKJACK
        dealer_turn
        winner
      end
      clear_game
      
    end until replay? == false
    puts "Thanks for playing #{player.name}"
  end
end

Game.new.play