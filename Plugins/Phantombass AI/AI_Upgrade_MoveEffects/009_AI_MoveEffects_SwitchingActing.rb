#===============================================================================
#
#===============================================================================
=begin
AIHandlers::MoveFailureCheck.add("FleeFromBattle",
  proc { |move, user, ai, battle|
    next !battle.pbCanRun?(user.index) || (user.wild? && user.battler.allAllies.length > 0)
  }
)
AIHandlers::MoveEffectScore.add("FleeFromBattle",
  proc { |score, move, user, ai, battle|
    # Generally don't prefer (don't want to end the battle too easily)
    next score - 20
  }
)
=end
#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0EA",
  proc { |move, user, ai, battle|
    if user.wild?
      next !battle.pbCanRun?(user.index) || user.battler.allAllies.length > 0
    end
    next !battle.pbCanChooseNonActive?(user.index)
  }
)
AIHandlers::MoveEffectScore.add("0EA",
  proc { |score, move, user, ai, battle|
    # Wild Pokémon run from battle - generally don't prefer (don't want to end the battle too easily)
    next score - 20 if user.wild?
    # Trainer-owned Pokémon switch out
    if ai.trainer.has_skill_flag?("ReserveLastPokemon") && battle.pbTeamAbleNonActiveCount(user.index) == 1
      next NewAI::MOVE_USELESS_SCORE   # Don't switch in ace
    end
    # Prefer if the user switching out will lose a negative effect
    score += 20 if user.effects[PBEffects::PerishSong] > 0
    score += 10 if user.effects[PBEffects::Confusion] > 1
    score += 10 if user.effects[PBEffects::Attract] >= 0
    # Consider the user's stat stages
    if user.stages.any? { |key, val| val >= 2 }
      score -= 15
    elsif user.stages.any? { |key, val| val < 0 }
      score += 10
    end
    # Consider the user's end of round damage/healing
    eor_damage = user.rough_end_of_round_damage
    score += 15 if eor_damage > 0
    score -= 15 if eor_damage < 0
    # Prefer if the user doesn't have any damaging moves
    score += 10 if !user.check_for_move { |m| m.damagingMove? }
    # Don't prefer if the user's side has entry hazards on it
    score -= 10 if user.pbOwnSide.effects[PBEffects::Spikes] > 0
    score -= 10 if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
    score -= 10 if user.pbOwnSide.effects[PBEffects::StealthRock]
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("0EE",
  proc { |score, move, user, ai, battle|
    next score if !battle.pbCanChooseNonActive?(user.index)
    # Don't want to switch in ace
    score -= 20 if ai.trainer.has_skill_flag?("ReserveLastPokemon") &&
                   battle.pbTeamAbleNonActiveCount(user.index) == 1
    # Prefer if the user switching out will lose a negative effect
    score += 20 if user.effects[PBEffects::PerishSong] > 0
    score += 10 if user.effects[PBEffects::Confusion] > 1
    score += 10 if user.effects[PBEffects::Attract] >= 0
    # Consider the user's stat stages
    if user.stages.any? { |key, val| val >= 2 }
      score -= 15
    elsif user.stages.any? { |key, val| val < 0 }
      score += 10
    end
    # Consider the user's end of round damage/healing
    eor_damage = user.rough_end_of_round_damage
    score += 15 if eor_damage > 0
    score -= 15 if eor_damage < 0
    # Don't prefer if the user's side has entry hazards on it
    score -= 10 if user.pbOwnSide.effects[PBEffects::Spikes] > 0
    score -= 10 if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
    score -= 10 if user.pbOwnSide.effects[PBEffects::StealthRock]
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("151",
  proc { |move, user, target, ai, battle|
    will_fail = true
    (move.move.statDown.length / 2).times do |i|
      next if !target.battler.pbCanLowerStatStage?(move.move.statDown[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("151",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_drop(score, target, move.move.statDown, false)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.copy("0EE",
                                                        "151")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0ED",
  proc { |move, user, ai, battle|
    next !battle.pbCanChooseNonActive?(user.index)
  }
)
AIHandlers::MoveEffectScore.add("0ED",
  proc { |score, move, user, ai, battle|
    # Don't want to switch in ace
    score -= 20 if ai.trainer.has_skill_flag?("ReserveLastPokemon") &&
                   battle.pbTeamAbleNonActiveCount(user.index) == 1
    # Don't prefer if the user will pass on a negative effect
    score -= 10 if user.effects[PBEffects::Confusion] > 1
    score -= 15 if user.effects[PBEffects::Curse]
    score -= 10 if user.effects[PBEffects::Embargo] > 1
    score -= 15 if user.effects[PBEffects::GastroAcid]
    score -= 10 if user.effects[PBEffects::HealBlock] > 1
    score -= 10 if user.effects[PBEffects::LeechSeed] >= 0
    score -= 20 if user.effects[PBEffects::PerishSong] > 0
    # Prefer if the user will pass on a positive effect
    score += 10 if user.effects[PBEffects::AquaRing]
    score += 10 if user.effects[PBEffects::FocusEnergy] > 0
    score += 10 if user.effects[PBEffects::Ingrain]
    score += 8 if user.effects[PBEffects::MagnetRise] > 1
    score += 10 if user.effects[PBEffects::Substitute] > 0
    # Consider the user's stat stages
    if user.stages.any? { |key, val| val >= 4 }
      score += 25
    elsif user.stages.any? { |key, val| val >= 2 }
      score += 15
    elsif user.stages.any? { |key, val| val < 0 }
      score -= 15
    end
    # Consider the user's end of round damage/healing
    eor_damage = user.rough_end_of_round_damage
    score += 15 if eor_damage > 0
    score -= 15 if eor_damage < 0
    # Prefer if the user doesn't have any damaging moves
    score += 15 if !user.check_for_move { |m| m.damagingMove? }
    # Don't prefer if the user's side has entry hazards on it
    score -= 10 if user.pbOwnSide.effects[PBEffects::Spikes] > 0
    score -= 10 if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
    score -= 10 if user.pbOwnSide.effects[PBEffects::StealthRock]
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0EB",
  proc { |move, user, target, ai, battle|
    next move.move.pbFailsAgainstTarget?(user.battler, target.battler, false)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0EB",
  proc { |score, move, user, target, ai, battle|
    # Ends the battle - generally don't prefer (don't want to end the battle too easily)
    next score - 10 if target.wild?
    # Switches the target out
    next NewAI::MOVE_USELESS_SCORE if target.effects[PBEffects::PerishSong] > 0
    # Don't prefer if target is at low HP and could be knocked out instead
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if target.hp <= target.totalhp / 3
    end
    # Consider the target's stat stages
    if target.stages.any? { |key, val| val >= 2 }
      score += 15
    elsif target.stages.any? { |key, val| val < 0 }
      score -= 15
    end
    # Consider the target's end of round damage/healing
    eor_damage = target.rough_end_of_round_damage
    score -= 15 if eor_damage > 0
    score += 15 if eor_damage < 0
    # Prefer if the target's side has entry hazards on it
    score += 10 if target.pbOwnSide.effects[PBEffects::Spikes] > 0
    score += 10 if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
    score += 10 if target.pbOwnSide.effects[PBEffects::StealthRock]
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0EC",
  proc { |score, move, user, target, ai, battle|
    next score if target.wild?
    # No score modification if the target can't be made to switch out
    next score if !battle.moldBreaker && target.has_active_ability?(:SUCTIONCUPS)
    next score if target.effects[PBEffects::Ingrain]
    # No score modification if the target can't be replaced
    can_switch = false
    battle.eachInTeamFromBattlerIndex(target.index) do |_pkmn, i|
      can_switch = battle.pbCanSwitchIn?(target.index, i)
      break if can_switch
    end
    next score if !can_switch
    # Not score modification if the target has a Substitute
    next score if target.effects[PBEffects::Substitute] > 0
    # Don't want to switch out the target if it will faint from Perish Song
    score -= 20 if target.effects[PBEffects::PerishSong] > 0
    # Consider the target's stat stages
    if target.stages.any? { |key, val| val >= 2 }
      score += 15
    elsif target.stages.any? { |key, val| val < 0 }
      score -= 15
    end
    # Consider the target's end of round damage/healing
    eor_damage = target.rough_end_of_round_damage
    score -= 15 if eor_damage > 0
    score += 15 if eor_damage < 0
    # Prefer if the target's side has entry hazards on it
    score += 10 if target.pbOwnSide.effects[PBEffects::Spikes] > 0
    score += 10 if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
    score += 10 if target.pbOwnSide.effects[PBEffects::StealthRock]
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0CF",
  proc { |score, move, user, target, ai, battle|
    next score if target.effects[PBEffects::Trapping] > 0
    next score if target.effects[PBEffects::Substitute] > 0
    # Prefer if the user has a Binding Band or Grip Claw (because why have it if
    # you don't want to use it?)
    score += 5 if user.has_active_item?([:BINDINGBAND, :GRIPCLAW])
    # Target will take damage at the end of each round from the binding
    score += 10 if target.battler.takesIndirectDamage?
    # Check whether the target will be trapped in battle by the binding
    if target.can_become_trapped?
      score += 8   # Prefer if the target will become trapped by this move
      eor_damage = target.rough_end_of_round_damage
      if eor_damage > 0
        # Prefer if the target will take damage at the end of each round on top
        # of binding damage
        score += 10
      elsif eor_damage < 0
        # Don't prefer if the target will heal itself at the end of each round
        score -= 10
      end
      # Prefer if the target has been Perish Songed
      score += 15 if target.effects[PBEffects::PerishSong] > 0
    end
    # Don't prefer if the target can remove the binding (and the binding has an
    # effect)
    if target.can_become_trapped? || target.battler.takesIndirectDamage?
      if ai.trainer.medium_skill? &&
         target.has_move_with_function?("110")
        score -= 10
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("0D0",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbModifyDamage(power, user.battler, target.battler)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.copy("0CF",
                                                        "0D0")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0EF",
  proc { |move, user, target, ai, battle|
    next false if move.damagingMove?
    next true if target.effects[PBEffects::MeanLook] >= 0
    next true if Settings::MORE_TYPE_EFFECTS && target.has_type?(:GHOST)
    next false
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0EF",
  proc { |score, move, user, target, ai, battle|
    if !target.can_become_trapped? || !battle.pbCanChooseNonActive?(target.index)
      next (move.damagingMove?) ? score : NewAI::MOVE_USELESS_SCORE
    end
    # Not worth trapping if target will faint this round anyway
    eor_damage = target.rough_end_of_round_damage
    if eor_damage >= target.hp
      next (move.damagingMove?) ? score : NewAI::MOVE_USELESS_SCORE
    end
    # Not worth trapping if target can remove the binding
    if ai.trainer.medium_skill? &&
       target.has_move_with_function?("110")
      next (move.damagingMove?) ? score : NewAI::MOVE_USELESS_SCORE
    end
    # Score for being an additional effect
    add_effect = move.get_score_change_for_additional_effect(user, target)
    next score if add_effect == -999   # Additional effect will be negated
    score += add_effect
    # Score for target becoming trapped in battle
    if target.effects[PBEffects::PerishSong] > 0 ||
       target.effects[PBEffects::Attract] >= 0 ||
       target.effects[PBEffects::Confusion] > 0 ||
       eor_damage > 0
      score += 15
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================

AIHandlers::MoveFailureAgainstTargetCheck.add("181",
  proc { |move, user, target, ai, battle|
    next false if move.damagingMove?
    next true if target.effects[PBEffects::Octolock] >= 0
    next true if Settings::MORE_TYPE_EFFECTS && target.has_type?(:GHOST)
    next false
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("181",
  proc { |score, move, user, target, ai, battle|
    # Score for stat drop
    score = ai.get_score_for_target_stat_drop(score, target, [:DEFENSE, 1, :SPECIAL_DEFENSE, 1], false)
    # Score for target becoming trapped in battle
    if target.can_become_trapped? && battle.pbCanChooseNonActive?(target.index)
      # Not worth trapping if target will faint this round anyway
      eor_damage = target.rough_end_of_round_damage
      if eor_damage >= target.hp
        next (move.damagingMove?) ? score : NewAI::MOVE_USELESS_SCORE
      end
      # Not worth trapping if target can remove the binding
      if target.has_move_with_function?("110")
        next (move.damagingMove?) ? score : NewAI::MOVE_USELESS_SCORE
      end
      # Score for target becoming trapped in battle
      if target.effects[PBEffects::PerishSong] > 0 ||
         target.effects[PBEffects::Attract] >= 0 ||
         target.effects[PBEffects::Confusion] > 0 ||
         eor_damage > 0
        score += 15
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("17D",
  proc { |score, move, user, target, ai, battle|
    # NOTE: Don't worry about scoring for the user also becoming trapped in
    #       battle, because it knows this move and accepts what it's getting
    #       itself into.
    if target.can_become_trapped? && battle.pbCanChooseNonActive?(target.index)
      # Not worth trapping if target will faint this round anyway
      eor_damage = target.rough_end_of_round_damage
      if eor_damage >= target.hp
        next (move.damagingMove?) ? score : NewAI::MOVE_USELESS_SCORE
      end
      # Not worth trapping if target can remove the binding
      if ai.trainer.medium_skill? &&
         target.has_move_with_function?("110")
        next (move.damagingMove?) ? score : NewAI::MOVE_USELESS_SCORE
      end
      # Score for target becoming trapped in battle
      if target.effects[PBEffects::PerishSong] > 0 ||
         target.effects[PBEffects::Attract] >= 0 ||
         target.effects[PBEffects::Confusion] > 0 ||
         eor_damage > 0
        score += 15
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("152",
  proc { |move, user, ai, battle|
    next battle.field.effects[PBEffects::FairyLock] > 0
  }
)
AIHandlers::MoveEffectScore.add("152",
  proc { |score, move, user, ai, battle|
    # Trapping for just one turn isn't so significant, so generally don't prefer
    next score - 10
  }
)

#===============================================================================
#
#===============================================================================
# PursueSwitchingFoe

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("171",
  proc { |move, user, ai, battle|
    found_physical_move = false
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| m.physicalMove?(m.type) }
      found_physical_move = true
      break
    end
    next !found_physical_move
  }
)
AIHandlers::MoveEffectScore.add("171",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if user.effects[PBEffects::Substitute] > 0
    # Prefer if foes don't know any special moves
    found_special_move = false
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| m.specialMove?(m.type) }
      found_special_move = true
      break
    end
    score += 10 if !found_special_move
    # Generally not worth using
    next score - 10
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("083",
  proc { |score, move, user, ai, battle|
    # No score change if no allies know this move
    ally_has_move = false
    ai.each_same_side_battler(user.side) do |b, i|
      next if !b.has_move_with_function?(move.function)
      ally_has_move = true
      break
    end
    next score if !ally_has_move
    # Prefer for the sake of doubling in power
    score += 10
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("11D",
  proc { |score, move, user, target, ai, battle|
    # Useless if the target is a foe
    next NewAI::MOVE_USELESS_SCORE if target.opposes?(user)
    # Compare the speeds of all battlers
    speeds = []
    ai.each_battler { |b, i| speeds.push([i, b.rough_stat(:SPEED)]) }
    if battle.field.effects[PBEffects::TrickRoom] > 0
      speeds.sort! { |a, b| a[1] <=> b[1] }
    else
      speeds.sort! { |a, b| b[1] <=> a[1] }
    end
    idx_user = speeds.index { |ele| ele[0] == user.index }
    idx_target = speeds.index { |ele| ele[0] == target.index }
    # Useless if the target is faster than the user
    next NewAI::MOVE_USELESS_SCORE if idx_target < idx_user
    # Useless if the target will move next anyway
    next NewAI::MOVE_USELESS_SCORE if idx_target - idx_user <= 1
    # Generally not worth using
    # NOTE: Because this move can be used against a foe but is being used on an
    #       ally (since we're here in this code), this move's score will be
    #       inverted later. A higher score here means this move will be less
    #       preferred, which is the result we want.
    next score + 10
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("11E",
  proc { |score, move, user, target, ai, battle|
    # Useless if the target is an ally
    next NewAI::MOVE_USELESS_SCORE if !target.opposes?(user)
    # Useless if the user has no ally (the point of this move is to let the ally
    # get in a hit before the foe)
    has_ally = false
    ai.each_ally(user.index) { |b, i| has_ally = true if b.can_attack? }
    next NewAI::MOVE_USELESS_SCORE if !has_ally
    # Compare the speeds of all battlers
    speeds = []
    ai.each_battler { |b, i| speeds.push([i, b.rough_stat(:SPEED)]) }
    if battle.field.effects[PBEffects::TrickRoom] > 0
      speeds.sort! { |a, b| a[1] <=> b[1] }
    else
      speeds.sort! { |a, b| b[1] <=> a[1] }
    end
    idx_user = speeds.index { |ele| ele[0] == user.index }
    idx_target = speeds.index { |ele| ele[0] == target.index }
    idx_slowest_ally = -1
    speeds.each_with_index { |ele, i| idx_slowest_ally = i if user.index.even? == ele[0].even? }
    # Useless if the target is faster than the user
    next NewAI::MOVE_USELESS_SCORE if idx_target < idx_user
    # Useless if the target will move last anyway
    next NewAI::MOVE_USELESS_SCORE if idx_target == speeds.length - 1
    # Useless if the slowest ally is faster than the target
    next NewAI::MOVE_USELESS_SCORE if idx_slowest_ally < idx_target
    # Generally not worth using
    next score - 10
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("16B",
  proc { |move, user, target, ai, battle|
    next target.battler.usingMultiTurnAttack?
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("16B",
  proc { |score, move, user, target, ai, battle|
    # We don't ever want to make a foe act again
    next NewAI::MOVE_USELESS_SCORE if target.opposes?(user)
    # Useless if target will act before the user, as we don't know what move
    # will be instructed
    next NewAI::MOVE_USELESS_SCORE if target.faster_than?(user)
    next NewAI::MOVE_USELESS_SCORE if !target.battler.lastRegularMoveUsed
    mov = nil
    target.battler.eachMove do |m|
      mov = m if m.id == target.battler.lastRegularMoveUsed
      break if mov
    end
    next NewAI::MOVE_USELESS_SCORE if mov.nil? || (mov.pp == 0 && mov.total_pp > 0)
    next NewAI::MOVE_USELESS_SCORE if move.move.moveBlacklist.include?(mov.function)
    # Without lots of code here to determine good/bad moves, using this move is
    # likely to just be a waste of a turn
    # NOTE: Because this move can be used against a foe but is being used on an
    #       ally (since we're here in this code), this move's score will be
    #       inverted later. A higher score here means this move will be less
    #       preferred, which is the result we want.
    score += 10
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("11F",
  proc { |score, move, user, ai, battle|
    # Get the speeds of all battlers
    ally_speeds = []
    foe_speeds = []
    ai.each_battler do |b, i|
      if b.opposes?(user)
        foe_speeds.push(b.rough_stat(:SPEED))
        foe_speeds.last *= 2 if user.pbOpposingSide.effects[PBEffects::Tailwind] > 1
        foe_speeds.last /= 2 if user.pbOpposingSide.effects[PBEffects::Swamp] > 1
      else
        ally_speeds.push(b.rough_stat(:SPEED))
        ally_speeds.last *= 2 if user.pbOwnSide.effects[PBEffects::Tailwind] > 1
        ally_speeds.last /= 2 if user.pbOwnSide.effects[PBEffects::Swamp] > 1
      end
    end
    # Just in case a side has no battlers
    next NewAI::MOVE_USELESS_SCORE if ally_speeds.length == 0 || foe_speeds.length == 0
    # Invert the speeds if Trick Room applies (and will last longer than this round)
    if battle.field.effects[PBEffects::TrickRoom] > 1
      foe_speeds.map! { |val| 100_000 - val }    # 100_000 is higher than speed can
      ally_speeds.map! { |val| 100_000 - val }   # possibly be; only order matters
    end
    # Score based on the relative speeds
    next NewAI::MOVE_USELESS_SCORE if ally_speeds.min > foe_speeds.max
    if foe_speeds.min > ally_speeds.max
      score += 20
    elsif ally_speeds.sum / ally_speeds.length < foe_speeds.sum / foe_speeds.length
      score += 10
    else
      score -= 10
    end
    score += 20 if user.has_role?(:TRICKROOMSETTER)
    next score
  }
)

#===============================================================================
#
#===============================================================================
# HigherPriorityInGrassyTerrain

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("210",
  proc { |score, move, user, target, ai, battle|
    add_effect = move.get_score_change_for_additional_effect(user, target)
    next score if add_effect == -999   # Additional effect will be negated
    if user.faster_than?(target)
      last_move = target.battler.pbGetMoveWithID(target.battler.lastRegularMoveUsed)
      if last_move && last_move.total_pp > 0
        score += add_effect
        next score + 20 if last_move.pp <= 3   # Will fully deplete the move's PP
        next score + 10 if last_move.pp <= 5
        next score - 10 if last_move.pp > 9   # Too much PP left to make a difference
      end
    end
    next score   # Don't know which move it will affect; treat as just a damaging move
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("10E",
  proc { |move, user, target, ai, battle|
    next !target.check_for_move { |m| m.id == target.battler.lastRegularMoveUsed }
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("10E",
  proc { |score, move, user, target, ai, battle|
    if user.faster_than?(target)
      last_move = target.battler.pbGetMoveWithID(target.battler.lastRegularMoveUsed)
      next score + 20 if last_move.pp <= 4   # Will fully deplete the move's PP
      next score + 10 if last_move.pp <= 6
      next score - 10 if last_move.pp > 10   # Too much PP left to make a difference
    end
    next score - 10   # Don't know which move it will affect; don't prefer
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0B9",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Disable] > 0 || !target.battler.lastRegularMoveUsed
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
    next !target.check_for_move { |m| m.id == target.battler.lastRegularMoveUsed }
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0B9",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if target.has_active_item?(:MENTALHERB)
    # Inherent preference
    score += 5
    # Prefer if the target is locked into using a single move, or will be
    if target.effects[PBEffects::ChoiceBand] ||
       target.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
       target.has_active_ability?(:GORILLATACTICS)
      score += 10
    end
    # Prefer disabling a damaging move
    score += 8 if GameData::Move.try_get(target.battler.lastRegularMoveUsed)&.damaging?
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0B7",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Torment]
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
    next false
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0B7",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if target.has_active_item?(:MENTALHERB)
    # Inherent preference
    score += 10
    # Prefer if the target is locked into using a single move, or will be
    if target.effects[PBEffects::ChoiceBand] ||
       target.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
       target.has_active_ability?(:GORILLATACTICS)
      score += 10
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0BC",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Encore] > 0
    next true if !target.battler.lastRegularMoveUsed ||
                 !GameData::Move.exists?(target.battler.lastRegularMoveUsed) ||
                 move.move.moveBlacklist.include?(GameData::Move.get(target.battler.lastRegularMoveUsed).function)
    next true if target.effects[PBEffects::ShellTrap]
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
    will_fail = true
    next !target.check_for_move { |m| m.id == target.battler.lastRegularMoveUsed }
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0BC",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if target.has_active_item?(:MENTALHERB)
    if user.faster_than?(target)
      # We know which move is going to be encored (assuming the target doesn't
      # use a high priority move)
      move_data = GameData::Move.get(target.battler.lastRegularMoveUsed)
      if move_data.status?
        # Prefer encoring status moves
        if [:User, :BothSides].include?(move_data.target)
          score += 10
        else
          score += 8
        end
      elsif move_data.damaging? && [:NearOther, :Other].include?(move_data.target)
        # Prefer encoring damaging moves depending on their type effectiveness
        # against the user
        eff = user.effectiveness_of_type_against_battler(move_data.type, target)
        if Effectiveness.ineffective?(eff)
          score += 20
        elsif Effectiveness.not_very_effective?(eff)
          score += 15
        elsif Effectiveness.super_effective?(eff)
          score -= 8
        else
          score += 8
        end
      end
    else
      # We don't know which move is going to be encored; just prefer limiting
      # the target's options
      score += 10
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0BA",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::Taunt] > 0
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
    next true if Settings::MECHANICS_GENERATION >= 6 &&
                 !battle.moldBreaker && target.has_active_ability?(:OBLIVIOUS)
    next false
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0BA",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !target.check_for_move { |m| m.statusMove? }
    # Not worth using on a sleeping target that won't imminently wake up
    if target.status == :SLEEP && target.statusCount > ((target.faster_than?(user)) ? 2 : 1)
      if !target.check_for_move { |m| m.statusMove? && m.usableWhenAsleep? }
        next NewAI::MOVE_USELESS_SCORE
      end
    end
    # Move is likely useless if the target will lock themselves into a move,
    # because they'll likely lock themselves into a damaging move
    if !target.effects[PBEffects::ChoiceBand]
      if target.has_active_item?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
         target.has_active_ability?(:GORILLATACTICS)
        next NewAI::MOVE_USELESS_SCORE
      end
    end
    # Prefer based on how many status moves the target knows
    target.battler.eachMove do |m|
      score += 5 if m.statusMove? && (m.pp > 0 || m.total_pp == 0)
    end
    # Prefer if the target has a protection move
    protection_moves = [
      "0AA",                                       # Detect, Protect
      "0AB",                  # Quick Guard
      "0AC",       # Wide Guard
      "0E8",                       # Endure
      "149",   # Mat Block
      "14A",                    # Crafty Shield
      "14B",           # King's Shield
      "180",              # Obstruct
      "14C",          # Spiky Shield
      "168",                           # Baneful Bunker
      "537"
    ]
    if target.check_for_move { |m| m.statusMove? && protection_moves.include?(m.function) }
      score += 10
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0BB",
  proc { |move, user, target, ai, battle|
    next true if target.effects[PBEffects::HealBlock] > 0
    next true if move.move.pbMoveFailedAromaVeil?(user.battler, target.battler, false)
    next false
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0BB",
  proc { |score, move, user, target, ai, battle|
    # Useless if the foe can't heal themselves with a move or some held items
    if !target.check_for_move { |m| m.healingMove? }
      if !target.has_active_item?(:LEFTOVERS) &&
         !(target.has_active_item?(:BLACKSLUDGE) && target.has_type?(:POISON))
        next NewAI::MOVE_USELESS_SCORE
      end
    end
    # Inherent preference
    score += 10
    next score
  }
)

#===============================================================================
#.
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("16C",
  proc { |score, move, user, target, ai, battle|
    next score if target.effects[PBEffects::ThroatChop] > 1
    next score if !target.check_for_move { |m| m.soundMove? }
    # Check additional effect chance
    add_effect = move.get_score_change_for_additional_effect(user, target)
    next score if add_effect == -999   # Additional effect will be negated
    score += add_effect
    # Inherent preference
    score += 8
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0B8",
  proc { |move, user, ai, battle|
    next user.effects[PBEffects::Imprison]
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0B8",
  proc { |score, move, user, target, ai, battle|
    # Useless if the foes have no moves that the user also knows
    affected_foe_count = 0
    user_moves = user.battler.moves.map { |m| m.id }
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| user_moves.include?(m.id) }
      affected_foe_count += 1
      break
    end
    next NewAI::MOVE_USELESS_SCORE if affected_foe_count == 0
    # Inherent preference
    score += 8 * affected_foe_count
    next score
  }
)
