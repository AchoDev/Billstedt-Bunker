
require_relative 'gameobject'
require_relative 'bullet'
require 'gosu'

class Enemy < GameObject

  def initialize(x, y, player)
    super(x, y, "enemy")
    @start_time = Time.now

    @player = player
  end

  def draw
    Gosu.draw_rect(@x, @y, @width, @height, Gosu::Color::RED)
  end

  def update(gameobjects)
    if Time.now - @start_time > 2
      @start_time = Time.now
      gameobjects.push(Bullet.new(@x + 22, @y + 50, 5, "player"))
    end

    @y += 0.1
  end
end
