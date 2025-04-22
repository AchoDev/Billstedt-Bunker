
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
    @player = Player.new(850, 400)
    @player2 = Player.new(100, 400, true)

    @player.shake_camera = method(:shake_camera)
    @player2.shake_camera = method(:shake_camera)

    @player.set_enemy(@player2)
    @player2.set_enemy(@player)

    @gameobjects.push(@player)
    @gameobjects.push(@player2)

    @camera_movement = [0, 0]

    @winning_sequence = false

    @logo = {
      image: Gosu::Image.new("sprites/logo.png"),
      x: 200,
      y: 200,
      velocity: 0,
      bg_alpha: 200,
      visible: true
    }

    @font = Gosu::Font.new(20)

    @colliders = [
      Collider.new(180, 420, 50, 325),
      Collider.new(120, 345, 75, 40),
      Collider.new(35, 505, 75, 40),
      
      Collider.new(330, 350, 50, 230),
      Collider.new(575, 350, 50, 230),
      Collider.new(520, 445, 65, 40),
      Collider.new(385, 445, 65, 45),

      Collider.new(385, 255, 65, 40),
      Collider.new(520, 255, 65, 40),

      Collider.new(145, 140, 90, 180, 45),
      
      Collider.new(735, 545, 55, 150, 45),
      Collider.new(600, 595, 205, 50),
      Collider.new(780, 375, 55, 280),
    ]
    
    @colliders.each do |collider| @gameobjects.push(collider) end


    @colliders[0].selected = true

    @dancer = {
      x: 200,
      y: -200,
      index: 0,
      sprites: []
    }

    @winning_music = Gosu::Song.new("sounds/winning-music.mp3")

    @map = Gosu::Image.new("sprites/map.png")

    @gun_icons = {
      shotgun: Gosu::Image.new("sprites/shotgun-icon.png"),
      rifle: Gosu::Image.new("sprites/rifle-icon.png"),
      pistol: Gosu::Image.new("sprites/pistol-icon.png")
    }

    @explosion_sound = Gosu::Sample.new("sounds/explosion.wav")
    @die_sound = Gosu::Sample.new("sounds/die.wav")
  end

  def restart

    @winning_music.stop()
    @winning_sequence = false


    @player.x = 850
    @player.y = 400
    @player.health = 10

    @gameobjects.each do |object|
      if object.tag == "bullet"
        @gameobjects.delete(object)
      end

      if object.tag == "player"
        @gameobjects.delete(object)
      end
    end

    @gameobjects.push(@player)
    @gameobjects.push(@player2)

    @player2.x = 100
    @player2.y = 400
    @player2.health = 10

    @logo[:bg_alpha] = 200
    @logo[:y] = 200
    @logo[:velocity] = 0
    @logo[:visible] = true
    @dancer[:x] = 200

    @dancer[:y] = -200
    @dancer[:index] = 0
    @dancer[:sprites] = []
    @player.winning_sequence = false
    @player2.winning_sequence = false
    @player.guns.each do |name, gun|
      gun.winning_sequence = false
    end
  end

  def button_down(id)
    case id
    when Gosu::KB_E
      @player.create_bullet(@gameobjects)
    when Gosu::KB_P
      @player2.create_bullet(@gameobjects)
    when Gosu::KB_TAB
      @colliders.each do |collider|
        if collider.selected
          collider.selected = false
          next_collider = @colliders[(@colliders.index(collider) + 1) % @colliders.length]
          next_collider.selected = true
          break
        end
      end
    when Gosu::KB_R
      restart()
    when Gosu::KB_SPACE
      if @logo[:visible] 
        @logo[:visible] = false
        
        Thread.new do
          100.times do
            sleep(0.01)
            @logo[:bg_alpha] -= 2
            if @logo[:bg_alpha] <= 0
              @logo[:bg_alpha] = 0
            end

            @logo[:velocity] += 0.5
            @logo[:y] += @logo[:velocity]
          end
        end
      end

      @colliders.each_with_index do |collider, index|
        if collider.selected
          puts "Collider #{index}: #{collider.x}, #{collider.y}, #{collider.width}, #{collider.height}, #{collider.angle}"
          break
        end
      end
    end

    if !@winning_sequence 
      @gameobjects.each do |object|
        object.button_down(id)
      end
    end
  end

  def start_winning_sequence

    @player.movement_direction = [0, 0]
    @player2.movement_direction = [0, 0]

    if @winning_sequence
      return
    end

    @explosion_sound.play(0.5)

    @player.winning_sequence = true
    @player2.winning_sequence = true
    @winning_sequence = true

    @player.guns.each do |name, gun|
      gun.start_winning_sequence
    end

    @player2.guns.each do |name, gun|
      gun.start_winning_sequence
    end

    Thread.new do
      sleep(2)

      200.times do 
        @dancer[:y] += 2
        
        sleep(0.01)
      end
    end

    Thread.new do
      sleep(1)
      playername = ""
      if @player.health <= 0
        @gameobjects.delete(@player)
        playername = "player2"
      else 
        @gameobjects.delete(@player2)
        playername = "player1"
      end

      @die_sound.play(0.5)

      sleep(0.5)

      @dancer[:sprites] = [
        Gosu::Image.new("sprites/win/#{playername}-win1.png"),
        Gosu::Image.new("sprites/win/#{playername}-win2.png"),
      ]

      @winning_music.play(false)

      i = 0
      loop do

        if !@winning_sequence
          break
        end

        if @dancer[:index] == 0
          @dancer[:index] = 1
        else 
          @dancer[:index] = 0
        end
        sleep(0.5)

        i += 1
      end
    end

  end

  def shake_camera
    Thread.new do
      15.times do
        shake_amount = 10
        @camera_movement = [rand(-shake_amount..shake_amount), rand(-shake_amount..shake_amount)]
        sleep(0.005)
      end

      @camera_movement = [0, 0]
    end
  end

  def draw
    Gosu.draw_rect(0, 0, 900, 700, Gosu::Color::WHITE)

    if !@winning_sequence
      @map.draw(0 + @camera_movement[0], 0 + @camera_movement[1], 0)
    end
    
    if @player.health <= 0
      start_winning_sequence()
    end
    
    if @player2.health <= 0   
      start_winning_sequence()
    end

    if @winning_sequence
      sprite = @dancer[:sprites][@dancer[:index]]
      if sprite
        sprite.draw(@dancer[:x], @dancer[:y], 1, 0.2, 0.2)
        @font.draw_text("Player #{@player.health <= 0 ? 2 : 1} wins!", 380, 600, 1, 1.0, 1.0, Gosu::Color::BLACK)
        @font.draw_text("Press R to restart the game", 320, 620, 1, 1.0, 1.0, Gosu::Color::BLACK)
      end
    end

    @gameobjects.each do |object|
      if !@winning_sequence
        object.update(@gameobjects)
      end
      object.draw(@camera_movement)
    end

    Gosu.draw_rect(0, 0, 900, 700, Gosu::Color.argb(@logo[:bg_alpha], 255, 255, 255), 30)
    @logo[:image].draw(@logo[:x], @logo[:y], 30, 0.2, 0.2)
  end
end

BillstedtBunker.new.show
