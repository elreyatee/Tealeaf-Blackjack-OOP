# Ellery Temple Jr.
# 11/4/14
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
    cards.shuffle!  
  end

  def deal
    cards.pop
  end

  def << card
    cards.push(card)
  end
end

module Hand
  def value
    sum = 0
    
    hand.each do |card|
      if card.rank == 'Ace'
        sum += 11
      elsif card.rank.to_i == 0
        sum += 10
      else
        sum += card.rank.to_i
      end
    end

    hand.select {|card| card.rank == 'Ace'}.count.times do
      sum -= 10 if sum > Game::BLACKJACK
    end

    sum
  end

  def natural?
    value == Game::BLACKJACK && hand.count == 2
  end

end

class Player 
  include Hand

  attr_reader :name
  attr_accessor :hand

  def initialize(n)
    @name = n
    @hand = []
  end

  def show_hand
    string = []
    
    hand.each do |card| #cards are card objects
      string << "#{card.rank} of #{card.suit}"
    end

    string.join(' and ') #won't call join on a single array (single card)
  end
end

class Game
  BLACKJACK = 21
  DEALER_MIN = 17

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

  def deal_cards
    deck.shuffle

    player.hand << deck.deal
    dealer.hand << deck.deal
    player.hand << deck.deal
    dealer.hand << deck.deal
    
    puts "Dealer's face up card is a #{dealer.hand.last.rank} of #{dealer.hand.last.suit}"
  end

  def player_turn

    puts "#{player.name}'s cards are #{player.show_hand}. Your total value is #{player.value}."

    case player.value
    when player.natural?
      puts "You win!"
      replay
    when BLACKJACK
      puts "=> You got Blackjack!"
    when (2..20)
      print "Would you like a hit or stay #{player.name}? (H/S)"
      player_choice = gets.chomp.downcase

      if player_choice == 'h'
        player.hand << deck.deal
        player_turn
      end
    else 
      puts "=> Sorry #{player.name}, you're busted!"
      replay
    end
  end

  def dealer_turn

    puts "The dealer's cards are #{dealer.show_hand}. Their total value is #{dealer.value}."

    case dealer.value
    when BLACKJACK
      puts "=> Dealer has Blackjack!"
    when (DEALER_MIN..BLACKJACK)
      sleep 1
      puts "=> Dealer stays"
    when (2...DEALER_MIN)
      puts "=> Dealer takes a hit"
      sleep 1
      dealer.hand << deck.deal
      dealer_turn
    else
      puts "=> Dealer has busted."
    end
  end

  def winner
    
    case
    when player.value > dealer.value
      puts "You win!"
    when player.value == dealer.value
      puts "It's a push (tie)!"
    else
      puts "You lose!"
    end
  end

  def replay
    loop do
      puts "Would you like to play again? (Y/N)"

      answer = gets.chomp.downcase

      if answer == 'y'
        clear_game
        break
      end

      if answer == 'n'
        puts "Thanks for playing #{player.name}"
        exit
      end

      puts "Invalid selection. Please try again."
    end
  end

  def clear_game
    deck = Deck.new(3)
    player.hand.clear
    dealer.hand.clear
    play
  end

  def play
    deal_cards
    player_turn
    dealer_turn
    winner
    replay
  end
end

Game.new.play