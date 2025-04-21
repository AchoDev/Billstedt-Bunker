
require_relative 'gameobject'
require_relative 'bullet'
require 'gosu'

class Gun
  attr_accessor :name, :sound, :cooldown, :cooldown_timer, :cooling_down, :shoot_sound, :shooting, :offset

  def initialize(name, cooldown, offset)
    @name = name
    @shoot_sound = Gosu::Sample.new("sounds/#{name}.wav")
    @equip_sound = Gosu::Sample.new("sounds/equip-#{name}.mp3")
    @cooldown = cooldown
    @cooldown_timer = 0
    @cooling_down = false
    @shooting = false

    @offset = offset
  end

  def shoot
    @shoot_sound.play(0.5, [0.9, 0.95, 1, 1.05, 1.1].sample, false)

    if @name == "rifle"
      @shooting = true
      Thread.new do
        sleep(0.5)
        @shooting = false
      end
    end

    Thread.new do
      start_time = Time.now
      @cooling_down = true
      loop do
        @cooldown_timer = (Time.now - start_time)

        if @cooldown_timer > @cooldown
          @cooling_down = false
          @cooldown_timer = 0
          @equip_sound.play(0.5, 2, false)
          break
        end

        sleep(0.01)
      end
    end
  end

  def equip
    if @cooling_down
      return
    end
    @equip_sound.play(0.5, 1, false)
  end
end

