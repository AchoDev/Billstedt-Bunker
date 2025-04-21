
require 'gosu'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'player'


class SpaceInvaders < Gosu::Window
  def initialize
    super(900, 700, false)

    self.caption = "Space Invaders"

    @gameobjects = []
    @player = Player.new(400, 400)
    @player2 = Player.new(100, 400, true)

    @player.set_enemy(@player2)
    @player2.set_enemy(@player)

    @gameobjects.push(@player)
    @gameobjects.push(@player2)

    @map = Gosu::Image.new("sprites/map.png")

    @gun_icons = {
      shotgun: Gosu::Image.new("sprites/shotgun-icon.png"),
      rifle: Gosu::Image.new("sprites/rifle-icon.png"),
      pistol: Gosu::Image.new("sprites/pistol-icon.png")
    }
  end

  def create_enemy
    enemy = Enemy.new(rand(0..640), rand(0..480), @player)
    @gameobjects.push(enemy)

    return enemy
  end

  def button_down(id)
    case id
    when Gosu::KB_J
      @player.create_bullet(@gameobjects)
    end

    @gameobjects.each do |object|
      object.button_down(id)
    end
  end

  def draw
    Gosu.draw_rect(0, 0, 900, 700, Gosu::Color::WHITE)

    @map.draw(0, 0, 0)

    @gameobjects.each do |object|
      object.update(@gameobjects)
      object.draw
    end

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
end

SpaceInvaders.new.show
