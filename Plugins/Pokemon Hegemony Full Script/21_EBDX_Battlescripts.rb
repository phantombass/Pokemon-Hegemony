module BattleScripts
  #============
  #Mini Bosses
  #============
  HELUM = {
    "turnStart0" => proc do
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:GRASSYTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
        @sprites["battlebg"].reconfigure(:GRASSY, :DISTORTION)
        @battle.field.terrain = :Grassy
        @battle.field.terrainDuration = -1
        $gym_gimmick = true
        @scene.pbDisplay("The battlefield got permanently grassy!")
      end
    end
  }
  OGAN = {
    "turnStart0" => proc do
      if $game_switches[LvlCap::Expert]
        $gym_hazard = true
        @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
        @scene.pbDisplay("A mysterious force prevents hazard removal!")
      end
    end
  }
  NEONN = {
    "turnStart0" => proc do
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:WISH).id,@battle.battlers[1],@battle.battlers[1])
        @battle.field.weather = :Starstorm
        @battle.field.weatherDuration = -1
        $gym_weather = true
        @scene.pbDisplay("Stars permanently filled the sky!")
        @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
      end
    end
  }

  NITRO = {
    "turnStart0" => proc do
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:TAILWIND).id,@battle.battlers[1],@battle.battlers[1])
        @battle.battlers[1].pbOwnSide.effects[PBEffects::Tailwind] = 1
        $gym_gimmick = true
        @scene.pbDisplay("A permanent Tailwind blew in behind Gail's team!")
      end
    end
  }

  KRYPTO = {
    "turnStart0" => proc do
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:TAILWIND).id,@battle.battlers[1],@battle.battlers[1])
        @battle.field.weather = :StrongWinds
        $gym_weather = true
        @scene.pbDisplay("A Delta Stream brewed!")
        @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
      end
    end
  }

  CHLOROS = {
    "turnStart0" => proc do
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:PSYCHICTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
        @sprites["battlebg"].reconfigure(:GRASSY, :PSYCHIC)
        @battle.field.terrain = :Psychic
        @battle.field.terrainDuration = -1
        @battle.field.effects[PBEffects::TrickRoom] = 1
        $gym_gimmick = true
        @scene.pbDisplay("The battlefield got permanently weird!")
        @scene.pbDisplay("The dimensions were permanently twisted!")
      end
    end
}

  CAPITOL = {
    "turnStart0" => proc do
      if $game_switches[LvlCap::Expert]
          @scene.pbAnimation(GameData::Move.get(:SLUDGEWAVE).id,@battle.battlers[1],@battle.battlers[1])
          @sprites["battlebg"].reconfigure(:GRASSY, :POISON)
          @battle.field.terrain = :Poison
          @battle.field.terrainDuration = -1
          $gym_gimmick = true
          @scene.pbAnimation(GameData::Move.get(:RAINDANCE).id,@battle.battlers[1],@battle.battlers[1])
          @battle.field.weather = :AcidRain
          @battle.field.weatherDuration = -1
          $gym_weather = true
          @scene.pbDisplay("The battlefield got permanently toxic!")
      end
    end
  }
  #============
  #Gym Leaders
  #============
  TURNER = {
    "afterLastOpp" => "My last Pokémon. Time to switch up my approach!",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("Let's see just how prepared you are!")
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:GRASSYTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
        @sprites["battlebg"].reconfigure(:GRASSY, :DISTORTION)
        @battle.field.terrain = :Grassy
        @battle.field.terrainDuration = -1
        $gym_gimmick = true
        @scene.pbDisplay("The battlefield got permanently grassy!")
      end
    end
  }

  HAZEL = {
    "afterLastOpp" => "Hmm, my last Pokémon...",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("I'm very curious to see how you handle this battle style.")
      if $game_switches[LvlCap::Expert]
        $gym_hazard = true
        @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
        @scene.pbDisplay("A mysterious force prevents hazard removal!")
      end
    end
  }

  ASTRID = {
    "afterLastOpp" => "My heavens. Is this my last Pokémon?",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("I hope you're ready to learn about the power of Cosmic-types.")
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:WISH).id,@battle.battlers[1],@battle.battlers[1])
        @battle.field.weather = :Starstorm
        @battle.field.weatherDuration = -1
        $gym_weather = true
        @scene.pbDisplay("Stars permanently filled the sky!")
        @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
      end
    end
  }

  GAIL = {
    "afterLastOpp" => "I see you've picked up rather fast. Think you can handle this one, though?",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("You'll be so confused in this battle. It's ok, you'll learn.")
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:TAILWIND).id,@battle.battlers[1],@battle.battlers[1])
        @battle.battlers[1].pbOwnSide.effects[PBEffects::Tailwind] = 1
        $gym_gimmick = true
        @scene.pbDisplay("A permanent Tailwind blew in behind Gail's team!")
      end
    end
  }

  GORDON = {
    "afterLastOpp" => proc do
      pname = $Trainer.name
      rname = $game_variables[12]
      @scene.pbTrainerSpeak("Get ready #{pname}! Here's my trump card")
    end,
    "turnStart0" => proc do
      pname = $Trainer.name
      rname = $game_variables[12]
      @scene.pbTrainerSpeak("I have heard good things about you from #{rname}! Let's see if he was right.")
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:TAILWIND).id,@battle.battlers[1],@battle.battlers[1])
        @battle.field.weather = :StrongWinds
        $gym_weather = true
        @scene.pbDisplay("A Delta Stream brewed!")
        @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
      end
    end
  }

  WINSLOW = {
    "afterLastOpp" => "Am I being played here? This is my last ditch Pokémon!",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("Things are about to get real twisted in here!")
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:PSYCHICTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
        @sprites["battlebg"].reconfigure(:PSYCHIC, :DISTORTION)
        @battle.field.terrain = :Psychic
        @battle.field.terrainDuration = -1
        @battle.field.effects[PBEffects::TrickRoom] = 1
        $gym_gimmick = true
        @scene.pbDisplay("The battlefield got permanently weird!")
        @scene.pbDisplay("The dimensions were permanently twisted!")
      end
    end
}

  VINCENT = {
    "afterLastOpp" => "Looks like it's closing time. Last call!",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("Let's march.")
      if $game_switches[LvlCap::Expert]
        if $game_variables[28] < 4
          @scene.pbAnimation(GameData::Move.get(:SLUDGEWAVE).id,@battle.battlers[1],@battle.battlers[1])
          @sprites["battlebg"].reconfigure(:POISON, :DISTORTION)
          @battle.field.terrain = :Poison
          @battle.field.terrainDuration = -1
          $gym_gimmick = true
          @scene.pbDisplay("The battlefield got permanently toxic!")
        else
          @scene.pbAnimation(GameData::Move.get(:RAINDANCE).id,@battle.battlers[1],@battle.battlers[1])
          @battle.field.weather = :AcidRain
          @battle.field.weatherDuration = -1
          $gym_weather = true
          @scene.pbDisplay("The skies permanently filled with Acid Rain!")
          @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
        end
      end
    end
  }

  JACKSON = {
    "afterLastOpp" => "Don't think we've given up!",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("I don't plan on losing to some punk.")
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:PSYCHICTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
        @sprites["battlebg"].reconfigure(:PSYCHIC, :DISTORTION)
        @battle.field.terrain = :Psychic
        @battle.field.terrainDuration = -1
        $gym_gimmick = true
        @scene.pbDisplay("The battlefield got permanently weird!")
        @battle.field.weather = :HeavyRain
        @battle.field.weatherDuration = -1
        $gym_weather = true
        @scene.pbDisplay("Jackson set permanent Heavy Rain!")
        @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
        @battle.battlers[1].pbOwnSide.effects[PBEffects::Safeguard] = 1
        @battle.battlers[1].effects[PBEffects::Taunt] = 1
        $gym_taunt = true
        @scene.pbDisplay("Jackson's team is protected from status and prevents your status moves!")
      end
    end
  }

  MILITIA1 = {
    "afterLastOpp" => "You are quite good. How frustrating.",
    "turnStart0" => "You don't know what you're dealing with, kid."
  }

  MILITIA2 = {
    "afterLastOpp" => "...",
    "turnStart0" => "..."
  }

  ARMY1 = {
    "afterLastOpp" => "How interesting...",
    "turnStart0" => proc do 
      @scene.pbTrainerSpeak("Stop while you can kid. You're way out of your depth.")
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:WISH).id,@battle.battlers[1],@battle.battlers[1])
        @battle.field.weather = :Eclipse
        @battle.field.weatherDuration = -1
        $gym_weather = true
        @scene.pbDisplay("Ahab set permanent Eclipse!")
      end
    end
  }

  ARMY2 = {
    "afterLastOpp" => "How infuriating...",
    "turnStart0" => "Don't think you can beat my team again like you did last time."
  }

  OFFCORP1 = {
    "afterLastOpp" => "I can't say I was expecting this.",
    "turnStart0" => "Prepare to be overrun."
  }

  NAVY1 = {
    "afterLastOpp" => "Ah, I see yer point. Well said, yungin.",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("Ye may as well be a criminal showing up at a time like this.")
      if $game_switches[LvlCap::Expert]
        if $game_variables[51] <= 5
          @scene.pbAnimation(GameData::Move.get(:HAIL).id,@battle.battlers[1],@battle.battlers[1])
          @battle.field.weather = :Sleet
          @battle.field.weatherDuration = -1
          $gym_weather = true
          @scene.pbDisplay("Eugene set permanent Sleet!")
        else
          @scene.pbAnimation(GameData::Move.get(:RAINDANCE).id,@battle.battlers[1],@battle.battlers[1])
          @battle.field.weather = :HeavyRain
          @battle.field.weatherDuration = -1
          $gym_weather = true
          @scene.pbDisplay("Eugene set permanent Heavy Rain!")
        end
      end
    end
  }

  NAVY2 = {
    "afterLastOpp" => "...",
    "turnStart0" => "..."
  }

  AIRFORCE1 = {
    "afterLastOpp" => "I do believe we are getting to the best part of this match!",
    "turnStart0" => proc do 
      @scene.pbTrainerSpeak("It's not that I don't trust you kiddo. I've just got to do my due diligence.")
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:TAILWIND).id,@battle.battlers[1],@battle.battlers[1])
        @battle.field.weather = :StrongWinds
        @battle.field.weatherDuration = -1
        $gym_weather = true
        @scene.pbDisplay("Winston set permanent Delta Stream!")
      end
    end
  }

  CHANCELLOR = {
    "afterLastOpp" => "I will not accept this. I WILL MAINTAIN CONTROL!",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("You can't seem to comprehend. I control EVERYTHING.")
      @scene.pbAnimation(GameData::Move.get(:PSYCHICTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
      @sprites["battlebg"].reconfigure(:PSYCHIC, :DISTORTION)
      @battle.field.terrain = :Psychic
      @battle.field.terrainDuration = -1
      $gym_gimmick = true
      @scene.pbDisplay("The battlefield got permanently weird!")
    end
  }
  #==============================================================================
  # Post-Game
  #==============================================================================
  JASPER = {
    "afterLastOpp" => "Hmm. You are very good. Very good indeed.",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("Allow me to formally introduce you to how we do Dojo Battles here!")
      @scene.pbAnimation(GameData::Move.get(:SANDSTORM).id,@battle.battlers[1],@battle.battlers[1])
      @battle.field.weather = :Sandstorm
      @battle.field.weatherDuration = -1
      $gym_weather = true
      @scene.pbDisplay("Jasper set a permanent Sandstorm!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
    end
  }
  APOLLO = {
    "afterLastOpp" => "Oh my. How exciting!",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("My dojo is themed around the Sun. Let me show you!")
      @scene.pbAnimation(GameData::Move.get(:SUNNYDAY).id,@battle.battlers[1],@battle.battlers[1])
      @battle.field.weather = :HarshSun
      @battle.field.weatherDuration = -1
      $gym_weather = true
      @scene.pbDisplay("Apollo set up Harsh Sunlight!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange }
    end
  }
  LUNA = {
    "afterLastOpp" => "Hmmph. This isn't over yet.",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("...time to show you why I hate visitors to my island...")
      @battle.pbCommonAnimation("ShadowSky")
      @battle.field.weather = :Eclipse
      @battle.field.weatherDuration = -1
      $gym_weather = true
      @scene.pbDisplay("Luna set a permanent Eclipse!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange }
    end
  }
  MALOKI = {
    "afterLastOpp" => "This is one righteous battle, my dude!",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("Time to feel the tidal wave come crashing in!")
      @scene.pbAnimation(GameData::Move.get(:RAINDANCE).id,@battle.battlers[1],@battle.battlers[1])
      @battle.field.weather = :HeavyRain
      $gym_weather = true
      @scene.pbDisplay("Maloki set up Heavy Rain!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange }
    end
  }
  JULIET = {
    "afterLastOpp" => "Like, WHOA. This is my last one!",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("YAY! Battle time!")
      @scene.pbAnimation(GameData::Move.get(:ELECTRICTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
      @sprites["battlebg"].reconfigure(:ELECTRIC, :DISTORTION)
      @battle.field.terrain = :Electric
      @battle.field.terrainDuration = -1
      $gym_gimmick = true
      @scene.pbDisplay("Juliet set up a permanent Electric Terrain!")
    end
  }
  OLAF = {
    "afterLastOpp" => "Huh. Not bad, kid.",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("I really do not care for battling, but here we go.")
      @scene.pbAnimation(GameData::Move.get(:BLIZZARD).id,@battle.battlers[1],@battle.battlers[1])
      @battle.field.weather = :Sleet
      @battle.field.weatherDuration = -1
      $gym_weather = true
      @scene.pbDisplay("Olaf set up permanent Sleet!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange }
    end
  }
  WENDY = {
    "afterLastOpp" => "Huh. Not bad, kid.",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("Umm, I'm really not sure...ok, here we go, I guess...")
      @scene.pbAnimation(GameData::Move.get(:TAILWIND).id,@battle.battlers[1],@battle.battlers[1])
      @battle.field.weather = :Windy
      @battle.field.weatherDuration = -1
      $gym_weather = true
      @scene.pbDisplay("Wendy set up a permanent Wind!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange }
    end
  }
  ADAM = {
    "afterLastOpp" => "Wow! You're so tough! But can you handle this?",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("Let's get this show going!")
      @scene.pbAnimation(GameData::Move.get(:MISTYTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
      @sprites["battlebg"].reconfigure(:MISTY, :DISTORTION)
      @battle.field.terrain = :Misty
      @battle.field.terrainDuration = -1
      $gym_gimmick = true
      @scene.pbDisplay("Adam set up a permanent Misty Terrain!")
    end
  }
  CHANCELLOR1 = {
    "afterLastOpp" => "I have to succeed at this. You will NOT stand in my way!",
    "turnStart0" => proc do
      @scene.pbDisplay("The Harsh Sun is permanent!")
      @scene.pbTrainerSpeak("Why can't you just stay out of our business?!?")
      @scene.pbAnimation(GameData::Move.get(:PSYCHICTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
      @sprites["battlebg"].reconfigure(:PSYCHIC, :DISTORTION)
      @battle.field.terrain = :Psychic
      @battle.field.terrainDuration = -1
      $gym_gimmick = true
      $gym_weather = true
      @scene.pbDisplay("Yule set up a permanent Psychic Terrain!")
    end
  }
  ASTRIDLEAGUE = {
    "turnStart0" => proc do
      @scene.pbAnimation(GameData::Move.get(:WISH).id,@battle.battlers[1],@battle.battlers[1])
      @battle.field.weather = :Starstorm
      @battle.field.weatherDuration = -1
      $gym_weather = true
      @scene.pbDisplay("Astrid set a permanent Starstorm!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
    end
  }
  WINSLOWLEAGUE = {
    "turnStart0" => proc do
      @scene.pbAnimation(GameData::Move.get(:PSYCHICTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
      @sprites["battlebg"].reconfigure(:PSYCHIC, :DISTORTION)
        @battle.field.terrain = :Psychic
        @battle.field.terrainDuration = -1
        @battle.field.effects[PBEffects::TrickRoom] = 1
        $gym_gimmick = true
      @scene.pbDisplay("Winslow set permanent Psychic Terrain and Trick Room!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
    end
  }
  EUGENERAIN = {
    "turnStart0" => proc do
      @scene.pbAnimation(GameData::Move.get(:RAINDANCE).id,@battle.battlers[1],@battle.battlers[1])
      @battle.field.weather = :HeavyRain
      $gym_weather = true
      @scene.pbDisplay("Eugene set up Heavy Rain!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
    end
  }
  EUGENESLEET = {
    "turnStart0" => proc do
      @scene.pbAnimation(GameData::Move.get(:HAIL).id,@battle.battlers[1],@battle.battlers[1])
      @battle.field.weather = :Sleet
      @battle.field.weatherDuration = -1
      $gym_weather = true
      @scene.pbDisplay("Eugene set up permanent Sleet!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
    end
  }
  ARMANDLEAGUE = {
    "turnStart0" => proc do
      @scene.pbAnimation(GameData::Move.get(:TAILWIND).id,@battle.battlers[1],@battle.battlers[1])
      @battle.field.weather = :StrongWinds
      $gym_weather = true
      @scene.pbDisplay("Armand set up Delta Stream!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
    end
  }
  WINSTONLEAGUE = {
    "turnStart0" => proc do
      @scene.pbAnimation(GameData::Move.get(:TAILWIND).id,@battle.battlers[1],@battle.battlers[1])
      @battle.field.weather = :Windy
      @battle.field.weatherDuration = -1
      $gym_weather = true
      @scene.pbDisplay("Winston set a permanent Wind!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
    end
  }
  VINCENTLEAGUE = {
    "turnStart0" => proc do
      @scene.pbAnimation(GameData::Move.get(:SLUDGEWAVE).id,@battle.battlers[1],@battle.battlers[1])
      @sprites["battlebg"].reconfigure(:POISON, :DISTORTION)
        @battle.field.terrain = :Poison
        @battle.field.terrainDuration = -1
        $gym_gimmick = true
      @scene.pbDisplay("Vincent set permanent Poison Terrain!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
    end
  }
  JOSEPHSAND = {
    "turnStart0" => proc do
      @scene.pbAnimation(GameData::Move.get(:SANDSTORM).id,@battle.battlers[1],@battle.battlers[1])
      @battle.field.weather = :Sandstorm
      @battle.field.weatherDuration = -1
      $gym_weather = true
      @scene.pbDisplay("Joseph set a permanent Sandstorm!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
    end
  }
  JOSEPHTERRAIN = {
    "turnStart0" => proc do
      @scene.pbAnimation(GameData::Move.get(:ELECTRICTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
      @sprites["battlebg"].reconfigure(:ELECTRIC, :DISTORTION)
        @battle.field.terrain = :Electric
        @battle.field.terrainDuration = -1
        $gym_gimmick = true
      @scene.pbDisplay("Winslow set permanent Electric Terrain!")
      @battle.eachBattler { |b| b.pbCheckFormOnWeatherChange}
    end
  }
end

module EnviromentEBDX
  GRASSY = { "base" => "Grassy" }
  PSYCHIC = { "base" => "Psychic" }
  MISTY = { "base" => "Misty" }
  ELECTRIC = { "base" => "Electric" }
  POISON = { "base" => "Poison" }
end