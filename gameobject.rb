
class GameObject

  attr_accessor :x, :y, :width, :height, :tag, :gameobjects

  def initialize(x, y, tag)
    @x = x
    @y = y
    @width = 50
    @height = 50

    @tag = tag
  end

  def draw
  end

  def update
  end

  def button_down(id)
  end

  def check_collision(other)
    if other.is_a?(GameObject)
      return (@x < other.x + other.width && @x + @width > other.x &&
              @y < other.y + other.height && @y + @height > other.y)
    end
    false
  end
end