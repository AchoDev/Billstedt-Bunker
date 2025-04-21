
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

  def rotated_rect_circle_collision(rect_x, rect_y, rect_width, rect_height, rect_angle, circle_x, circle_y, circle_radius)
    cos_angle = Math.cos(-rect_angle)
    sin_angle = Math.sin(-rect_angle)

    local_circle_x = cos_angle * (circle_x - rect_x) - sin_angle * (circle_y - rect_y)
    local_circle_y = sin_angle * (circle_x - rect_x) + cos_angle * (circle_y - rect_y)

    half_width = rect_width / 2.0
    half_height = rect_height / 2.0

    closest_x = [[local_circle_x, -half_width].max, half_width].min
    closest_y = [[local_circle_y, -half_height].max, half_height].min

    distance_x = local_circle_x - closest_x
    distance_y = local_circle_y - closest_y

    distance_x**2 + distance_y**2 <= circle_radius**2
  end

  def circle_collision(circle1_x, circle1_y, circle1_radius, circle2_x, circle2_y, circle2_radius)
    # Calculate the distance between the two circle centers
    distance_x = circle2_x - circle1_x
    distance_y = circle2_y - circle1_y
    distance_squared = distance_x**2 + distance_y**2

    # Compare the squared distance to the squared sum of the radii
    radius_sum = circle1_radius + circle2_radius
    distance_squared <= radius_sum**2
  end
end