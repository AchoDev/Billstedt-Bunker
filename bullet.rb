
require_relative 'gameobject'
# require_relative 'enemy'
require_relative 'player'
require 'gosu'

class Bullet < GameObject

  def initialize(x, y, angle)
    super(x, y, "bullet")
    
    @width = 5
    @height = 25

    @x = x - @width / 2
    @y = y

    @angle = angle - 90
    @speed = 10

    @image = Gosu.render(@width, @height) do
      Gosu.draw_rect(0, 0, @width, @height, Gosu::Color::WHITE, 0)
    end
  end

  def draw
    @image.draw_rot(@x + @width / 2, @y - @height / 2, 1, @angle - 90)
  end

  def update(gameobjects)
    @x += @speed * Math.cos(@angle * Math::PI / 180)
    @y += @speed * Math.sin(@angle * Math::PI / 180)

    gameobjects.each do |target|
      if target.tag == "collider"
        if rotated_rect_circle_collision(target.x, target.y, target.width, target.height, target.angle, @x + @width / 2, @y - @height / 2, @width / 2)
          gameobjects.delete(self)
        end
      end

      next unless target.tag == "player"

      if circle_collision(@x, @y, @width / 2, target.x + target.width / 2, target.y - target.height / 2, target.width / 2)
        target.take_damage()
        gameobjects.delete(self)
      end
    end
  end
end
