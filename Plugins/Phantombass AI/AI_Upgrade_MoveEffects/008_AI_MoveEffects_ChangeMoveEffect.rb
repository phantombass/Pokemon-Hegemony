#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("117",
  proc { |score, move, user, ai, battle|
    # Useless if there is no ally to redirect attacks from
    next NewAI::MOVE_USELESS_SCORE if user.battler.allAllies.length == 0
    # Prefer if ally is at low HP and user is at high HP
    if ai.trainer.has_skill_flag?("HPAware") && user.hp > user.totalhp * 2 / 3
      ai.each_ally(user.index) do |b, i|
        score += 10 if b.hp <= b.totalhp / 3
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("16A",
  proc { |score, move, user, target, ai, battle|
    if target.opposes?(user)
      # Useless if target is a foe but there is only one foe
      next NewAI::MOVE_USELESS_SCORE if target.battler.allAllies.length == 0
      # Useless if there is no ally to attack the spotlighted foe
      next NewAI::MOVE_USELESS_SCORE if user.battler.allAllies.length == 0
    end
    # Generaly don't prefer this move, as it's a waste of the user's turn
    next score - 20
  }
)

#===============================================================================
#
#===============================================================================
# CannotBeRedirected

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("094",
  proc { |power, move, user, target, ai, battle|
    next 50   # Average power, ish
  }
)
AIHandlers::MoveEffectScore.add("094",
  proc { |score, move, user, ai, battle|
    # Generaly don't prefer this move, as it may heal the target instead
    next score - 10
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("16F",
  proc { |move, user, target, ai, battle|
    next !target.opposes?(user) && !target.battler.canHeal?
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("16F",
  proc { |score, move, user, target, ai, battle|
    next score if target.opposes?(user)
    # Consider how much HP will be restored
    if ai.trainer.has_skill_flag?("HPAware")
      if target.hp >= target.totalhp * 0.5
        score -= 10
      else
        score += 20 * (target.totalhp - target.hp) / target.totalhp   # +10 to +20
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("10D",
  proc { |move, user, ai, battle|
    next false if user.has_type?(:GHOST) ||
                  (move.rough_type == :GHOST && user.has_active_ability?([:LIBERO, :PROTEAN]))
    will_fail = true
    (move.move.statUp.length / 2).times do |i|
      next if !user.battler.pbCanRaiseStatStage?(move.move.statUp[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    (move.move.statDown.length / 2).times do |i|
      next if !user.battler.pbCanLowerStatStage?(move.move.statDown[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
AIHandlers::MoveFailureAgainstTargetCheck.add("10D",
  proc { |move, user, target, ai, battle|
    next false if !user.has_type?(:GHOST) &&
                  !(move.rough_type == :GHOST && user.has_active_ability?([:LIBERO, :PROTEAN]))
    next true if target.effects[PBEffects::Curse] || !target.battler.takesIndirectDamage?
    next false
  }
)
AIHandlers::MoveEffectScore.add("10D",
  proc { |score, move, user, ai, battle|
    next score if user.has_type?(:GHOST) ||
                  (move.rough_type == :GHOST && user.has_active_ability?([:LIBERO, :PROTEAN]))
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    next score if score == NewAI::MOVE_USELESS_SCORE
    next ai.get_score_for_target_stat_drop(score, user, move.move.statDown, false)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("10D",
  proc { |score, move, user, target, ai, battle|
    next score if !user.has_type?(:GHOST) &&
                  !(move.rough_type == :GHOST && user.has_active_ability?([:LIBERO, :PROTEAN]))
    # Don't prefer if user will faint because of using this move
    if ai.trainer.has_skill_flag?("HPAware")
      next NewAI::MOVE_USELESS_SCORE if user.hp <= user.totalhp / 2
    end
    # Prefer early on
    score += 10 if user.turnCount < 2
    if ai.trainer.medium_skill?
      # Prefer if the user has no damaging moves
      score += 15 if !user.check_for_move { |m| m.damagingMove? }
      # Prefer if the target can't switch out to remove its curse
      score += 10 if !battle.pbCanChooseNonActive?(target.index)
    end
    if ai.trainer.high_skill?
      # Prefer if user can stall while damage is dealt
      if user.check_for_move { |m| m.is_a?(PokeBattle_ProtectMove) }
        score += 5
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0A4",
  proc { |score, move, user, target, ai, battle|
    # Determine this move's effect
    move.move.pbOnStartUse(user.battler, [target.battler])
    function_code = nil
    case move.move.secretPower
    when 2
      function_code = "003"
    when 10
      function_code = "00A"
    when 0, 1
      function_code = "007"
    when 9
      function_code = "00C"
    when 7, 11, 13
      function_code = "00F"
    else
      stat_lowered = nil
      case move.move.secretPower
      when 5
        stat_lowered = :ATTACK
      when 14
        stat_lowered = :DEFENSE
      when 3
        stat_lowered = :SPECIAL_ATTACK
      when 4, 6, 12
        stat_lowered = :SPEED
      when 8
        stat_lowered = :ACCURACY
      end
      next ai.get_score_for_target_stat_drop(score, target, [stat_lowered, 1]) if stat_lowered
    end
    if function_code
      next AIHandlers.apply_move_effect_against_target_score(function_code,
         score, move, user, target, ai, battle)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("190",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("148",
  proc { |move, user, target, ai, battle|
    next target.effects[PBEffects::Powder]
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("148",
  proc { |score, move, user, target, ai, battle|
    # Prefer if target knows any Fire moves (moreso if that's the only type they know)
    next NewAI::MOVE_USELESS_SCORE if !target.check_for_move { |m| m.pbCalcType(target.battler) == :FIRE }
    score += 10
    score += 10 if !target.check_for_move { |m| m.pbCalcType(target.battler) != :FIRE }
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("079",
  proc { |score, move, user, ai, battle|
    # Prefer if an ally knows Fusion Flare
    ai.each_ally(user.index) do |b, i|
      score += 10 if b.has_move_with_function?("07A")
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("07A",
  proc { |score, move, user, ai, battle|
    # Prefer if an ally knows Fusion Bolt
    ai.each_ally(user.index) do |b, i|
      score += 10 if b.has_move_with_function?("079")
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("09C",
  proc { |move, user, target, ai, battle|
    next target.effects[PBEffects::HelpingHand]
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("09C",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !target.check_for_move { |m| m.damagingMove? }
    next score + 5
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("071",
  proc { |power, move, user, target, ai, battle|
    next 60   # Representative value
  }
)
AIHandlers::MoveEffectScore.add("071",
  proc { |score, move, user, ai, battle|
    has_physical_move = false
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack?
      next if !b.check_for_move { |m| m.physicalMove?(m.type) &&
                                      (user.effects[PBEffects::Substitute] == 0 ||
                                       m.ignoresSubstitute?(b.battler)) }
      has_physical_move = true
      # Prefer if foe has a higher Attack than Special Attack
      score += 5 if b.rough_stat(:ATTACK) > b.rough_stat(:SPECIAL_ATTACK)
      # Prefer if the last move the foe used was physical
      if ai.trainer.medium_skill? && b.battler.lastMoveUsed
        score += 8 if GameData::Move.try_get(b.battler.lastMoveUsed)&.physical?
      end
      # Prefer if the foe is taunted into using a damaging move
      score += 5 if b.effects[PBEffects::Taunt] > 0
    end
    # Useless if no foes have a physical move to counter
    next NewAI::MOVE_USELESS_SCORE if !has_physical_move
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("072",
  proc { |power, move, user, target, ai, battle|
    next 60   # Representative value
  }
)
AIHandlers::MoveEffectScore.add("072",
  proc { |score, move, user, ai, battle|
    has_special_move = false
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack?
      next if !b.check_for_move { |m| m.specialMove?(m.type) &&
                                      (user.effects[PBEffects::Substitute] == 0 ||
                                       m.ignoresSubstitute?(b.battler)) }
      has_special_move = true
      # Prefer if foe has a higher Special Attack than Attack
      score += 5 if b.rough_stat(:SPECIAL_ATTACK) > b.rough_stat(:ATTACK)
      # Prefer if the last move the foe used was special
      if ai.trainer.medium_skill? && b.battler.lastMoveUsed
        score += 8 if GameData::Move.try_get(b.battler.lastMoveUsed)&.special?
      end
      # Prefer if the foe is taunted into using a damaging move
      score += 5 if b.effects[PBEffects::Taunt] > 0
    end
    # Useless if no foes have a special move to counter
    next NewAI::MOVE_USELESS_SCORE if !has_special_move
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("073",
  proc { |power, move, user, target, ai, battle|
    next 60   # Representative value
  }
)
AIHandlers::MoveEffectScore.add("073",
  proc { |score, move, user, ai, battle|
    has_damaging_move = false
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack? || user.faster_than?(b)
      next if !b.check_for_move { |m| m.damagingMove? &&
                                      (user.effects[PBEffects::Substitute] == 0 ||
                                       m.ignoresSubstitute?(b.battler)) }
      has_damaging_move = true
      # Prefer if the last move the foe used was damaging
      if ai.trainer.medium_skill? && b.battler.lastMoveUsed
        score += 8 if GameData::Move.try_get(b.battler.lastMoveUsed)&.damaging?
      end
      # Prefer if the foe is taunted into using a damaging move
      score += 5 if b.effects[PBEffects::Taunt] > 0
    end
    # Useless if no foes have a damaging move to counter
    next NewAI::MOVE_USELESS_SCORE if !has_damaging_move
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("112",
  proc { |move, user, ai, battle|
    next user.effects[PBEffects::Stockpile] >= 3
  }
)
AIHandlers::MoveEffectScore.add("112",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, [:DEFENSE, 1, :SPECIAL_DEFENSE, 1], false)
    # More preferable if user also has Spit Up/Swallow
    if user.battler.pbHasMoveFunction?("113",
                                       "114")
      score += [10, 10, 8, 5][user.effects[PBEffects::Stockpile]]
    end
    next score
  }
)

#===============================================================================
# NOTE: Don't worry about the stat drops caused by losing the stockpile, because
#       if these moves are known, they want to be used.
#===============================================================================
AIHandlers::MoveFailureCheck.add("113",
  proc { |move, user, ai, battle|
    next user.effects[PBEffects::Stockpile] == 0
  }
)
AIHandlers::MoveBasePower.add("113",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)
AIHandlers::MoveEffectScore.add("113",
  proc { |score, move, user, ai, battle|
    # Slightly prefer to hold out for another Stockpile to make this move stronger
    score -= 5 if user.effects[PBEffects::Stockpile] < 2
    next score
  }
)

#===============================================================================
# NOTE: Don't worry about the stat drops caused by losing the stockpile, because
#       if these moves are known, they want to be used.
#===============================================================================
AIHandlers::MoveFailureCheck.add("114",
  proc { |move, user, ai, battle|
    next true if user.effects[PBEffects::Stockpile] == 0
    next true if !user.battler.canHeal? &&
                 user.effects[PBEffects::StockpileDef] == 0 &&
                 user.effects[PBEffects::StockpileSpDef] == 0
    next false
  }
)
AIHandlers::MoveEffectScore.add("114",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !user.battler.canHeal?
    # Consider how much HP will be restored
    if ai.trainer.has_skill_flag?("HPAware")
      next score - 10 if user.hp >= user.totalhp * 0.5
      score += 20 * (user.totalhp - user.hp) / user.totalhp   # +10 to +20
    end
    # Slightly prefer to hold out for another Stockpile to make this move stronger
    score -= 5 if user.effects[PBEffects::Stockpile] < 2
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("106",
  proc { |score, move, user, ai, battle|
    # Prefer if an ally knows a different Pledge move
    ai.each_ally(user.index) do |b, i|
      score += 10 if b.has_move_with_function?("107", "108")
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("107",
  proc { |score, move, user, ai, battle|
    # Prefer if an ally knows a different Pledge move
    ai.each_ally(user.index) do |b, i|
      score += 10 if b.has_move_with_function?("106", "108")
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("108",
  proc { |score, move, user, ai, battle|
    # Prefer if an ally knows a different Pledge move
    ai.each_ally(user.index) do |b, i|
      score += 10 if b.has_move_with_function?("106", "107")
    end
    next score
  }
)

#===============================================================================
# NOTE: The move that this move will become is determined in def
#       set_up_move_check, and the score for that move is calculated instead. If
#       this move cannot become another move and will fail, the score for this
#       move is calculated as normal (and the code below says it fails).
#===============================================================================
AIHandlers::MoveFailureCheck.add("0AF",
  proc { |move, user, ai, battle|
    next true if !battle.lastMoveUsed || !GameData::Move.exists?(battle.lastMoveUsed)
    next move.move.moveBlacklist.include?(GameData::Move.get(battle.lastMoveUsed).function)
  }
)

#===============================================================================
# NOTE: The move that this move will become is determined in def
#       set_up_move_check, and the score for that move is calculated instead. If
#       this move cannot become another move and will fail, the score for this
#       move is calculated as normal (and the code below says it fails).
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0AE",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.lastRegularMoveUsed
    next true if !GameData::Move.exists?(target.battler.lastRegularMoveUsed)
    next !GameData::Move.get(target.battler.lastRegularMoveUsed).flags[/e/]
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0B0",
  proc { |move, user, target, ai, battle|
    next !target.check_for_move { |m| m.damagingMove? && !move.move.moveBlacklist.include?(m.function) }
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0B0",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if target.faster_than?(user)
    # Don't prefer if target knows any moves that can't be copied
    if target.check_for_move { |m| m.statusMove? || move.move.moveBlacklist.include?(m.function) }
      score -= 8
    end
    next score
  }
)

#===============================================================================
# NOTE: The move that this move will become is determined in def
#       set_up_move_check, and the score for that move is calculated instead.
#===============================================================================
# UseMoveDependingOnEnvironment

#===============================================================================
#
#===============================================================================
# UseRandomMove

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0B5",
  proc { |move, user, ai, battle|
    will_fail = true
    battle.pbParty(user.index).each_with_index do |pkmn, i|
      next if !pkmn || i == user.party_index
      next if Settings::MECHANICS_GENERATION >= 6 && pkmn.egg?
      pkmn.moves.each do |pkmn_move|
        next if move.move.moveBlacklist.include?(pkmn_move.function)
        next if pkmn_move.type == :SHADOW
        will_fail = false
        break
      end
      break if !will_fail
    end
    next will_fail
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0B4",
  proc { |move, user, ai, battle|
    will_fail = true
    user.battler.eachMoveWithIndex do |m, i|
      next if move.move.moveBlacklist.include?(m.function)
      next if !battle.pbCanChooseMove?(user.index, i, false, true)
      will_fail = false
      break
    end
    next will_fail
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("0B1",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if user.has_active_ability?(:MAGICBOUNCE)
    useless = true
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack?
      next if !b.check_for_move { |m| m.statusMove? && m.canMagicCoat? }
      score += 5
      useless = false
    end
    next NewAI::MOVE_USELESS_SCORE if useless
    # Don't prefer the lower the user's HP is (better to try something else)
    if ai.trainer.has_skill_flag?("HPAware") && user.hp < user.totalhp / 2
      score -= (20 * (1.0 - (user.hp.to_f / user.totalhp))).to_i   # -10 to -20
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("0B2",
  proc { |score, move, user, ai, battle|
    useless = true
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack?
      next if !b.check_for_move { |m| m.statusMove? && m.canSnatch? }
      score += 5
      useless = false
    end
    next NewAI::MOVE_USELESS_SCORE if useless
    # Don't prefer the lower the user's HP is (better to try something else)
    if ai.trainer.has_skill_flag?("HPAware") && user.hp < user.totalhp / 2
      score -= (20 * (1.0 - (user.hp.to_f / user.totalhp))).to_i   # -10 to -20
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("05C",
  proc { |move, user, ai, battle|
    next user.effects[PBEffects::Transform] || !user.battler.pbHasMove?(move.id)
  }
)
AIHandlers::MoveFailureAgainstTargetCheck.add("05C",
  proc { |move, user, target, ai, battle|
    next false if !user.faster_than?(target)
    last_move_data = GameData::Move.try_get(target.battler.lastRegularMoveUsed)
    next true if !last_move_data ||
                 user.battler.pbHasMove?(target.battler.lastRegularMoveUsed) ||
                 move.move.moveBlacklist.include?(last_move_data.function) ||
                 last_move_data.type == :SHADOW
    next false
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("05C",
  proc { |score, move, user, target, ai, battle|
    # Generally don't prefer, as this wastes the user's turn just to gain a move
    # of unknown utility
    score -= 10
    # Slightly prefer if this move will definitely succeed, just for the sake of
    # getting rid of this move
    score += 5 if user.faster_than?(target)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("05C",
                                                         "05D")
AIHandlers::MoveEffectScore.copy("05C",
                                           "05D")
