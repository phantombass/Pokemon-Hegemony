module BattleScripts
  TURNER = {
    "afterLastOpp" => "My last Pokémon. Time to switch up my approach!",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("Let's see just how prepared you are!")
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:GRASSYTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
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
        @battle.battlers[1].pbOwnSide.effects[PBEffects::AuroraVeil] = 1
        @scene.pbAnimation(GameData::Move.get(:AURORAVEIL).id,@battle.battlers[1],@battle.battlers[1])
        $gym_gimmick = true
        @scene.pbDisplay("Hazel set a permanent Aurora Veil!")
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
      end
    end
  }

  WINSLOW = {
    "afterLastOpp" => "Am I being played here? This is my last ditch Pokémon!",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("Things are about to get real twisted in here!")
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:PSYCHICTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
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
        end
      end
    end
  }

  JACKSON = {
    "afterLastOpp" => "Don't think we've given up!",
    "turnStart0" => proc do
      @scene.pbTrainerSpeak("I don't plan on losing to some punk.")
      if $game_switches[LvlCap::Expert]
        @scene.pbAnimation(GameData::Move.get(:MISTYTERRAIN).id,@battle.battlers[1],@battle.battlers[1])
        @battle.field.terrain = :Misty
        @battle.field.terrainDuration = -1
        $gym_gimmick = true
        @scene.pbDisplay("The battlefield got permanently misty!")
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
    "turnStart0" => "Stop while you can kid. You're way out of your depth."
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
    "turnStart0" => "Ye may as well be a criminal showing up at a time like this."
  }

  NAVY2 = {
    "afterLastOpp" => "...",
    "turnStart0" => "..."
  }

  AIRFORCE1 = {
    "afterLastOpp" => "I do believe we are getting to the best part of this match!",
    "turnStart0" => "It's not that I don't trust you kiddo. I've just got to do my due diligence."
  }

  CHANCELLOR1 = {
    "afterLastOpp" => "I will not accept this. I WILL MAINTAIN CONTROL!",
    "turnStart0" => "You can't seem to comprehend. I control EVERYTHING."
  }
end
