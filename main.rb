
require 'gosu'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'player'
require_relative 'collider'

class BillstedtBunker < Gosu::Window
  def initialize
    super(900, 700, false)

    self.caption = "Billstedt Bunker"

    @gameobjects = []
    @player = Player.new(400, 400)
    @player2 = Player.new(100, 400, true)

    @player.set_enemy(@player2)
    @player2.set_enemy(@player)

    @gameobjects.push(@player)
    @gameobjects.push(@player2)

    [
      Collider.new(180, 420, 50, 325),
      Collider.new(120, 345, 75, 40),
      Collider.new(35, 505, 75, 40),
      Collider.new(335, 350, 35, 230),
      Collider.new(565, 350, 25, 230),
      Collider.new(520, 445, 65, 35),
      Collider.new(385, 450, 65, 35),
      Collider.new(385, 250, 65, 35),
      Collider.new(520, 250, 65, 35),
      Collider.new(155, 145, 90, 180, 45),
      Collider.new(740, 555, 35, 150, 45),
      Collider.new(600, 605, 205, 30),
      Collider.new(790, 375, 35, 280),
    ].each do |collider| @gameobjects.push(collider) end

    @map = Gosu::Image.new("sprites/map.png")

    @gun_icons = {
      shotgun: Gosu::Image.new("sprites/shotgun-icon.png"),
      rifle: Gosu::Image.new("sprites/rifle-icon.png"),
      pistol: Gosu::Image.new("sprites/pistol-icon.png")
    }
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
  end
end

BillstedtBunker.new.show
