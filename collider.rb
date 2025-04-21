
require_relative 'gameobject'

class Collider < GameObject
  attr_accessor :width, :height, :x, :y, :angle, :speed

  def initialize(x, y, width, height, angle = 0)
    super(x, y, "collider")
    @width = width
    @height = height
    @x = x
    @y = y
    @angle = angle
    
    @debug = false

    @image = Gosu.render(@width, @height) do
      Gosu.draw_rect(0, 0, @width, @height, Gosu::Color.argb(200, 255, 0, 0), 0)
    end
  end

  def draw
    if @debug
      @image.draw_rot(@x, @y, 1, @angle)
    end
  end

  def update(gameobjects)
    @image = Gosu.render(@width, @height) do
      Gosu.draw_rect(0, 0, @width, @height, Gosu::Color.argb(200, 255, 0, 0), 0)
    end
  end

  def button_down(id)

    if id == Gosu::KB_F1
      @debug = !@debug
    end

    if !@debug
      return
    end

    case id

    when Gosu::KB_Q
      @angle -= 5
    when Gosu::KB_E
      @angle += 5

    when Gosu::KB_W
      @y -= 5
    when Gosu::KB_S
      @y += 5
    when Gosu::KB_A
      @x -= 5
    when Gosu::KB_D
      @x += 5

    when Gosu::KB_UP
      @height += 5
    when Gosu::KB_DOWN
      @height -= 5
    when Gosu::KB_LEFT
      @width -= 5
    when Gosu::KB_RIGHT
      @width += 5
    when Gosu::KB_SPACE
      puts "x: #{@x}, y: #{@y}, width: #{@width}, height: #{@height}, angle: #{@angle}"
      # Handle space key press
    end
  end
end