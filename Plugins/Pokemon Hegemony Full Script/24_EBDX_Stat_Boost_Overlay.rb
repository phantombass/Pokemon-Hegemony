class DataBoxEBDX  <  SpriteWrapper
  def setUp
    # reset of the set-up procedure
    @loaded = false
    @showing = false
    pbDisposeSpriteHash(@sprites)
    @sprites.clear
    # caches the bitmap used for coloring
    @colors = pbBitmap(@path + @colors)
    # initializes all the necessary components
    @sprites["base"] = Sprite.new(@viewport)
    @sprites["base"].bitmap = pbBitmap(@path+@baseBitmap)
    @sprites["base"].mirror = @playerpoke

    @sprites["status"] = Sprite.new(@viewport)
    @sprites["status"].bitmap = pbBitmap(@path + "status")
    @sprites["status"].z = self.getMetric("status", :z)
    @sprites["status"].src_rect.height /= 5
    @sprites["status"].src_rect.width = 0
    @sprites["status"].ex = self.getMetric("status", :x)
    @sprites["status"].ey = self.getMetric("status", :y)

    @sprites["boost1"] = Sprite.new(@viewport)
    @sprites["boost1"].bitmap = nil
    @sprites["boost1"].z = 1
    @sprites["boost1"].ex = @playerpoke ? 186 : 20
    @sprites["boost1"].ey = @playerpoke ? -136 : 27
    @sprites["boost1"].visible = false

    @sprites["boost2"] = Sprite.new(@viewport)
    @sprites["boost2"].bitmap = nil
    @sprites["boost2"].z = 1
    @sprites["boost2"].ex = @playerpoke ? 186 : 20
    @sprites["boost2"].ey = @playerpoke ? -120 : 43
    @sprites["boost2"].visible = false

    @sprites["boost3"] = Sprite.new(@viewport)
    @sprites["boost3"].bitmap = nil
    @sprites["boost3"].z = 1
    @sprites["boost3"].ex = @playerpoke ? 186 : 20
    @sprites["boost3"].ey = @playerpoke ? -104 : 59
    @sprites["boost3"].visible = false

    @sprites["boost4"] = Sprite.new(@viewport)
    @sprites["boost4"].bitmap = nil
    @sprites["boost4"].z = 1
    @sprites["boost4"].ex = @playerpoke ? 186 : 20
    @sprites["boost4"].ey = @playerpoke ? -98 : 75
    @sprites["boost4"].visible = false

    @sprites["boost5"] = Sprite.new(@viewport)
    @sprites["boost5"].bitmap = nil
    @sprites["boost5"].z = 1
    @sprites["boost5"].ex = @playerpoke ? 186 : 20
    @sprites["boost5"].ey = @playerpoke ? -82 : 91
    @sprites["boost5"].visible = false

    @sprites["boost6"] = Sprite.new(@viewport)
    @sprites["boost6"].bitmap = nil
    @sprites["boost6"].z = 1
    @sprites["boost6"].ex = @playerpoke ? 186 : 20
    @sprites["boost6"].ey = @playerpoke ? -66 : 107
    @sprites["boost6"].visible = false

    @sprites["boost7"] = Sprite.new(@viewport)
    @sprites["boost7"].bitmap = nil
    @sprites["boost7"].z = 1
    @sprites["boost7"].ex = @playerpoke ? 186 : 20
    @sprites["boost7"].ey = @playerpoke ? -50 : 123
    @sprites["boost7"].visible = false

    @sprites["mega"] = Sprite.new(@viewport)
    @sprites["mega"].z = self.getMetric("mega", :z)
    @sprites["mega"].mirror = @playerpoke
    @sprites["mega"].ex = self.getMetric("mega", :x)
    @sprites["mega"].ey = self.getMetric("mega", :y)

    @sprites["container"] = Sprite.new(@viewport)
    @sprites["container"].bitmap = pbBitmap(@path + @containerBmp)
    @sprites["container"].z = self.getMetric("container", :z)
    @sprites["container"].src_rect.height = @showexp ? 26 : 14
    @sprites["container"].ex = self.getMetric("container", :x)
    @sprites["container"].ey = self.getMetric("container", :y)

    @sprites["hp"] = Sprite.new(@viewport)
    @sprites["hp"].bitmap = Bitmap.new(1, 6)
    @sprites["hp"].z = @sprites["container"].z
    @sprites["hp"].ex = @sprites["container"].ex + @hpBarX
    @sprites["hp"].ey = @sprites["container"].ey + @hpBarY

    @sprites["exp"] = Sprite.new(@viewport)
    @sprites["exp"].bitmap = Bitmap.new(1, 4)
    @sprites["exp"].bitmap.blt(0, 0, @colors, Rect.new(0, 6, 2, 4))
    @sprites["exp"].z = @sprites["container"].z
    @sprites["exp"].ex = @sprites["container"].ex + @expBarX
    @sprites["exp"].ey = @sprites["container"].ey + @expBarY

    @sprites["textName"] = Sprite.new(@viewport)
    @sprites["textName"].bitmap = Bitmap.new(@sprites["container"].bitmap.width + 32, @sprites["base"].bitmap.height)
    @sprites["textName"].z = self.getMetric("name", :z)
    @sprites["textName"].ex = self.getMetric("name", :x) - 16
    @sprites["textName"].ey = self.getMetric("name", :y)
    pbSetSmallFont(@sprites["textName"].bitmap)

    @sprites["caught"] = Sprite.new(@viewport)
    @sprites["caught"].bitmap = pbBitmap(@path + "battleBoxOwned") if !@playerpoke && @battler.owned? && !@scene.battle.opponent
    @sprites["caught"].z = @sprites["container"].z
    @sprites["caught"].ex = @sprites["container"].ex - 18
    @sprites["caught"].ey = @sprites["container"].ey - 2

    @sprites["textHP"] = Sprite.new(@viewport)
    @sprites["textHP"].bitmap = Bitmap.new(@sprites["container"].bitmap.width, @sprites["base"].bitmap.height + 8)
    @sprites["textHP"].z = self.getMetric("hp", :z)
    @sprites["textHP"].ex = self.getMetric("hp", :x)
    @sprites["textHP"].ey = self.getMetric("hp", :y)
    pbSetSmallFont(@sprites["textHP"].bitmap)

    @megaBmp = pbBitmap(@path + "symMega")
    @prKyogre = pbBitmap("Graphics/Pictures/Battle/icon_primal_Kyogre")
    @prGroudon = pbBitmap("Graphics/Pictures/Battle/icon_primal_Groudon")
  end
  def update
    return if self.disposed?
    # updates the HP increase/decrease animation
    if @animatingHP
      if @currenthp < @endhp
        @currenthp += (@endhp - @currenthp)/10.0.delta_add(false)
        @currenthp = @currenthp.ceil
        @currenthp = @endhp if @currenthp > @endhp
      elsif @currenthp > @endhp
        @currenthp -= (@currenthp - @endhp)/10.0.delta_add(false)
        @currenthp = @currenthp.floor
        @currenthp = @endhp if @currenthp < @endhp
      end
      self.updateHpBar
      @animatingHP = false if @currenthp == @endhp
    end
    # updates the EXP increase/decrease animation
    if @animatingEXP
      if !@showexp
        @currentexp = @endexp
      elsif @currentexp < @endexp
        @currentexp += (@endexp - @currentexp)/10.0.delta_add(false)
        @currentexp = @currentexp.ceil
        @currentexp = @endexp if @currentexp > @endexp
      elsif @currentexp > @endexp
        @currentexp -= (@currentexp - @endexp)/10.0.delta_add(false)
        @currentexp = @currentexp.floor
        @currentexp = @endexp if @currentexp < @endexp
      end
      self.updateExpBar
      if @currentexp == @endexp
        # tints the databox blue and plays a sound when EXP is full
        if @currentexp >= @expBarWidth
          pbSEPlay("Pkmn exp full")
          @sprites["base"].color = Color.new(61, 141, 179)
          @animatingEXP = false
          refreshExpLevel
          self.refresh
        else
          @animatingEXP = false
        end
      end
    end
    return if !@loaded
    # moves into position
    unless @animatingHP || @animatingEXP || @inposition
      if @playerpoke && self.x > self.defX
        self.x -= @sprites["base"].width/8
      elsif !@playerpoke && self.x < self.defX
        self.x += @sprites["base"].width/8
      end
    end
    # shows status condition
    status = GameData::Status.get(@battler.status).id_number
    @sprites["status"].src_rect.y = @sprites["status"].src_rect.height * (status - 1)
    @sprites["status"].src_rect.width = status > 0 ? @sprites["status"].bitmap.width : 0

    # shows stat boosts
    stat_boost = []
    $stat_boost = stat_boost
    i = @battler.stages[:ATTACK]
    j = @battler.stages[:DEFENSE]
    k = @battler.stages[:SPECIAL_ATTACK]
    l = @battler.stages[:SPECIAL_DEFENSE]
    m = @battler.stages[:SPEED]
    n = @battler.stages[:ACCURACY]
    o = @battler.stages[:EVASION]
    stat_boost.push(i)
    stat_boost.push(j)
    stat_boost.push(k)
    stat_boost.push(l)
    stat_boost.push(m)
    stat_boost.push(n)
    stat_boost.push(o)
    @sprites["boost1"].bitmap = i != 0 ? pbBitmap(@path + "Atk#{i}") : nil
    @sprites["boost1"].visible = i != 0 ? true : false

    @sprites["boost2"].bitmap = j != 0 ? pbBitmap(@path + "Def#{j}") : nil
    @sprites["boost2"].visible = j != 0 ? true : false

    @sprites["boost3"].bitmap = k != 0 ? pbBitmap(@path + "SpAtk#{k}") : nil
    @sprites["boost3"].visible = k != 0 ? true : false

    @sprites["boost4"].bitmap = l != 0 ? pbBitmap(@path + "SpDef#{l}") : nil
    @sprites["boost4"].visible = l != 0 ? true : false

    @sprites["boost5"].bitmap = m != 0 ? pbBitmap(@path + "Spe#{m}") : nil
    @sprites["boost5"].visible = m != 0 ? true : false

    @sprites["boost6"].bitmap = n != 0 ? pbBitmap(@path + "Acc#{n}") : nil
    @sprites["boost6"].visible = n != 0 ? true : false

    @sprites["boost7"].bitmap = o != 0 ? pbBitmap(@path + "Eva#{o}") : nil
    @sprites["boost7"].visible = o != 0 ? true : false


    # gets rid of the level up tone
    @sprites["base"].color.alpha -= 16 if @sprites["base"].color.alpha > 0
    # bobbing effect
    if @selected
      @frame += 1
      self.y = self.defY + (@frame <= 8.delta_add ? 2 : 0) - (@frame > 8.delta_add ? 2 : 0)
      @frame = 0 if @frame > 16.delta_add
    else
      self.y = self.defY
    end
  end
end