class Player < GameObject

  attr_accessor :current_gun, :guns, :health

  def initialize(x, y, player2 = false)
    super(x, y, "player")

    @width = 20
    @height = 20

    @angle = 0

    @enemy = nil
    @velocity = [0, 0]

    @speed = 6
    @dash_speed = 20
    @drag = 0.1
    @movement_direction = [0, 0]

    @health = 3

    @player2 = player2

    @guns = {
      shotgun: Gun.new("shotgun", 5, [45, 20]),
      rifle: Gun.new("rifle", 10, [60, 10]),
      pistol: Gun.new("pistol", 0.5, [50, 0])
    }
    @player_sprites = {
      rifle: Gosu::Image.new("sprites/player1/rifle.png"),
      shotgun: Gosu::Image.new("sprites/player1/shotgun.png"),
      pistol: Gosu::Image.new("sprites/player1/pistol.png")
    }

    if @player2 
      @player_sprites = {
        rifle: Gosu::Image.new("sprites/player2/rifle.png"),
        shotgun: Gosu::Image.new("sprites/player2/shotgun.png"),
        pistol: Gosu::Image.new("sprites/player2/pistol.png")
      }
    end

    @current_gun = @guns[:shotgun]
  end

  def draw
    # Gosu.draw_rect(@x + @width / 2, @y - @height / 2, @width, @height, Gosu::Color::BLACK)

    # @guns[:shotgun].offset[1] += 1
    # @angle += 5

    
    target_angle = Math.atan2(@enemy.y - @y, @enemy.x - @x) * 180 / Math::PI
    
    angle_difference = target_angle - @angle
    angle_difference -= 360 if angle_difference > 180
    angle_difference += 360 if angle_difference < -180
    
    @angle += angle_difference * 0.1
    
    @player_sprites.each do |gun, sprite|
      if @current_gun.name == gun.to_s
        # sprite.draw_rot(@x + @width / 2, @y - @height / 2, 1, @angle + 90, 0.5, 0.5, 0.05, 0.05)
        sprite.draw_rot(@x + @width / 2, @y - @height / 2, 1, @angle + 90, 0.45, 0.75, 0.05, 0.05)
      end
    end

    # pos = calculate_bullet_position(@current_gun.offset)

    # w = 10
    # h = 10
    # Gosu.draw_rect(pos[0] - w / 2, pos[1] - h / 2, w, h, Gosu::Color::BLACK)

    icon_x = 10
    @gun_icons.each do |gun, icon|
      if @player.current_gun.name == gun.to_s
        icon.draw(icon_x, 600, 0, 0.2, 0.2, Gosu::Color::GREEN)
      else
        icon.draw(icon_x, 600, 0, 0.2, 0.2, Gosu::Color::WHITE)
      end
      
      icon.draw(icon_x, 600, 0, 0.2, 0.2)


      height_percentage = 0
      gun_object = @player.guns[gun]

      if gun_object.cooling_down
        height_percentage = 1 - (gun_object.cooldown_timer / gun_object.cooldown)
      end

      Gosu.draw_rect(icon_x, 600, 100, 100 * height_percentage, Gosu::Color.argb(200, 0, 0, 0))
      
      icon_x += 100
    end  
  end

  def set_enemy(enemy)
    @enemy = enemy
  end

  def update(gameobjects)

    @last_pos = [@x, @y]

    movement_buttons = {
      right: !@player2 ? Gosu::KB_D : Gosu::KB_RIGHT,
      left: !@player2 ? Gosu::KB_A : Gosu::KB_LEFT,
      up: !@player2 ? Gosu::KB_W : Gosu::KB_UP,
      down: !@player2 ? Gosu::KB_S : Gosu::KB_DOWN
    }

    @velocity[0] -= @drag * @velocity[0]
    @velocity[1] -= @drag * @velocity[1]

    @x += @velocity[0]
    @y += @velocity[1]

    @movement_direction = [0, 0]

    if Gosu.button_down?(movement_buttons[:left])
      @movement_direction[0] = -1
    end

    if Gosu.button_down?(movement_buttons[:right])
      @movement_direction[0] = 1
    end

    if Gosu.button_down?(movement_buttons[:up])
      @movement_direction[1] = -1
    end

    if Gosu.button_down?(movement_buttons[:down])
      @movement_direction[1] = 1
    end

    normalize()
    apply_speed()


    gameobjects.each do |target|
      next unless target.tag == "collider"
      if rotated_rect_circle_collision(
        target.x, target.y, target.width, target.height, target.angle * Math::PI / 180,
        @x + @width / 2, @last_pos[1] - @height / 2, @width / 2
      )
        # Collision detected
        @x = @last_pos[0]
        @velocity[0] = 0
        
      end

      if rotated_rect_circle_collision(
        target.x, target.y, target.width, target.height, target.angle * Math::PI / 180,
        @last_pos[0] + @width / 2, @y - @height / 2, @width / 2
      )
        # Collision detected
        @y = @last_pos[1]
        @velocity[1] = 0
        
      end
    end
  end

  def button_down(id)

    action_buttons = {
      dash: !@player2 ? Gosu::KB_Q : Gosu::KB_P,
      shotgun: !@player2 ? Gosu::KB_1 : Gosu::KB_9,
      rifle: !@player2 ? Gosu::KB_2 : Gosu::KB_0,
      pistol: !@player2 ? Gosu::KB_3 : Gosu::KB_MINUS
    }

    case id
    when action_buttons[:dash]
      dash()
    when action_buttons[:shotgun]
      if @current_gun.shooting == false
        @current_gun = @guns[:shotgun]
        @current_gun.equip()
      end
    when action_buttons[:rifle]
      if @current_gun.shooting == false
        @current_gun = @guns[:rifle]
        @current_gun.equip()
      end
    when action_buttons[:pistol]
      if @current_gun.shooting == false
        @current_gun = @guns[:pistol]
        @current_gun.equip()
      end
    end
  end

  def apply_speed
    if @velocity[0].abs < @speed && @movement_direction[0] != 0
      @velocity[0] = @movement_direction[0] * @speed
    end

    if @velocity[1].abs < @speed && @movement_direction[1] != 0
      @velocity[1] = @movement_direction[1] * @speed
    end
  end

  def dash
    @velocity = [@movement_direction[0] * @dash_speed, @movement_direction[1] * @dash_speed]
  end

  def normalize
    # normalize movement direction
    length = Math.sqrt(@movement_direction[0]**2 + @movement_direction[1]**2)
    if length > 0
      @movement_direction[0] /= length
      @movement_direction[1] /= length
    end
  end

  def calculate_bullet_position(offset)
    offset_x = offset[0]
    offset_y = offset[1]
    radians = @angle * Math::PI / 180 # Convert angle to radians
    rotated_x = @x - 1 + offset_x * Math.cos(radians) - offset_y * Math.sin(radians)
    rotated_y = @y - 10 + offset_x * Math.sin(radians) + offset_y * Math.cos(radians)
    [rotated_x, rotated_y]
  end
  
  def create_bullet(gameobjects)

    return if @current_gun.cooling_down
    @current_gun.shoot()

    case @current_gun
    when @guns[:shotgun]
      angles = [-20, -10, 0, 10, 20]
      pos = calculate_bullet_position(@current_gun.offset)

      angles.map do |angle|
        gameobjects.push(Bullet.new(pos[0], pos[1], angle + @angle + 90))
      end

    when @guns[:rifle]
      Thread.new do
        5.times do
          pos = calculate_bullet_position(@current_gun.offset)
          bullet = Bullet.new(pos[0], pos[1], @angle + 90)
          gameobjects.push(bullet)
          sleep(0.1)
          @current_gun.shoot_sound.play(0.5, 1, false)
        end
      end
    when @guns[:pistol]
      pos = calculate_bullet_position(@current_gun.offset)
      bullet = Bullet.new(pos[0], pos[1], @angle + 90)
      gameobjects.push(bullet)
    end
  end
end