#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("003",
  proc { |move, user, target, ai, battle|
    next move.statusMove? && !target.battler.pbCanSleep?(user.battler, false, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("003",
  proc { |score, move, user, target, ai, battle|
    useless_score = (move.statusMove?) ? NewAI::MOVE_USELESS_SCORE : score
    next useless_score if target.effects[PBEffects::Yawn] > 0   # Target is going to fall asleep anyway
    # No score modifier if the sleep will be removed immediately
    next useless_score if target.has_active_item?([:CHESTOBERRY, :LUMBERRY])
    next useless_score if target.faster_than?(user) &&
                          target.has_active_ability?(:HYDRATION) &&
                          [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
    if target.battler.pbCanSleep?(user.battler, false, move.move)
      add_effect = move.get_score_change_for_additional_effect(user, target)
      next useless_score if add_effect == -999   # Additional effect will be negated
      score += add_effect
      # Inherent preference
      score += 15
      # Prefer if the user or an ally has a move/ability that is better if the target is asleep
      ai.each_same_side_battler(user.side) do |b, i|
        score += 5 if b.has_move_with_function?("07D",
                                                "07F",
                                                "0DE",
                                                "10F")
        score += 10 if b.has_active_ability?(:BADDREAMS)
      end
      # Don't prefer if target benefits from having the sleep status problem
      # NOTE: The target's Guts/Quick Feet will benefit from the target being
      #       asleep, but the target won't (usually) be able to make use of
      #       them, so they're not worth considering.
      score -= 10 if target.has_active_ability?(:EARLYBIRD)
      score -= 8 if target.has_active_ability?(:MARVELSCALE)
      # Don't prefer if target has a move it can use while asleep
      score -= 8 if target.check_for_move { |m| m.usableWhenAsleep? }
      # Don't prefer if the target can heal itself (or be healed by an ally)
      if target.has_active_ability?(:SHEDSKIN)
        score -= 8
      elsif target.has_active_ability?(:HYDRATION) &&
            [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
        score -= 15
      end
      ai.each_same_side_battler(target.side) do |b, i|
        score -= 8 if i != target.index && b.has_active_ability?(:HEALER)
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("004",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Yawn] > 0
    next true if !target.battler.pbCanSleep?(user.battler, false, move.move)
    next false
  }
)
AIHandlers::MoveEffectAgainstTargetScore.copy("003",
                                                        "004")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("005",
  proc { |move, user, target, ai, battle|
    next move.statusMove? && !target.battler.pbCanPoison?(user.battler, false, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("005",
  proc { |score, move, user, target, ai, battle|
    useless_score = (move.statusMove?) ? NewAI::MOVE_USELESS_SCORE : score
    next useless_score if target.has_active_ability?(:POISONHEAL)
    # No score modifier if the poisoning will be removed immediately
    next useless_score if target.has_active_item?([:PECHABERRY, :LUMBERRY])
    next useless_score if target.faster_than?(user) &&
                          target.has_active_ability?(:HYDRATION) &&
                          [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
    if target.battler.pbCanPoison?(user.battler, false, move.move)
      add_effect = move.get_score_change_for_additional_effect(user, target)
      next useless_score if add_effect == -999   # Additional effect will be negated
      score += add_effect
      # Inherent preference
      score += 15
      # Prefer if the target is at high HP
      if ai.trainer.has_skill_flag?("HPAware")
        score += 15 * target.hp / target.totalhp
      end
      # Prefer if the user or an ally has a move/ability that is better if the target is poisoned
      ai.each_same_side_battler(user.side) do |b, i|
        score += 5 if b.has_move_with_function?("07B",
                                                "07F")
        score += 10 if b.has_active_ability?(:MERCILESS)
      end
      # Don't prefer if target benefits from having the poison status problem
      score -= 8 if target.has_active_ability?([:GUTS, :MARVELSCALE, :QUICKFEET, :TOXICBOOST])
      score -= 25 if target.has_active_ability?(:POISONHEAL)
      score -= 20 if target.has_active_ability?(:SYNCHRONIZE) &&
                     user.battler.pbCanPoisonSynchronize?(target.battler)
      score -= 5 if target.has_move_with_function?("07E",
                                                   "018")
      score -= 15 if target.check_for_move { |m|
        m.function == "01B" && user.battler.pbCanPoison?(target.battler, false, m)
      }
      # Don't prefer if the target won't take damage from the poison
      score -= 20 if !target.battler.takesIndirectDamage?
      # Don't prefer if the target can heal itself (or be healed by an ally)
      if target.has_active_ability?(:SHEDSKIN)
        score -= 8
      elsif target.has_active_ability?(:HYDRATION) &&
            [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
        score -= 15
      end
      ai.each_same_side_battler(target.side) do |b, i|
        score -= 8 if i != target.index && b.has_active_ability?(:HEALER)
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("159",
  proc { |move, user, target, ai, battle|
    next !target.battler.pbCanPoison?(user.battler, false, move.move) &&
         !target.battler.pbCanLowerStatStage?(:SPEED, user.battler, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("159",
  proc { |score, move, user, target, ai, battle|
    poison_score = AIHandlers.apply_move_effect_against_target_score("005",
       0, move, user, target, ai, battle)
    score += poison_score if poison_score != NewAI::MOVE_USELESS_SCORE
    score = ai.get_score_for_target_stat_drop(score, target, move.move.statDown, false)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("005",
                                                         "006")
AIHandlers::MoveEffectAgainstTargetScore.copy("005",
                                                        "006")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("007",
  proc { |move, user, target, ai, battle|
    next move.statusMove? && !target.battler.pbCanParalyze?(user.battler, false, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("007",
  proc { |score, move, user, target, ai, battle|
    useless_score = (move.statusMove?) ? NewAI::MOVE_USELESS_SCORE : score
    # No score modifier if the paralysis will be removed immediately
    next useless_score if target.has_active_item?([:CHERIBERRY, :LUMBERRY])
    next useless_score if target.faster_than?(user) &&
                          target.has_active_ability?(:HYDRATION) &&
                          [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
    if target.battler.pbCanParalyze?(user.battler, false, move.move)
      add_effect = move.get_score_change_for_additional_effect(user, target)
      next useless_score if add_effect == -999   # Additional effect will be negated
      score += add_effect
      # Inherent preference (because of the chance of full paralysis)
      score += 10
      # Prefer if the target is faster than the user but will become slower if
      # paralysed
      if target.faster_than?(user)
        user_speed = user.rough_stat(:SPEED)
        target_speed = target.rough_stat(:SPEED)
        score += 15 if target_speed < user_speed * ((Settings::MECHANICS_GENERATION >= 7) ? 2 : 4)
      end
      # Prefer if the target is confused or infatuated, to compound the turn skipping
      score += 7 if target.effects[PBEffects::Confusion] > 1
      score += 7 if target.effects[PBEffects::Attract] >= 0
      # Prefer if the user or an ally has a move/ability that is better if the target is paralysed
      ai.each_same_side_battler(user.side) do |b, i|
        score += 5 if b.has_move_with_function?("07C",
                                                "07F")
      end
      # Don't prefer if target benefits from having the paralysis status problem
      score -= 8 if target.has_active_ability?([:GUTS, :MARVELSCALE, :QUICKFEET])
      score -= 20 if target.has_active_ability?(:SYNCHRONIZE) &&
                     user.battler.pbCanParalyzeSynchronize?(target.battler)
      score -= 5 if target.has_move_with_function?("07E",
                                                   "018")
      score -= 15 if target.check_for_move { |m|
        m.function == "01B" && user.battler.pbCanParalyze?(target.battler, false, m)
      }
      # Don't prefer if the target can heal itself (or be healed by an ally)
      if target.has_active_ability?(:SHEDSKIN)
        score -= 8
      elsif target.has_active_ability?(:HYDRATION) &&
            [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
        score -= 15
      end
      ai.each_same_side_battler(target.side) do |b, i|
        score -= 8 if i != target.index && b.has_active_ability?(:HEALER)
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("007",
  proc { |move, user, target, ai, battle|
    eff = target.effectiveness_of_type_against_battler(move.rough_type, user, move)
    next true if Effectiveness.ineffective?(eff)
    next true if move.statusMove? && !target.battler.pbCanParalyze?(user.battler, false, move.move)
    next false
  }
)
AIHandlers::MoveEffectAgainstTargetScore.copy("007",
                                                        "007")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.copy("007",
                                                        "008")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("009",
  proc { |score, move, user, target, ai, battle|
    paralyze_score = AIHandlers.apply_move_effect_against_target_score("007",
       0, move, user, target, ai, battle)
    flinch_score = AIHandlers.apply_move_effect_against_target_score("00F",
       0, move, user, target, ai, battle)
    if paralyze_score == NewAI::MOVE_USELESS_SCORE &&
       flinch_score == NewAI::MOVE_USELESS_SCORE
      next NewAI::MOVE_USELESS_SCORE
    end
    score += paralyze_score if paralyze_score != NewAI::MOVE_USELESS_SCORE
    score += flinch_score if flinch_score != NewAI::MOVE_USELESS_SCORE
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("00A",
  proc { |move, user, target, ai, battle|
    next move.statusMove? && !target.battler.pbCanBurn?(user.battler, false, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("00A",
  proc { |score, move, user, target, ai, battle|
    useless_score = (move.statusMove?) ? NewAI::MOVE_USELESS_SCORE : score
    # No score modifier if the burn will be removed immediately
    next useless_score if target.has_active_item?([:RAWSTBERRY, :LUMBERRY])
    next useless_score if target.faster_than?(user) &&
                          target.has_active_ability?(:HYDRATION) &&
                          [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
    if target.battler.pbCanBurn?(user.battler, false, move.move)
      add_effect = move.get_score_change_for_additional_effect(user, target)
      next useless_score if add_effect == -999   # Additional effect will be negated
      score += add_effect
      # Inherent preference
      score += 15
      # Prefer if the target knows any physical moves that will be weaked by a burn
      if !target.has_active_ability?(:GUTS) && target.check_for_move { |m| m.physicalMove? }
        score += 8
        score += 8 if !target.check_for_move { |m| m.specialMove? }
      end
      # Prefer if the user or an ally has a move/ability that is better if the target is burned
      ai.each_same_side_battler(user.side) do |b, i|
        score += 5 if b.has_move_with_function?("07F")
      end
      # Don't prefer if target benefits from having the burn status problem
      score -= 8 if target.has_active_ability?([:FLAREBOOST, :GUTS, :MARVELSCALE, :QUICKFEET])
      score -= 5 if target.has_active_ability?(:HEATPROOF)
      score -= 20 if target.has_active_ability?(:SYNCHRONIZE) &&
                     user.battler.pbCanBurnSynchronize?(target.battler)
      score -= 5 if target.has_move_with_function?("07E",
                                                   "018")
      score -= 15 if target.check_for_move { |m|
        m.function == "01B" && user.battler.pbCanBurn?(target.battler, false, m)
      }
      # Don't prefer if the target won't take damage from the burn
      score -= 20 if !target.battler.takesIndirectDamage?
      # Don't prefer if the target can heal itself (or be healed by an ally)
      if target.has_active_ability?(:SHEDSKIN)
        score -= 8
      elsif target.has_active_ability?(:HYDRATION) &&
            [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
        score -= 15
      end
      ai.each_same_side_battler(target.side) do |b, i|
        score -= 8 if i != target.index && b.has_active_ability?(:HEALER)
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================


#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("00B",
  proc { |score, move, user, target, ai, battle|
    burn_score = AIHandlers.apply_move_effect_against_target_score("00A",
       0, move, user, target, ai, battle)
    flinch_score = AIHandlers.apply_move_effect_against_target_score("00F",
       0, move, user, target, ai, battle)
    if burn_score == NewAI::MOVE_USELESS_SCORE &&
       flinch_score == NewAI::MOVE_USELESS_SCORE
      next NewAI::MOVE_USELESS_SCORE
    end
    score += burn_score if burn_score != NewAI::MOVE_USELESS_SCORE
    score += flinch_score if flinch_score != NewAI::MOVE_USELESS_SCORE
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("00C",
  proc { |move, user, target, ai, battle|
    next move.statusMove? && !target.battler.pbCanFreeze?(user.battler, false, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("00C",
  proc { |score, move, user, target, ai, battle|
    useless_score = (move.statusMove?) ? NewAI::MOVE_USELESS_SCORE : score
    # No score modifier if the freeze will be removed immediately
    next useless_score if target.has_active_item?([:ASPEARBERRY, :LUMBERRY])
    next useless_score if target.faster_than?(user) &&
                          target.has_active_ability?(:HYDRATION) &&
                          [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
    if target.battler.pbCanFreeze?(user.battler, false, move.move)
      add_effect = move.get_score_change_for_additional_effect(user, target)
      next useless_score if add_effect == -999   # Additional effect will be negated
      score += add_effect
      # Inherent preference
      score += 15
      # Prefer if the user or an ally has a move/ability that is better if the target is frozen
      ai.each_same_side_battler(user.side) do |b, i|
        score += 5 if b.has_move_with_function?("DoublePowerIfTargetStatusProblem")
      end
      # Don't prefer if target benefits from having the frozen status problem
      # NOTE: The target's Guts/Quick Feet will benefit from the target being
      #       frozen, but the target won't be able to make use of them, so
      #       they're not worth considering.
      score -= 8 if target.has_active_ability?(:MARVELSCALE)
      # Don't prefer if the target knows a move that can thaw it
      score -= 15 if target.check_for_move { |m| m.thawsUser? }
      # Don't prefer if the target can heal itself (or be healed by an ally)
      if target.has_active_ability?(:SHEDSKIN)
        score -= 8
      elsif target.has_active_ability?(:HYDRATION) &&
            [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
        score -= 15
      end
      ai.each_same_side_battler(target.side) do |b, i|
        score -= 8 if i != target.index && b.has_active_ability?(:HEALER)
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.copy("00C",
                                                        "135")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.copy("00C",
                                                        "00D")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("00E",
  proc { |score, move, user, target, ai, battle|
    freeze_score = AIHandlers.apply_move_effect_against_target_score("00C",
       0, move, user, target, ai, battle)
    flinch_score = AIHandlers.apply_move_effect_against_target_score("00F",
       0, move, user, target, ai, battle)
    if freeze_score == NewAI::MOVE_USELESS_SCORE &&
       flinch_score == NewAI::MOVE_USELESS_SCORE
      next NewAI::MOVE_USELESS_SCORE
    end
    score += freeze_score if freeze_score != NewAI::MOVE_USELESS_SCORE
    score += flinch_score if flinch_score != NewAI::MOVE_USELESS_SCORE
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("017",
  proc { |score, move, user, target, ai, battle|
    # No score modifier if the status problem will be removed immediately
    next score if target.has_active_item?(:LUMBERRY)
    next score if target.faster_than?(user) &&
                  target.has_active_ability?(:HYDRATION) &&
                  [:Rain, :HeavyRain].include?(target.battler.effectiveWeather)
    # Scores for the possible effects
    ["007", "00A", "00C"].each do |function|
      effect_score = AIHandlers.apply_move_effect_against_target_score(function,
         0, move, user, target, ai, battle)
      score += effect_score / 3 if effect_score != NewAI::MOVE_USELESS_SCORE
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("01B",
  proc { |move, user, ai, battle|
    next user.status == :NONE
  }
)
AIHandlers::MoveFailureAgainstTargetCheck.add("01B",
  proc { |move, user, target, ai, battle|
    next !target.battler.pbCanInflictStatus?(user.status, user.battler, false, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("01B",
  proc { |score, move, user, target, ai, battle|
    # Curing the user's status problem
    score += 15 if !user.wants_status_problem?(user.status)
    # Giving the target a status problem
    function = {
      :SLEEP     => "003",
      :PARALYSIS => "007",
      :POISON    => "005",
      :BURN      => "00A",
      :FROZEN    => "00C"
    }[user.status]
    if function
      new_score = AIHandlers.apply_move_effect_against_target_score(function,
         score, move, user, target, ai, battle)
      next new_score if new_score != NewAI::MOVE_USELESS_SCORE
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("018",
  proc { |move, user, ai, battle|
    next ![:BURN, :POISON, :PARALYSIS].include?(user.status)
  }
)
AIHandlers::MoveEffectScore.add("018",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if user.wants_status_problem?(user.status)
    next score + 20
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("019",
  proc { |move, user, ai, battle|
    next battle.pbParty(user.index).none? { |pkmn| pkmn&.able? && pkmn.status != :NONE }
  }
)
AIHandlers::MoveEffectScore.add("019",
  proc { |score, move, user, ai, battle|
    score = NewAI::MOVE_BASE_SCORE   # Ignore the scores for each targeted battler calculated earlier
    battle.pbParty(user.index).each do |pkmn|
      next if !pkmn || pkmn.status == :NONE
      next if pkmn.status == :SLEEP && pkmn.statusCount == 1   # About to wake up
      score += 12
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("15A",
  proc { |score, move, user, target, ai, battle|
    add_effect = move.get_score_change_for_additional_effect(user, target)
    next score if add_effect == -999   # Additional effect will be negated
    if target.status == :BURN
      score -= add_effect
      if target.wants_status_problem?(:BURN)
        score += 15
      else
        score -= 10
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("056",
  proc { |move, user, ai, battle|
    next user.pbOwnSide.effects[PBEffects::Safeguard] > 0
  }
)
AIHandlers::MoveEffectScore.add("056",
  proc { |score, move, user, ai, battle|
    # Not worth it if Misty Terrain is already safeguarding all user side battlers
    if battle.field.terrain == :Misty &&
       (battle.field.terrainDuration > 1 || battle.field.terrainDuration < 0)
      already_immune = true
      ai.each_same_side_battler(user.side) do |b, i|
        already_immune = false if !b.battler.affectedByTerrain?
      end
      next NewAI::MOVE_USELESS_SCORE if already_immune
    end
    # Tends to be wasteful if the foe just has one Pokémon left
    next score - 20 if battle.pbAbleNonActiveCount(user.idxOpposingSide) == 0
    # Prefer for each user side battler
    ai.each_same_side_battler(user.side) { |b, i| score += 15 }
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("00F",
  proc { |score, move, user, target, ai, battle|
    next score if target.faster_than?(user) || target.effects[PBEffects::Substitute] > 0
    next score if target.has_active_ability?(:INNERFOCUS) && !battle.moldBreaker
    add_effect = move.get_score_change_for_additional_effect(user, target)
    next score if add_effect == -999   # Additional effect will be negated
    score += add_effect
    # Inherent preference
    score += 15
    # Prefer if the target is paralysed, confused or infatuated, to compound the
    # turn skipping
    score += 8 if target.status == :PARALYSIS ||
                  target.effects[PBEffects::Confusion] > 1 ||
                  target.effects[PBEffects::Attract] >= 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.copy("00F",
                                                        "011")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("012",
  proc { |move, user, ai, battle|
    next user.turnCount > 0
  }
)
AIHandlers::MoveEffectAgainstTargetScore.copy("00F",
                                                        "012")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("078",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.copy("00F",
                                                        "078")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("013",
  proc { |move, user, target, ai, battle|
    next move.statusMove? && !target.battler.pbCanConfuse?(user.battler, false, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("013",
  proc { |score, move, user, target, ai, battle|
    # No score modifier if the status problem will be removed immediately
    next score if target.has_active_item?(:PERSIMBERRY)
    if target.battler.pbCanConfuse?(user.battler, false, move.move)
      add_effect = move.get_score_change_for_additional_effect(user, target)
      next score if add_effect == -999   # Additional effect will be negated
      score += add_effect
      # Inherent preference
      score += 10
      # Prefer if the target is at high HP
      if ai.trainer.has_skill_flag?("HPAware")
        score += 20 * target.hp / target.totalhp
      end
      # Prefer if the target is paralysed or infatuated, to compound the turn skipping
      score += 8 if target.status == :PARALYSIS || target.effects[PBEffects::Attract] >= 0
      # Don't prefer if target benefits from being confused
      score -= 15 if target.has_active_ability?(:TANGLEDFEET)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.copy("013",
                                                        "015")

#===============================================================================
#
#===============================================================================
=begin
AIHandlers::MoveFailureAgainstTargetCheck.add("AttractTarget",
  proc { |move, user, target, ai, battle|
    next move.statusMove? && !target.battler.pbCanAttract?(user.battler, false)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("AttractTarget",
  proc { |score, move, user, target, ai, battle|
    if target.battler.pbCanAttract?(user.battler, false)
      add_effect = move.get_score_change_for_additional_effect(user, target)
      next score if add_effect == -999   # Additional effect will be negated
      score += add_effect
      # Inherent preference
      score += 15
      # Prefer if the target is paralysed or confused, to compound the turn skipping
      score += 8 if target.status == :PARALYSIS || target.effects[PBEffects::Confusion] > 1
      # Don't prefer if the target can infatuate the user because of this move
      score -= 15 if target.has_active_item?(:DESTINYKNOT) &&
                     user.battler.pbCanAttract?(target.battler, false)
      # Don't prefer if the user has another way to infatuate the target
      score -= 15 if move.statusMove? && user.has_active_ability?(:CUTECHARM)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("SetUserTypesBasedOnEnvironment",
  proc { |move, user, ai, battle|
    next true if !user.battler.canChangeType?
    new_type = nil
    terr_types = Battle::Move::SetUserTypesBasedOnEnvironment::TERRAIN_TYPES
    terr_type = terr_types[battle.field.terrain]
    if terr_type && GameData::Type.exists?(terr_type)
      new_type = terr_type
    else
      env_types = Battle::Move::SetUserTypesBasedOnEnvironment::ENVIRONMENT_TYPES
      new_type = env_types[battle.environment] || :NORMAL
      new_type = :NORMAL if !GameData::Type.exists?(new_type)
    end
    next !GameData::Type.exists?(new_type) || !user.battler.pbHasOtherType?(new_type)
  }
)
AIHandlers::MoveEffectScore.add("SetUserTypesBasedOnEnvironment",
  proc { |score, move, user, ai, battle|
    # Determine the new type
    new_type = nil
    terr_types = Battle::Move::SetUserTypesBasedOnEnvironment::TERRAIN_TYPES
    terr_type = terr_types[battle.field.terrain]
    if terr_type && GameData::Type.exists?(terr_type)
      new_type = terr_type
    else
      env_types = Battle::Move::SetUserTypesBasedOnEnvironment::ENVIRONMENT_TYPES
      new_type = env_types[battle.environment] || :NORMAL
      new_type = :NORMAL if !GameData::Type.exists?(new_type)
    end
    # Check if any user's moves will get STAB because of the type change
    score += 14 if user.has_damaging_move_of_type?(new_type)
    # Check if any user's moves will lose STAB because of the type change
    user.pbTypes(true).each do |type|
      next if type == new_type
      score -= 14 if user.has_damaging_move_of_type?(type)
    end
    # NOTE: Other things could be considered, like the foes' moves'
    #       effectivenesses against the current and new user's type(s), and
    #       which set of STAB is more beneficial. However, I'm keeping this
    #       simple because, if you know this move, you probably want to use it
    #       just because.
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("SetUserTypesToResistLastAttack",
  proc { |move, user, target, ai, battle|
    next true if !user.battler.canChangeType?
    next true if !target.battler.lastMoveUsed || !target.battler.lastMoveUsedType ||
                 GameData::Type.get(target.battler.lastMoveUsedType).pseudo_type
    has_possible_type = false
    GameData::Type.each do |t|
      next if t.pseudo_type || user.has_type?(t.id) ||
              !Effectiveness.resistant_type?(target.battler.lastMoveUsedType, t.id)
      has_possible_type = true
      break
    end
    next !has_possible_type
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("SetUserTypesToResistLastAttack",
  proc { |score, move, user, target, ai, battle|
    effectiveness = user.effectiveness_of_type_against_battler(target.battler.lastMoveUsedType, target)
    if Effectiveness.ineffective?(effectiveness)
      next NewAI::MOVE_USELESS_SCORE
    elsif Effectiveness.super_effective?(effectiveness)
      score += 15
    elsif Effectiveness.normal?(effectiveness)
      score += 10
    else   # Not very effective
      score += 5
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("SetUserTypesToTargetTypes",
  proc { |move, user, target, ai, battle|
    next true if !user.battler.canChangeType?
    next true if target.pbTypes(true).empty?
    next true if user.pbTypes == target.pbTypes &&
                 user.effects[PBEffects::ExtraType] == target.effects[PBEffects::ExtraType]
    next false
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("SetUserTypesToUserMoveType",
  proc { |move, user, ai, battle|
    next true if !user.battler.canChangeType?
    has_possible_type = false
    user.battler.eachMoveWithIndex do |m, i|
      break if Settings::MECHANICS_GENERATION >= 6 && i > 0
      next if GameData::Type.get(m.type).pseudo_type
      next if user.has_type?(m.type)
      has_possible_type = true
      break
    end
    next !has_possible_type
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("SetUserTypesToUserMoveType",
  proc { |score, move, user, target, ai, battle|
    possible_types = []
    user.battler.eachMoveWithIndex do |m, i|
      break if Settings::MECHANICS_GENERATION >= 6 && i > 0
      next if GameData::Type.get(m.type).pseudo_type
      next if user.has_type?(m.type)
      possible_types.push(m.type)
    end
    # Check if any user's moves will get STAB because of the type change
    possible_types.each do |type|
      next if !user.has_damaging_move_of_type?(type)
      score += 14
      break
    end
    # NOTE: Other things could be considered, like the foes' moves'
    #       effectivenesses against the current and new user's type(s), and
    #       whether any of the user's moves will lose STAB because of the type
    #       change (and if so, which set of STAB is more beneficial). However,
    #       I'm keeping this simple because, if you know this move, you probably
    #       want to use it just because.
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("SetTargetTypesToPsychic",
  proc { |move, user, target, ai, battle|
    next move.move.pbFailsAgainstTarget?(user.battler, target.battler, false)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("SetTargetTypesToPsychic",
  proc { |score, move, user, target, ai, battle|
    # Prefer if target's foes know damaging moves that are super-effective
    # against Psychic, and don't prefer if they know damaging moves that are
    # ineffective against Psychic
    ai.each_foe_battler(target.side) do |b, i|
      b.battler.eachMove do |m|
        next if !m.damagingMove?
        effectiveness = Effectiveness.calculate(m.pbCalcType(b.battler), :PSYCHIC)
        if Effectiveness.super_effective?(effectiveness)
          score += 10
        elsif Effectiveness.ineffective?(effectiveness)
          score -= 10
        end
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("SetTargetTypesToPsychic",
                                                         "SetTargetTypesToWater")
AIHandlers::MoveEffectAgainstTargetScore.add("SetTargetTypesToWater",
  proc { |score, move, user, target, ai, battle|
    # Prefer if target's foes know damaging moves that are super-effective
    # against Water, and don't prefer if they know damaging moves that are
    # ineffective against Water
    ai.each_foe_battler(target.side) do |b, i|
      b.battler.eachMove do |m|
        next if !m.damagingMove?
        effectiveness = Effectiveness.calculate(m.pbCalcType(b.battler), :WATER)
        if Effectiveness.super_effective?(effectiveness)
          score += 10
        elsif Effectiveness.ineffective?(effectiveness)
          score -= 10
        end
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("SetTargetTypesToWater",
                                                         "AddGhostTypeToTarget")
AIHandlers::MoveEffectAgainstTargetScore.add("AddGhostTypeToTarget",
  proc { |score, move, user, target, ai, battle|
    # Prefer/don't prefer depending on the effectiveness of the target's foes'
    # damaging moves against the added type
    ai.each_foe_battler(target.side) do |b, i|
      b.battler.eachMove do |m|
        next if !m.damagingMove?
        effectiveness = Effectiveness.calculate(m.pbCalcType(b.battler), :GHOST)
        if Effectiveness.super_effective?(effectiveness)
          score += 10
        elsif Effectiveness.not_very_effective?(effectiveness)
          score -= 5
        elsif Effectiveness.ineffective?(effectiveness)
          score -= 10
        end
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("AddGhostTypeToTarget",
                                                         "AddGrassTypeToTarget")
AIHandlers::MoveEffectAgainstTargetScore.add("AddGrassTypeToTarget",
  proc { |score, move, user, target, ai, battle|
    # Prefer/don't prefer depending on the effectiveness of the target's foes'
    # damaging moves against the added type
    ai.each_foe_battler(target.side) do |b, i|
      b.battler.eachMove do |m|
        next if !m.damagingMove?
        effectiveness = Effectiveness.calculate(m.pbCalcType(b.battler), :GRASS)
        if Effectiveness.super_effective?(effectiveness)
          score += 10
        elsif Effectiveness.not_very_effective?(effectiveness)
          score -= 5
        elsif Effectiveness.ineffective?(effectiveness)
          score -= 10
        end
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("UserLosesFireType",
  proc { |move, user, ai, battle|
    next !user.has_type?(:FIRE)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("SetTargetAbilityToSimple",
  proc { |move, user, target, ai, battle|
    next true if !GameData::Ability.exists?(:SIMPLE)
    next move.move.pbFailsAgainstTarget?(user.battler, target.battler, false)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("SetTargetAbilityToSimple",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !target.ability_active?
    old_ability_rating = target.wants_ability?(target.ability_id)
    new_ability_rating = target.wants_ability?(:SIMPLE)
    side_mult = (target.opposes?(user)) ? 1 : -1
    if old_ability_rating > new_ability_rating
      score += 5 * side_mult * [old_ability_rating - new_ability_rating, 3].max
    elsif old_ability_rating < new_ability_rating
      score -= 5 * side_mult * [new_ability_rating - old_ability_rating, 3].max
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("SetTargetAbilityToInsomnia",
  proc { |move, user, target, ai, battle|
    next true if !GameData::Ability.exists?(:INSOMNIA)
    next move.move.pbFailsAgainstTarget?(user.battler, target.battler, false)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("SetTargetAbilityToInsomnia",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !target.ability_active?
    old_ability_rating = target.wants_ability?(target.ability_id)
    new_ability_rating = target.wants_ability?(:INSOMNIA)
    side_mult = (target.opposes?(user)) ? 1 : -1
    if old_ability_rating > new_ability_rating
      score += 5 * side_mult * [old_ability_rating - new_ability_rating, 3].max
    elsif old_ability_rating < new_ability_rating
      score -= 5 * side_mult * [new_ability_rating - old_ability_rating, 3].max
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("SetUserAbilityToTargetAbility",
  proc { |move, user, target, ai, battle|
    next true if user.battler.unstoppableAbility?
    next move.move.pbFailsAgainstTarget?(user.battler, target.battler, false)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("SetUserAbilityToTargetAbility",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !user.ability_active?
    old_ability_rating = user.wants_ability?(user.ability_id)
    new_ability_rating = user.wants_ability?(target.ability_id)
    if old_ability_rating > new_ability_rating
      score += 5 * [old_ability_rating - new_ability_rating, 3].max
    elsif old_ability_rating < new_ability_rating
      score -= 5 * [new_ability_rating - old_ability_rating, 3].max
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("SetTargetAbilityToUserAbility",
  proc { |move, user, target, ai, battle|
    next true if !user.ability || user.ability_id == target.ability_id
    next true if user.battler.ungainableAbility? ||
                 [:POWEROFALCHEMY, :RECEIVER, :TRACE].include?(user.ability_id)
    next move.move.pbFailsAgainstTarget?(user.battler, target.battler, false)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("SetTargetAbilityToUserAbility",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !target.ability_active?
    old_ability_rating = target.wants_ability?(target.ability_id)
    new_ability_rating = target.wants_ability?(user.ability_id)
    side_mult = (target.opposes?(user)) ? 1 : -1
    if old_ability_rating > new_ability_rating
      score += 5 * side_mult * [old_ability_rating - new_ability_rating, 3].max
    elsif old_ability_rating < new_ability_rating
      score -= 5 * side_mult * [new_ability_rating - old_ability_rating, 3].max
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("UserTargetSwapAbilities",
  proc { |move, user, target, ai, battle|
    next true if !user.ability || user.battler.unstoppableAbility? ||
                 user.battler.ungainableAbility? || user.ability_id == :WONDERGUARD
    next move.move.pbFailsAgainstTarget?(user.battler, target.battler, false)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("UserTargetSwapAbilities",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !user.ability_active? && !target.ability_active?
    old_user_ability_rating = user.wants_ability?(user.ability_id)
    new_user_ability_rating = user.wants_ability?(target.ability_id)
    user_diff = new_user_ability_rating - old_user_ability_rating
    user_diff = 0 if !user.ability_active?
    old_target_ability_rating = target.wants_ability?(target.ability_id)
    new_target_ability_rating = target.wants_ability?(user.ability_id)
    target_diff = new_target_ability_rating - old_target_ability_rating
    target_diff = 0 if !target.ability_active?
    side_mult = (target.opposes?(user)) ? 1 : -1
    if user_diff > target_diff
      score += 5 * side_mult * [user_diff - target_diff, 3].max
    elsif target_diff < user_diff
      score -= 5 * side_mult * [target_diff - user_diff, 3].max
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("NegateTargetAbility",
  proc { |move, user, target, ai, battle|
    next move.move.pbFailsAgainstTarget?(user.battler, target.battler, false)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("NegateTargetAbility",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !target.ability_active?
    target_ability_rating = target.wants_ability?(target.ability_id)
    side_mult = (target.opposes?(user)) ? 1 : -1
    if target_ability_rating > 0
      score += 5 * side_mult * [target_ability_rating, 3].max
    elsif target_ability_rating < 0
      score -= 5 * side_mult * [target_ability_rating.abs, 3].max
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("NegateTargetAbilityIfTargetActed",
  proc { |score, move, user, target, ai, battle|
    next score if target.effects[PBEffects::Substitute] > 0
    next score if target.battler.unstoppableAbility? || !target.ability_active?
    next score if user.faster_than?(target)
    target_ability_rating = target.wants_ability?(target.ability_id)
    side_mult = (target.opposes?(user)) ? 1 : -1
    if target_ability_rating > 0
      score += 5 * side_mult * [target_ability_rating, 3].max
    elsif target_ability_rating < 0
      score -= 5 * side_mult * [target_ability_rating.abs, 3].max
    end
    next score
  }
)
=end
#===============================================================================
#
#===============================================================================
# IgnoreTargetAbility

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("119",
  proc { |move, user, ai, battle|
    next true if user.has_active_item?(:IRONBALL)
    next true if user.effects[PBEffects::Ingrain] ||
                 user.effects[PBEffects::SmackDown] ||
                 user.effects[PBEffects::MagnetRise] > 0
    next false
  }
)
AIHandlers::MoveEffectScore.add("119",
  proc { |score, move, user, ai, battle|
    # Move is useless if user is already airborne
    if user.has_type?(:FLYING) ||
       user.has_active_ability?([:LEVITATE,:MULTITOOL]) ||
       user.has_active_item?(:AIRBALLOON) ||
       user.effects[PBEffects::Telekinesis] > 0
      next NewAI::MOVE_USELESS_SCORE
    end
    # Prefer if any foes have damaging Ground-type moves that do 1x or more
    # damage to the user
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.has_damaging_move_of_type?(:GROUND)
      next if Effectiveness.resistant?(user.effectiveness_of_type_against_battler(:GROUND, b))
      score += 10
    end
    # Don't prefer if terrain exists (which the user will no longer be affected by)
    if ai.trainer.medium_skill?
      score -= 8 if battle.field.terrain != :None
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
# HitsTargetInSky

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("11C",
  proc { |score, move, user, target, ai, battle|
    next score if target.effects[PBEffects::Substitute] > 0
    if !target.battler.airborne?
      next score if target.faster_than?(user) ||
                    !target.battler.inTwoTurnAttack?("0C9",
                                                     "0CC")
    end
    # Prefer if the target is airborne
    score += 10
    # Prefer if any allies have damaging Ground-type moves
    ai.each_foe_battler(target.side) do |b, i|
      score += 8 if b.has_damaging_move_of_type?(:GROUND)
    end
    # Don't prefer if terrain exists (which the target will become affected by)
    if ai.trainer.medium_skill?
      score -= 8 if battle.field.terrain != :None
    end
    next score
  }
)

