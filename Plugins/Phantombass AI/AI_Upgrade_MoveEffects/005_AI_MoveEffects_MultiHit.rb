#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("0BD",
  proc { |power, move, user, target, ai, battle|
    next power * move.move.pbNumHits(user.battler, [target.battler])
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0BD",
  proc { |score, move, user, target, ai, battle|
    # Prefer if the target has a Substitute and this move can break it before
    # the last hit
    if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
      dmg = move.rough_damage
      num_hits = move.move.pbNumHits(user.battler, [target.battler])
      score += 10 if target.effects[PBEffects::Substitute] < dmg * (num_hits - 1) / num_hits
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("0BD",
                                         "0BE")
AIHandlers::MoveEffectAgainstTargetScore.add("0BE",
  proc { |score, move, user, target, ai, battle|
    # Score for hitting multiple times
    score = AIHandlers.apply_move_effect_against_target_score("0BD",
       score, move, user, target, ai, battle)
    # Score for poisoning
    poison_score = AIHandlers.apply_move_effect_against_target_score("005",
       0, move, user, target, ai, battle)
    score += poison_score if poison_score != NewAI::MOVE_USELESS_SCORE
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("0BD",
                                         "175")
AIHandlers::MoveEffectAgainstTargetScore.add("175",
  proc { |score, move, user, target, ai, battle|
    # Score for hitting multiple times
    score = AIHandlers.apply_move_effect_against_target_score("0BD",
       score, move, user, target, ai, battle)
    # Score for flinching
    score = AIHandlers.apply_move_effect_against_target_score("00F",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("17C",
  proc { |power, move, user, target, ai, battle|
    next power * 2
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("0BF",
  proc { |power, move, user, target, ai, battle|
    next power * 6   # Hits do x1, x2, x3 ret in turn, for x6 in total
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0BF",
  proc { |score, move, user, target, ai, battle|
    # Prefer if the target has a Substitute and this move can break it before
    # the last hit
    if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
      dmg = move.rough_damage
      score += 10 if target.effects[PBEffects::Substitute] < dmg / 2
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("0BD",
                                         "188")
AIHandlers::MoveEffectAgainstTargetScore.copy("0BD",
                                                        "188")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("0C0",
  proc { |power, move, user, target, ai, battle|
    next power * 5 if user.has_active_ability?(:SKILLLINK)
    next power * 31 / 10   # Average damage dealt
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0C0",
  proc { |score, move, user, target, ai, battle|
    # Prefer if the target has a Substitute and this move can break it before
    # the last/third hit
    if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
      dmg = move.rough_damage
      num_hits = (user.has_active_ability?(:SKILLLINK)) ? 5 : 3   # 3 is about average
      score += 10 if target.effects[PBEffects::Substitute] < dmg * (num_hits - 1) / num_hits
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("0C0",
  proc { |power, move, user, target, ai, battle|
    if user.battler.isSpecies?(:GRENINJA) && user.battler.form == 2
      next move.move.pbBaseDamage(power, user.battler, target.battler) * move.move.pbNumHits(user.battler, [target.battler])
    end
    next power * 5 if user.has_active_ability?(:SKILLLINK)
    next power * 31 / 10   # Average damage dealt
  }
)
AIHandlers::MoveEffectAgainstTargetScore.copy("0C0",
                                                        "0C0")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("0C0",
                                         "193")
AIHandlers::MoveEffectAgainstTargetScore.add("193",
  proc { |score, move, user, target, ai, battle|
    # Score for being a multi-hit attack
    score = AIHandlers.apply_move_effect_against_target_score("0C0",
       score, move, user, target, ai, battle)
    # Score for user's stat changes
    score = ai.get_score_for_target_stat_raise(score, user, [:SPEED, 1], false)
    score = ai.get_score_for_target_stat_drop(score, user, [:DEFENSE, 1], false)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0C1",
  proc { |move, user, ai, battle|
    will_fail = true
    battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, i|
      next if !pkmn.able? || pkmn.status != :NONE
      will_fail = false
      break
    end
    next will_fail
  }
)
AIHandlers::MoveBasePower.add("0C1",
  proc { |power, move, user, target, ai, battle|
    ret = 0
    battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, _i|
      ret += 5 + (pkmn.baseStats[:ATTACK] / 10) if pkmn.able? && pkmn.status == :NONE
    end
    next ret
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0C1",
  proc { |score, move, user, target, ai, battle|
    # Prefer if the target has a Substitute and this move can break it before
    # the last hit
    if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
      dmg = move.rough_damage
      num_hits = 0
      battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, _i|
        num_hits += 1 if pkmn.able? && pkmn.status == :NONE
      end
      score += 10 if target.effects[PBEffects::Substitute] < dmg * (num_hits - 1) / num_hits
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("0C2",
  proc { |score, move, user, ai, battle|
    # Don't prefer if user is at a high HP (treat this move as a last resort)
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp >= user.totalhp / 2
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0C3",
  proc { |score, move, user, target, ai, battle|
    # Power Herb makes this a 1 turn move, the same as a move with no effect
    next score if user.has_active_item?(:POWERHERB)
    # Treat as a failure if user has Truant (the charging turn has no effect)
    next NewAI::MOVE_USELESS_SCORE if user.has_active_ability?(:TRUANT)
    # Useless if user will faint from EoR damage before finishing this attack
    next NewAI::MOVE_USELESS_SCORE if user.rough_end_of_round_damage >= user.hp
    # Don't prefer because it uses up two turns
    score -= 10
    # Don't prefer if user is at a low HP (time is better spent on quicker moves)
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
    end
    # Don't prefer if target has a protecting move
    if ai.trainer.high_skill? && !(user.has_active_ability?(:UNSEENFIST) && move.contactMove?)
      has_protect_move = false
      if move.pbTarget(user).num_targets > 1 &&
         (Settings::MECHANICS_GENERATION >= 7 || move.damagingMove?)
        if target.has_move_with_function?("0AC")
          has_protect_move = true
        end
      end
      if move.move.canProtectAgainst?
        if target.has_move_with_function?("0AA",
                                          "14C",
                                          "168")
          has_protect_move = true
        end
        if move.damagingMove?
          # NOTE: Doesn't check for Mat Block because it only works on its
          #       user's first turn in battle, so it can't be used in response
          #       to this move charging up.
          if target.has_move_with_function?("14B",
                                            "180")
            has_protect_move = true
          end
        end
        if move.rough_priority(user) > 0
          if target.has_move_with_function?("0AB")
            has_protect_move = true
          end
        end
      end
      score -= 20 if has_protect_move
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("0C4",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamageMultiplier(power, user.battler, target.battler)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0C4",
  proc { |score, move, user, target, ai, battle|
    # In sunny weather this a 1 turn move, the same as a move with no effect
    next score if [:Sun, :HarshSun].include?(user.battler.effectiveWeather)
    # Score for being a two turn attack
    next AIHandlers.apply_move_effect_against_target_score("0C3",
       score, move, user, target, ai, battle)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0C5",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = AIHandlers.apply_move_effect_against_target_score("0C3",
       score, move, user, target, ai, battle)
    next score if score == NewAI::MOVE_USELESS_SCORE
    # Score for paralysing
    score = AIHandlers.apply_move_effect_against_target_score("007",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("06C",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = AIHandlers.apply_move_effect_against_target_score("0C3",
       score, move, user, target, ai, battle)
    next score if score == NewAI::MOVE_USELESS_SCORE
    # Score for burning
    score = AIHandlers.apply_move_effect_against_target_score("00A",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0C7",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = AIHandlers.apply_move_effect_against_target_score("0C3",
       score, move, user, target, ai, battle)
    next score if score == NewAI::MOVE_USELESS_SCORE
    # Score for flinching
    score = AIHandlers.apply_move_effect_against_target_score("00F",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("024",
                                            "14E")
AIHandlers::MoveEffectAgainstTargetScore.add("14E",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = AIHandlers.apply_move_effect_against_target_score("0C3",
       score, move, user, target, ai, battle)
    next score if score == NewAI::MOVE_USELESS_SCORE
    # Score for raising user's stats
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0C8",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = AIHandlers.apply_move_effect_against_target_score("0C3",
       score, move, user, target, ai, battle)
    next score if score == NewAI::MOVE_USELESS_SCORE
    # Score for raising the user's stat
    score = AIHandlers.apply_move_effect_score("01D",
       score, move, user, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("191",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = AIHandlers.apply_move_effect_against_target_score("0C3",
       score, move, user, target, ai, battle)
    next score if score == NewAI::MOVE_USELESS_SCORE
    # Score for raising the user's stat
    score = AIHandlers.apply_move_effect_score("020",
       score, move, user, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0CA",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = AIHandlers.apply_move_effect_against_target_score("0C3",
       score, move, user, target, ai, battle)
    next score if score == NewAI::MOVE_USELESS_SCORE
    # Score for being semi-invulnerable underground
    ai.each_foe_battler(user.side) do |b, i|
      if b.check_for_move { |m| m.hitsDiggingTargets? }
        score -= 10
      else
        score += 8
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0CB",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = AIHandlers.apply_move_effect_against_target_score("0C3",
       score, move, user, target, ai, battle)
    next score if score == NewAI::MOVE_USELESS_SCORE
    # Score for being semi-invulnerable underwater
    ai.each_foe_battler(user.side) do |b, i|
      if b.check_for_move { |m| m.hitsDivingTargets? }
        score -= 10
      else
        score += 8
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0C9",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = AIHandlers.apply_move_effect_against_target_score("0C3",
       score, move, user, target, ai, battle)
    next score if score == NewAI::MOVE_USELESS_SCORE
    # Score for being semi-invulnerable in the sky
    ai.each_foe_battler(user.side) do |b, i|
      if b.check_for_move { |m| m.hitsFlyingTargets? }
        score -= 10
      else
        score += 8
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0CC",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack and semi-invulnerable in the sky
    score = AIHandlers.apply_move_effect_against_target_score("0C9",
       score, move, user, target, ai, battle)
    next score if score == NewAI::MOVE_USELESS_SCORE
    # Score for paralyzing the target
    score = AIHandlers.apply_move_effect_against_target_score("007",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0CE",
  proc { |move, user, target, ai, battle|
    next true if !target.opposes?(user)
    next true if target.effects[PBEffects::Substitute] > 0 && !move.move.ignoresSubstitute?(user.battler)
    next true if target.has_type?(:FLYING)
    next true if Settings::MECHANICS_GENERATION >= 6 && target.battler.pbWeight >= 2000   # 200.0kg
    next true if target.battler.semiInvulnerable? || target.effects[PBEffects::SkyDrop] >= 0
    next false
  }
)
AIHandlers::MoveEffectAgainstTargetScore.copy("0C9",
                                                        "0CE")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0CD",
  proc { |score, move, user, target, ai, battle|
    # Score for being a two turn attack
    score = AIHandlers.apply_move_effect_against_target_score("0C3",
       score, move, user, target, ai, battle)
    next score if score == NewAI::MOVE_USELESS_SCORE
    # Score for being invulnerable
    score += 8
    # Score for removing protections
    score = AIHandlers.apply_move_effect_against_target_score("0AD",
       score, move, user, target, ai, battle)
    next score
  }
)

#===============================================================================
#
#===============================================================================
# MultiTurnAttackPreventSleeping

#===============================================================================
#
#===============================================================================
# MultiTurnAttackConfuseUserAtEnd

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("0D3",
  proc { |power, move, user, target, ai, battle|
    # NOTE: The * 2 (roughly) incorporates the higher damage done in subsequent
    #       rounds. It is nearly the average damage this move will do per round,
    #       assuming it hits for 3 rounds (hoping for hits in all 5 rounds is
    #       optimistic).
    next move.move.pbBaseDamage(power, user.battler, target.battler) * 2
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("0D4",
  proc { |power, move, user, target, ai, battle|
    next 40   # Representative value
  }
)
AIHandlers::MoveEffectScore.add("0D4",
  proc { |score, move, user, ai, battle|
    # Useless if no foe has any damaging moves
    has_damaging_move = false
    ai.each_foe_battler(user.side) do |b, i|
      next if b.status == :SLEEP && b.statusCount > 2
      next if b.status == :FROZEN
      has_damaging_move = true if b.check_for_move { |m| m.damagingMove? }
      break if has_damaging_move
    end
    next NewAI::MOVE_USELESS_SCORE if !has_damaging_move
    # Don't prefer if the user isn't at high HP
    if ai.trainer.has_skill_flag?("HPAware")
      next NewAI::MOVE_USELESS_SCORE if user.hp <= user.totalhp / 4
      score -= 15 if user.hp <= user.totalhp / 2
      score -= 8 if user.hp <= user.totalhp * 3 / 4
    end
    next score
  }
)
