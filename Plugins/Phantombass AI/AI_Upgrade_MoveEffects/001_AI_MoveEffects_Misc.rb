#===============================================================================
#
#===============================================================================
# None

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("134",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.copy("134",
                                           "133")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.copy("134",
                                           "001")

#===============================================================================
#
#===============================================================================
# AddMoneyGainedFromBattle

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.copy("134",
                                           "157")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("012",
  proc { |move, user, ai, battle|
    next user.turnCount > 0
  }
)
AIHandlers::MoveEffectScore.add("012",
  proc { |score, move, user, ai, battle|
    next score + 25   # Use it or lose it
  }
)
AIHandlers::MoveFailureCheck.copy("012","174")
AIHandlers::MoveEffectScore.copy("012","174")
#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("125",
  proc { |move, user, ai, battle|
    has_another_move = false
    has_unused_move = false
    user.battler.eachMove do |m|
      next if m.id == move.id
      has_another_move = true
      next if user.battler.movesUsed.include?(m.id)
      has_unused_move = true
      break
    end
    next !has_another_move || has_unused_move
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("158",
  proc { |move, user, ai, battle|
    next !user.battler.belched?
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("192",
  proc { |move, user, target, ai, battle|
    next !target.item || !target.item_active?
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("123",
  proc { |move, user, target, ai, battle|
    user_types = user.pbTypes(true)
    target_types = target.pbTypes(true)
    next (user_types & target_types).empty?
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("115",
  proc { |score, move, user, target, ai, battle|
    # Check whether user is faster than its foe(s) and could use this move
    user_faster_count = 0
    foe_faster_count = 0
    ai.each_foe_battler(user.side) do |b, i|
      if user.faster_than?(b)
        user_faster_count += 1
      else
        foe_faster_count += 1
      end
    end
    next NewAI::MOVE_USELESS_SCORE if user_faster_count == 0
    score += 15 if foe_faster_count == 0
    # Effects that make the target unlikely to act before the user
    if ai.trainer.high_skill?
      if !target.can_attack?
        score += 15
      elsif target.effects[PBEffects::Confusion] > 1 ||
            target.effects[PBEffects::Attract] == user.index
        score += 10
      elsif target.battler.paralyzed?
        score += 5
      end
    end
    # Don't risk using this move if target is weak
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if target.hp <= target.totalhp / 2
      score -= 10 if target.hp <= target.totalhp / 4
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("116",
  proc { |score, move, user, target, ai, battle|
    # Check whether user is faster than the target and could use this move
    next NewAI::MOVE_USELESS_SCORE if target.faster_than?(user)
    # Check whether the target has any damaging moves it could use
    next NewAI::MOVE_USELESS_SCORE if !target.check_for_move { |m| m.damagingMove? }
    # Don't risk using this move if target is weak
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if target.hp <= target.totalhp / 2
      score -= 10 if target.hp <= target.totalhp / 4
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("10B",
  proc { |score, move, user, target, ai, battle|
    if user.battler.takesIndirectDamage?
      score -= (0.6 * (100 - move.rough_accuracy)).to_i   # -0 (100%) to -60 (1%)
    end
    next score
  }
)
AIHandlers::MoveEffectAgainstTargetScore.copy("10B","527")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0FF",
  proc { |move, user, ai, battle|
    next [:HarshSun, :HeavyRain, :StrongWinds, move.move.weatherType].include?(battle.field.weather)
  }
)
AIHandlers::MoveEffectScore.add("0FF",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                                           battle.pbCheckGlobalAbility(:CLOUDNINE)
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.weather != :None
      score -= ai.get_score_for_weather(battle.field.weather, user)
    end
    score += ai.get_score_for_weather(:Sun, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("0FF",
                                            "100")
AIHandlers::MoveEffectScore.add("100",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                                           battle.pbCheckGlobalAbility(:CLOUDNINE)
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.weather != :None
      score -= ai.get_score_for_weather(battle.field.weather, user)
    end
    score += ai.get_score_for_weather(:Rain, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("0FF",
                                            "101")
AIHandlers::MoveEffectScore.add("101",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                                           battle.pbCheckGlobalAbility(:CLOUDNINE)
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.weather != :None
      score -= ai.get_score_for_weather(battle.field.weather, user)
    end
    score += ai.get_score_for_weather(:Sandstorm, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("0FF",
                                            "102")
AIHandlers::MoveEffectScore.add("102",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                                           battle.pbCheckGlobalAbility(:CLOUDNINE)
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.weather != :None
      score -= ai.get_score_for_weather(battle.field.weather, user)
    end
    score += ai.get_score_for_weather(:Hail, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("154",
  proc { |move, user, ai, battle|
    next battle.field.terrain == :Electric
  }
)
AIHandlers::MoveEffectScore.add("154",
  proc { |score, move, user, ai, battle|
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    score += ai.get_score_for_terrain(:Electric, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("155",
  proc { |move, user, ai, battle|
    next battle.field.terrain == :Grassy
  }
)
AIHandlers::MoveEffectScore.add("155",
  proc { |score, move, user, ai, battle|
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    score += ai.get_score_for_terrain(:Grassy, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("156",
  proc { |move, user, ai, battle|
    next battle.field.terrain == :Misty
  }
)
AIHandlers::MoveEffectScore.add("156",
  proc { |score, move, user, ai, battle|
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    score += ai.get_score_for_terrain(:Misty, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("157",
  proc { |move, user, ai, battle|
    next battle.field.terrain == :Psychic
  }
)
AIHandlers::MoveEffectScore.add("157",
  proc { |score, move, user, ai, battle|
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    score += ai.get_score_for_terrain(:Psychic, user, true)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("195",
  proc { |move, user, ai, battle|
    next battle.field.terrain == :None
  }
)
AIHandlers::MoveEffectScore.add("195",
  proc { |score, move, user, ai, battle|
    next score - ai.get_score_for_terrain(battle.field.terrain, user)
  }
)
AIHandlers::MoveFailureCheck.copy("195","525")
AIHandlers::MoveEffectScore.copy("195","525")
#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("103",
  proc { |move, user, ai, battle|
    next user.pbOpposingSide.effects[PBEffects::Spikes] >= 3
  }
)
AIHandlers::MoveEffectScore.add("103",
  proc { |score, move, user, ai, battle|
    inBattleIndices = battle.allSameSideBattlers(user.idxOpposingSide).map { |b| b.pokemonIndex }
    foe_reserves = []
    battle.pbParty(user.idxOpposingSide).each_with_index do |pkmn, idxParty|
      next if !pkmn || !pkmn.able? || inBattleIndices.include?(idxParty)
      if ai.trainer.medium_skill?
        next if pkmn.hasItem?(:HEAVYDUTYBOOTS)
        next if ai.pokemon_airborne?(pkmn)
        next if pkmn.hasAbility?(:MAGICGUARD)
      end
      foe_reserves.push(pkmn)   # pkmn will be affected by Spikes
    end
    next NewAI::MOVE_USELESS_SCORE if foe_reserves.empty?
    multiplier = [10, 7, 5][user.pbOpposingSide.effects[PBEffects::Spikes]]
    score += [multiplier * foe_reserves.length, 30].min
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("104",
  proc { |move, user, ai, battle|
    next user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >= 2
  }
)
AIHandlers::MoveEffectScore.add("104",
  proc { |score, move, user, ai, battle|
    inBattleIndices = battle.allSameSideBattlers(user.idxOpposingSide).map { |b| b.pokemonIndex }
    foe_reserves = []
    battle.pbParty(user.idxOpposingSide).each_with_index do |pkmn, idxParty|
      next if !pkmn || !pkmn.able? || inBattleIndices.include?(idxParty)
      if ai.trainer.medium_skill?
        next if pkmn.hasItem?(:HEAVYDUTYBOOTS)
        next if ai.pokemon_airborne?(pkmn)
        next if !ai.pokemon_can_be_poisoned?(pkmn)
      end
      foe_reserves.push(pkmn)   # pkmn will be affected by Toxic Spikes
    end
    next NewAI::MOVE_USELESS_SCORE if foe_reserves.empty?
    multiplier = [8, 5][user.pbOpposingSide.effects[PBEffects::ToxicSpikes]]
    score += [multiplier * foe_reserves.length, 30].min
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("105",
  proc { |move, user, ai, battle|
    next user.pbOpposingSide.effects[PBEffects::StealthRock]
    next user.pbOpposingSide.effects[PBEffects::CometShards]
  }
)
AIHandlers::MoveEffectScore.add("105",
  proc { |score, move, user, ai, battle|
    inBattleIndices = battle.allSameSideBattlers(user.idxOpposingSide).map { |b| b.pokemonIndex }
    foe_reserves = []
    battle.pbParty(user.idxOpposingSide).each_with_index do |pkmn, idxParty|
      next if !pkmn || !pkmn.able? || inBattleIndices.include?(idxParty)
      if ai.trainer.medium_skill?
        next if pkmn.hasItem?(:HEAVYDUTYBOOTS)
        next if pkmn.hasAbility?(:MAGICGUARD)
      end
      foe_reserves.push(pkmn)   # pkmn will be affected by Stealth Rock
    end
    next NewAI::MOVE_USELESS_SCORE if foe_reserves.empty?
    score += [10 * foe_reserves.length, 30].min
    next score
  }
)
AIHandlers::MoveFailureCheck.copy("105","500")
AIHandlers::MoveEffectScore.copy("105","500")
#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("153",
  proc { |move, user, ai, battle|
    next user.pbOpposingSide.effects[PBEffects::StickyWeb]
  }
)
AIHandlers::MoveEffectScore.add("153",
  proc { |score, move, user, ai, battle|
    inBattleIndices = battle.allSameSideBattlers(user.idxOpposingSide).map { |b| b.pokemonIndex }
    foe_reserves = []
    battle.pbParty(user.idxOpposingSide).each_with_index do |pkmn, idxParty|
      next if !pkmn || !pkmn.able? || inBattleIndices.include?(idxParty)
      if ai.trainer.medium_skill?
        next if pkmn.hasItem?(:HEAVYDUTYBOOTS)
        next if ai.pokemon_airborne?(pkmn)
      end
      foe_reserves.push(pkmn)   # pkmn will be affected by Sticky Web
    end
    next NewAI::MOVE_USELESS_SCORE if foe_reserves.empty?
    score += [8 * foe_reserves.length, 30].min
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("17A",
  proc { |move, user, ai, battle|
    has_effect = false
    2.times do |side|
      effects = battle.sides[side].effects
      move.move.number_effects.each do |e|
        next if effects[e] == 0
        has_effect = true
        break
      end
      break if has_effect
      move.move.boolean_effects.each do |e|
        next if !effects[e]
        has_effect = true
        break
      end
      break if has_effect
    end
    next !has_effect
  }
)
AIHandlers::MoveEffectScore.add("17A",
  proc { |score, move, user, ai, battle|
    if ai.trainer.medium_skill?
      good_effects = [:AuroraVeil, :LightScreen, :Mist, :Rainbow, :Reflect,
                      :Safeguard, :SeaOfFire, :Swamp, :Tailwind].map! { |e| PBEffects.const_get(e) }
      bad_effects = [:Spikes, :StealthRock, :StickyWeb, :ToxicSpikes, :CometShards].map! { |e| PBEffects.const_get(e) }
      bad_effects.each do |e|
        score += 10 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
        score -= 10 if ![0, 1, false, nil].include?(user.pbOpposingSide.effects[e])
      end
      if ai.trainer.high_skill?
        good_effects.each do |e|
          score += 10 if ![0, 1, false, nil].include?(user.pbOpposingSide.effects[e])
          score -= 10 if ![0, false, nil].include?(user.pbOwnSide.effects[e])
        end
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("10C",
  proc { |move, user, ai, battle|
    next true if user.effects[PBEffects::Substitute] > 0
    next user.hp <= [user.totalhp / 4, 1].max
  }
)
AIHandlers::MoveEffectScore.add("10C",
  proc { |score, move, user, ai, battle|
    # Prefer more the higher the user's HP
    if ai.trainer.has_skill_flag?("HPAware")
      score += (10 * user.hp.to_f / user.totalhp).round
    end
    # Prefer if foes don't know any moves that can bypass a substitute
    ai.each_foe_battler(user.side) do |b, i|
      score += 5 if !b.check_for_move { |m| m.ignoresSubstitute?(b.battler) }
    end
    # Prefer if the user lost more than a Substitute's worth of HP from the last
    # attack against it
    score += 7 if user.battler.lastHPLost >= user.totalhp / 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("110",
  proc { |score, move, user, ai, battle|
    # Score for raising user's Speed
    if Settings::MECHANICS_GENERATION >= 8
      score = AIHandlers.apply_move_effect_score("01F",
         score, move, user, ai, battle)
    end
    # Score for removing various effects
    score += 10 if user.effects[PBEffects::Trapping] > 0
    score += 15 if user.effects[PBEffects::LeechSeed] >= 0
    if battle.pbAbleNonActiveCount(user.idxOwnSide) > 0
      score += 15 if user.pbOwnSide.effects[PBEffects::Spikes] > 0
      score += 15 if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
      score += 20 if user.pbOwnSide.effects[PBEffects::StealthRock]
      score += 15 if user.pbOwnSide.effects[PBEffects::StickyWeb]
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("111",
  proc { |move, user, target, ai, battle|
    next battle.positions[target.index].effects[PBEffects::FutureSightCounter] > 0
  }
)
AIHandlers::MoveEffectScore.add("111",
  proc { |score, move, user, ai, battle|
    # Future Sight tends to be wasteful if down to last Pokémon
    score -= 20 if battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("120",
  proc { |move, user, ai, battle|
    num_targets = 0
    idxUserOwner = battle.pbGetOwnerIndexFromBattlerIndex(user.index)
    ai.each_ally(user.side) do |b, i|
      next if battle.pbGetOwnerIndexFromBattlerIndex(b.index) != idxUserOwner
      next if !b.battler.near?(user.battler)
      num_targets += 1
    end
    next num_targets != 1
  }
)
AIHandlers::MoveEffectScore.add("120",
  proc { |score, move, user, ai, battle|
    next score - 30   # Usually no point in using this
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("172",
  proc { |score, move, user, ai, battle|
    ai.each_foe_battler(user.side) do |b|
      next if !b.battler.affectedByContactEffect?
      next if !b.battler.pbCanBurn?(user.battler, false, move.move)
      if ai.trainer.high_skill?
        next if !b.check_for_move { |m| m.pbContactMove?(b.battler) }
      end
      score += 10   # Possible to burn
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
=begin
AIHandlers::MoveEffectScore.add("AllBattlersLoseHalfHPUserSkipsNextTurn",
  proc { |score, move, user, ai, battle|
    # HP halving
    foe_hp_lost = 0
    ally_hp_lost = 0
    ai.each_battler do |b, i|
      next if b.hp == 1
      if b.battler.opposes?(user.battler)
        foe_hp_lost += b.hp / 2
      else
        ally_hp_lost += b.hp / 2
      end
    end
    score += 20 * foe_hp_lost / ally_hp_lost
    score -= 20 * ally_hp_lost / foe_hp_lost
    # Recharging
    score = AIHandlers.apply_move_effect_score("AttackAndSkipNextTurn",
       score, move, user, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("UserLosesHalfHP",
  proc { |score, move, user, ai, battle|
    score = AIHandlers.apply_move_effect_score("UserLosesHalfOfTotalHP",
       score, move, user, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("StartSunWeather",
                                            "StartShadowSkyWeather")
AIHandlers::MoveEffectScore.add("StartShadowSkyWeather",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if battle.pbCheckGlobalAbility(:AIRLOCK) ||
                                           battle.pbCheckGlobalAbility(:CLOUDNINE)
    # Not worth it at lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 15 if user.hp < user.totalhp / 2
    end
    if ai.trainer.high_skill? && battle.field.weather != :None
      score -= ai.get_score_for_weather(battle.field.weather, user)
    end
    score += ai.get_score_for_weather(:ShadowSky, user, true)
    next score
  }
)
#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("RemoveAllScreensAndSafeguard",
  proc { |move, user, ai, battle|
    will_fail = true
    battle.sides.each do |side|
      will_fail = false if side.effects[PBEffects::AuroraVeil] > 0 ||
                           side.effects[PBEffects::LightScreen] > 0 ||
                           side.effects[PBEffects::Reflect] > 0 ||
                           side.effects[PBEffects::Safeguard] > 0
    end
    next will_fail
  }
)
AIHandlers::MoveEffectScore.add("RemoveAllScreensAndSafeguard",
  proc { |score, move, user, ai, battle|
    foe_side = user.pbOpposingSide
    # Useless if the foe's side has no screens/Safeguard to remove, or if
    # they'll end this round anyway
    if foe_side.effects[PBEffects::AuroraVeil] <= 1 &&
       foe_side.effects[PBEffects::LightScreen] <= 1 &&
       foe_side.effects[PBEffects::Reflect] <= 1 &&
       foe_side.effects[PBEffects::Safeguard] <= 1
      next NewAI::MOVE_USELESS_SCORE
    end
    # Prefer removing opposing screens
    score = AIHandlers.apply_move_effect_score("RemoveScreens",
       score, move, user, ai, battle)
    # Don't prefer removing same side screens
    ai.each_foe_battler(user.side) do |b, i|
      score -= AIHandlers.apply_move_effect_score("RemoveScreens",
         0, move, b, ai, battle)
      break
    end
    # Safeguard
    score += 10 if foe_side.effects[PBEffects::Safeguard] > 0
    score -= 10 if user.pbOwnSide.effects[PBEffects::Safeguard] > 0
    next score
  }
)
=end