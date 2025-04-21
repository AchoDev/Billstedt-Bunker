
require_relative 'gameobject'
# require_relative 'enemy'
require_relative 'player'
require 'gosu'

class Bullet < GameObject

  def initialize(x, y, angle, target_tag)
    super(x, y, "bullet")
    
    @width = 5
    @height = 25

    @x = x - @width / 2
    @y = y

    @angle = angle - 90
    @speed = 10
    @target_tag = target_tag

    @image = Gosu.render(@width, @height) do
      Gosu.draw_rect(0, 0, @width, @height, Gosu::Color::BLACK, 0)
    end
  end

  def draw
    @image.draw_rot(@x + @width / 2, @y - @height / 2, 1, @angle - 90)
  end

  def update(gameobjects)
    @x += @speed * Math.cos(@angle * Math::PI / 180)
    @y += @speed * Math.sin(@angle * Math::PI / 180)

    gameobjects.each do |target|
      next unless target.tag == @target_tag

      if check_collision(target)
        gameobjects.delete(target)
        gameobjects.delete(self) 
      end
    end
  end
end
