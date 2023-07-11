#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("01C",
  proc { |move, user, ai, battle|
    next move.statusMove? &&
         !user.battler.pbCanRaiseStatStage?(move.move.statUp[0], user.battler, move.move)
  }
)
AIHandlers::MoveEffectScore.add("01C",
  proc { |score, move, user, ai, battle|
    next ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("01C",
                                            "02E")
AIHandlers::MoveEffectScore.copy("01C",
                                           "02E")

#===============================================================================
#
#===============================================================================

AIHandlers::MoveEffectAgainstTargetScore.add("150",
  proc { |score, move, user, target, ai, battle|
    if move.rough_damage >= target.hp * 0.9
      next ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    end
    next score
  }
)
#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("01C",
                                            "511")
AIHandlers::MoveEffectScore.copy("01C",
                                           "511")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("03A",
  proc { |move, user, ai, battle|
    next true if user.hp <= [user.totalhp / 2, 1].max
    next !user.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move)
  }
)
AIHandlers::MoveEffectScore.add("03A",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    # Don't prefer the lower the user's HP is
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 60 * (1 - (user.hp.to_f / user.totalhp))   # -0 to -30
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("01C",
                                            "01D")
AIHandlers::MoveEffectScore.copy("01C",
                                           "01D")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("01D",
                                            "01E")
AIHandlers::MoveEffectScore.add("01E",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    if !user.effects[PBEffects::DefenseCurl] &&
       user.has_move_with_function?("0D3")
      score += 10
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("01D",
                                            "02F")
AIHandlers::MoveEffectScore.copy("01D",
                                           "02F")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("01D",
                                            "038")
AIHandlers::MoveEffectScore.copy("01D",
                                           "038")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("01C",
                                            "020")
AIHandlers::MoveEffectScore.copy("01C",
                                           "020")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("020",
                                            "032")
AIHandlers::MoveEffectScore.copy("020",
                                           "032")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("020",
                                            "039")
AIHandlers::MoveEffectScore.copy("020",
                                           "039")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("01D",
                                            "021")
AIHandlers::MoveEffectScore.add("021",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    if user.has_damaging_move_of_type?(:ELECTRIC)
      score += 10
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("021",
                                            "033")
AIHandlers::MoveEffectScore.copy("01D",
                                           "033")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("021",
                                            "01F")
AIHandlers::MoveEffectScore.copy("021",
                                           "01F")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("01F",
                                            "030")
AIHandlers::MoveEffectScore.copy("01F",
                                           "030")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("030",
                                            "031")
AIHandlers::MoveEffectScore.add("031",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    if ai.trainer.medium_skill?
      current_weight = user.battler.pbWeight
      if current_weight > 1
        score -= 5 if user.has_move_with_function?("09B")
        ai.each_foe_battler(user.side) do |b, i|
          score -= 5 if b.has_move_with_function?("09B")
          score += 5 if b.has_move_with_function?("09A")
          # User will become susceptible to Sky Drop
          if b.has_move_with_function?("0CE") &&
             Settings::MECHANICS_GENERATION >= 6
            score -= 10 if current_weight >= 2000 && current_weight < 3000
          end
        end
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("023",
  proc { |move, user, ai, battle|
    next user.effects[PBEffects::FocusEnergy] >= 2
  }
)
AIHandlers::MoveEffectScore.add("023",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !user.check_for_move { |m| m.damagingMove? }
    score += 15
    if ai.trainer.medium_skill?
      # Other effects that raise the critical hit rate
      if user.item_active?
        if [:RAZORCLAW, :SCOPELENS].include?(user.item_id) ||
           (user.item_id == :LUCKYPUNCH && user.battler.isSpecies?(:CHANSEY)) ||
           ([:LEEK, :STICK].include?(user.item_id) &&
           (user.battler.isSpecies?(:FARFETCHD) || user.battler.isSpecies?(:SIRFETCHD)))
          score += 10
        end
      end
      # Critical hits do more damage
      score += 10 if user.has_active_ability?(:SNIPER)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("024",
  proc { |move, user, ai, battle|
    next false if move.damagingMove?
    will_fail = true
    (move.move.statUp.length / 2).times do |i|
      next if !user.battler.pbCanRaiseStatStage?(move.move.statUp[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
AIHandlers::MoveEffectScore.copy("01C",
                                           "024")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("024",
                                            "025")
AIHandlers::MoveEffectScore.copy("024",
                                           "025")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("024",
                                            "027")
AIHandlers::MoveEffectScore.copy("024",
                                           "027")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("027",
                                            "028")
AIHandlers::MoveEffectScore.add("028",
  proc { |score, move, user, ai, battle|
    raises = move.move.statUp.clone
    if [:Sun, :HarshSun].include?(user.battler.effectiveWeather)
      raises[1] = 2
      raises[3] = 2
    end
    next ai.get_score_for_target_stat_raise(score, user, raises)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("035",
  proc { |move, user, ai, battle|
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
AIHandlers::MoveEffectScore.add("035",
  proc { |score, move, user, ai, battle|
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    next score if score == NewAI::MOVE_USELESS_SCORE
    next ai.get_score_for_target_stat_drop(score, user, move.move.statDown, false)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("027",
                                            "026")
AIHandlers::MoveEffectScore.copy("027",
                                           "026")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("027",
                                            "036")
AIHandlers::MoveEffectScore.copy("027",
                                           "036")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("027",
                                            "029")
AIHandlers::MoveEffectScore.copy("027",
                                           "029")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("027",
                                            "02A")
AIHandlers::MoveEffectScore.copy("027",
                                           "02A")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("027",
                                            "02C")
AIHandlers::MoveEffectScore.copy("027",
                                           "02C")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("027",
                                            "02B")
AIHandlers::MoveEffectScore.copy("027",
                                           "02B")
#===============================================================================
#
#===============================================================================

AIHandlers::MoveFailureCheck.copy("027",
                                            "518")
AIHandlers::MoveEffectScore.copy("027",
                                           "518")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.copy("027",
                                            "02D")
AIHandlers::MoveEffectScore.copy("027",
                                           "02D")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("179",
  proc { |move, user, ai, battle|
    next true if user.hp <= [user.totalhp / 3, 1].max
    next AIHandlers.move_will_fail?("024", move, user, ai, battle)
  }
)
AIHandlers::MoveEffectScore.add("179",
  proc { |score, move, user, ai, battle|
    # Score for stat increase
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    next score if score == NewAI::MOVE_USELESS_SCORE
    # Score for losing HP
    if ai.trainer.has_skill_flag?("HPAware") && user.hp <= user.totalhp * 0.75
      score -= 45 * (user.totalhp - user.hp) / user.totalhp   # -0 to -30
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("17F",
  proc { |move, user, ai, battle|
    next true if user.effects[PBEffects::NoRetreat]
    next AIHandlers.move_will_fail?("024", move, user, ai, battle)
  }
)
AIHandlers::MoveEffectScore.add("17F",
  proc { |score, move, user, ai, battle|
    # Score for stat increase
    score = ai.get_score_for_target_stat_raise(score, user, move.move.statUp)
    # Score for user becoming trapped in battle
    if user.can_become_trapped? && battle.pbCanChooseNonActive?(user.index)
      # Not worth trapping if user will faint this round anyway
      eor_damage = user.rough_end_of_round_damage
      if eor_damage >= user.hp
        next (move.damagingMove?) ? score : NewAI::MOVE_USELESS_SCORE
      end
      # Score for user becoming trapped in battle
      if user.effects[PBEffects::PerishSong] > 0 ||
         user.effects[PBEffects::Attract] >= 0 ||
         eor_damage > 0
        score -= 15
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("093",
  proc { |score, move, user, ai, battle|
    # Ignore the stat-raising effect if user is at a low HP and likely won't
    # benefit from it
    if ai.trainer.has_skill_flag?("HPAware")
      next score if user.hp <= user.totalhp / 3
    end
    # Prefer if user benefits from a raised Attack stat
    score += 10 if ai.stat_raise_worthwhile?(user, :ATTACK)
    score += 7 if user.has_move_with_function?("08E")
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("15F",
  proc { |score, move, user, ai, battle|
    next ai.get_score_for_target_stat_drop(score, user, move.move.statDown)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.copy("15F",
                                           "528")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.copy("15F",
                                           "03F")
#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.copy("15F",
                                           "03E")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.copy("03E",
                                           "535")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.copy("15F",
                                           "03B")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.copy("15F",
                                           "03C")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.copy("15F",
                                           "03D")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("01C",
  proc { |move, user, target, ai, battle|
    next move.statusMove? &&
         !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("01C",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:ATTACK, 1])
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("041",
  proc { |move, user, target, ai, battle|
    next !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
         !target.battler.pbCanConfuse?(user.battler, false, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("041",
  proc { |score, move, user, target, ai, battle|
    if !target.has_active_ability?(:CONTRARY) || battle.moldBreaker
      next NewAI::MOVE_USELESS_SCORE if !target.battler.pbCanConfuse?(user.battler, false, move.move)
    end
    # Score for stat raise
    score = ai.get_score_for_target_stat_raise(score, target, [:ATTACK, 2], false)
    # Score for confusing the target
    next AIHandlers.apply_move_effect_against_target_score(
       "013", score, move, user, target, ai, battle)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("040",
  proc { |move, user, target, ai, battle|
    next !target.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move) &&
         !target.battler.pbCanConfuse?(user.battler, false, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("040",
  proc { |score, move, user, target, ai, battle|
    if !target.has_active_ability?(:CONTRARY) || battle.moldBreaker
      next NewAI::MOVE_USELESS_SCORE if !target.battler.pbCanConfuse?(user.battler, false, move.move)
    end
    # Score for stat raise
    score = ai.get_score_for_target_stat_raise(score, target, [:SPECIAL_ATTACK, 1], false)
    # Score for confusing the target
    next AIHandlers.apply_move_effect_against_target_score(
       "013", score, move, user, target, ai, battle)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("138",
  proc { |move, user, target, ai, battle|
    next !target.battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user.battler, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("138",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:SPECIAL_DEFENSE, 1])
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("037",
  proc { |move, user, target, ai, battle|
    will_fail = true
    GameData::Stat.each_battle do |s|
      next if !target.battler.pbCanRaiseStatStage?(s.id, user.battler, move.move)
      will_fail = false
    end
    next will_fail
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("037",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !battle.moldBreaker && target.has_active_ability?(:CONTRARY)
    next NewAI::MOVE_USELESS_SCORE if target.rough_end_of_round_damage >= target.hp
    score -= 7 if target.index != user.index   # Less likely to use on ally
    score += 10 if target.has_active_ability?(:SIMPLE)
    # Prefer if target is at high HP, don't prefer if target is at low HP
    if ai.trainer.has_skill_flag?("HPAware")
      if target.hp >= target.totalhp * 0.7
        score += 10
      else
        score += (50 * ((target.hp.to_f / target.totalhp) - 0.6)).to_i   # +5 to -30
      end
    end
    # Prefer if target has Stored Power
    if target.has_move_with_function?("08E")
      score += 10
    end
    # Don't prefer if any foe has Punishment
    ai.each_foe_battler(target.side) do |b, i|
      next if !b.has_move_with_function?("08F")
      score -= 8
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("17B",
  proc { |move, user, target, ai, battle|
    next !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
         !target.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("17B",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if target.opposes?(user)
    next ai.get_score_for_target_stat_raise(score, target, [:ATTACK, 2, :SPECIAL_ATTACK, 2])
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("042",
  proc { |move, user, target, ai, battle|
    next move.statusMove? &&
         !target.battler.pbCanLowerStatStage?(move.move.statDown[0], user.battler, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("042",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_drop(score, target, move.move.statDown)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("042",
                                                         "139")
AIHandlers::MoveEffectAgainstTargetScore.copy("042",
                                                        "139")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("042",
                                                         "04B")
AIHandlers::MoveEffectAgainstTargetScore.copy("042",
                                                        "04B")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("042",
                                                         "043")
AIHandlers::MoveEffectAgainstTargetScore.copy("042",
                                                        "043")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("043",
                                                         "185")
AIHandlers::MoveEffectAgainstTargetScore.copy("043",
                                                        "185")
AIHandlers::MoveBasePower.add("185",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("043",
                                                         "04C")
AIHandlers::MoveEffectAgainstTargetScore.copy("043",
                                                        "04C")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("042",
                                                         "045")
AIHandlers::MoveEffectAgainstTargetScore.copy("042",
                                                        "045")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("045",
                                                         "13D")
AIHandlers::MoveEffectAgainstTargetScore.copy("045",
                                                        "13D")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("04E",
  proc { |move, user, target, ai, battle|
    next true if move.statusMove? &&
                 !target.battler.pbCanLowerStatStage?(move.move.statDown[0], user.battler, move.move)
    next true if user.gender == 2 || target.gender == 2 || user.gender == target.gender
    next true if !battle.moldBreaker && target.has_active_ability?(:OBLIVIOUS)
    next false
  }
)
AIHandlers::MoveEffectAgainstTargetScore.copy("13D",
                                                        "04E")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("043",
                                                         "046")
AIHandlers::MoveEffectAgainstTargetScore.copy("043",
                                                        "046")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("046",
                                                         "04F")
AIHandlers::MoveEffectAgainstTargetScore.copy("046",
                                                        "04F")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("046",
                                                         "044")
AIHandlers::MoveEffectAgainstTargetScore.copy("046",
                                                        "044")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("044",
                                                         "570")
AIHandlers::MoveEffectAgainstTargetScore.copy("044",
                                                        "570")
AIHandlers::MoveBasePower.add("570",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("186",
  proc { |move, user, target, ai, battle|
    next false if !target.effects[PBEffects::TarShot]
    next move.statusMove? &&
         !target.battler.pbCanLowerStatStage?(move.move.statDown[0], user.battler, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("186",
  proc { |score, move, user, target, ai, battle|
    # Score for stat drop
    score = ai.get_score_for_target_stat_drop(score, target, move.move.statDown)
    # Score for adding weakness to Fire
    if !target.effects[PBEffects::TarShot]
      eff = target.effectiveness_of_type_against_battler(:FIRE)
      if !Effectiveness.ineffective?(eff)
        score += 10 * eff if user.has_damaging_move_of_type?(:FIRE)
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("044",
                                                         "04D")
AIHandlers::MoveEffectAgainstTargetScore.copy("044",
                                                        "04D")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("049",
  proc { |move, user, target, ai, battle|
    target_side = target.pbOwnSide
    target_opposing_side = target.pbOpposingSide
    next false if target_side.effects[PBEffects::AuroraVeil] > 0 ||
                  target_side.effects[PBEffects::LightScreen] > 0 ||
                  target_side.effects[PBEffects::Reflect] > 0 ||
                  target_side.effects[PBEffects::Mist] > 0 ||
                  target_side.effects[PBEffects::Safeguard] > 0
    next false if target_side.effects[PBEffects::StealthRock] ||
                  target_side.effects[PBEffects::Spikes] > 0 ||
                  target_side.effects[PBEffects::ToxicSpikes] > 0 ||
                  target_side.effects[PBEffects::StickyWeb]
    next false if Settings::MECHANICS_GENERATION >= 6 &&
                  (target_opposing_side.effects[PBEffects::StealthRock] ||
                  target_opposing_side.effects[PBEffects::Spikes] > 0 ||
                  target_opposing_side.effects[PBEffects::ToxicSpikes] > 0 ||
                  target_opposing_side.effects[PBEffects::StickyWeb])
    next false if Settings::MECHANICS_GENERATION >= 8 && battle.field.terrain != :None
    next move.statusMove? &&
         !target.battler.pbCanLowerStatStage?(move.move.statDown[0], user.battler, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("049",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !target.opposes?(user)
    # Score for stat drop
    score = ai.get_score_for_target_stat_drop(score, target, move.move.statDown)
    # Score for removing side effects/terrain
    score += 10 if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 1 ||
                   target.pbOwnSide.effects[PBEffects::Reflect] > 1 ||
                   target.pbOwnSide.effects[PBEffects::LightScreen] > 1 ||
                   target.pbOwnSide.effects[PBEffects::Mist] > 1 ||
                   target.pbOwnSide.effects[PBEffects::Safeguard] > 1
    if target.can_switch_lax?
      score -= 15 if target.pbOwnSide.effects[PBEffects::Spikes] > 0 ||
                     target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0 ||
                     target.pbOwnSide.effects[PBEffects::StealthRock] ||
                     target.pbOwnSide.effects[PBEffects::StickyWeb]
    end
    if user.can_switch_lax? && Settings::MECHANICS_GENERATION >= 6
      score += 15 if target.pbOpposingSide.effects[PBEffects::Spikes] > 0 ||
                     target.pbOpposingSide.effects[PBEffects::ToxicSpikes] > 0 ||
                     target.pbOpposingSide.effects[PBEffects::StealthRock] ||
                     target.pbOpposingSide.effects[PBEffects::StickyWeb]
    end
    if Settings::MECHANICS_GENERATION >= 8 && battle.field.terrain != :None
      score -= ai.get_score_for_terrain(battle.field.terrain, user)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("04A",
  proc { |move, user, target, ai, battle|
    next false if !move.statusMove?
    will_fail = true
    (move.move.statDown.length / 2).times do |i|
      next if !target.battler.pbCanLowerStatStage?(move.move.statDown[i * 2], user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
AIHandlers::MoveEffectAgainstTargetScore.copy("042",
                                                        "04A")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.copy("04A",
                                                         "13A")
AIHandlers::MoveEffectAgainstTargetScore.copy("04A",
                                                        "13A")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("140",
  proc { |move, user, target, ai, battle|
    next true if !target.battler.poisoned?
    next AIHandlers.move_will_fail_against_target?("13A",
                                                             move, user, target, ai, battle)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.copy("13A",
                                                        "140")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("18E",
  proc { |move, user, target, ai, battle|
    next !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
         !target.battler.pbCanRaiseStatStage?(:DEFENSE, user.battler, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("18E",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:ATTACK, 1, :DEFENSE, 1])
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("15C",
  proc { |move, user, ai, battle|
    will_fail = true
    ai.each_same_side_battler(user.side) do |b, i|
      next if !b.has_active_ability?([:MINUS, :PLUS])
      next if !b.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
              !b.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
AIHandlers::MoveFailureAgainstTargetCheck.add("15C",
  proc { |move, user, target, ai, battle|
    next true if !target.has_active_ability?([:MINUS, :PLUS])
    next !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
         !target.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move)
  }
)
AIHandlers::MoveEffectScore.add("15C",
  proc { |score, move, user, ai, battle|
    next score if move.pbTarget(user.battler) != :UserSide
    ai.each_same_side_battler(user.side) do |b, i|
      score = ai.get_score_for_target_stat_raise(score, b, [:ATTACK, 1, :SPECIAL_ATTACK, 1], false)
    end
    next score
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("15C",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:ATTACK, 1, :SPECIAL_ATTACK, 1])
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("137",
  proc { |move, user, ai, battle|
    will_fail = true
    ai.each_same_side_battler(user.side) do |b, i|
      next if !b.has_active_ability?([:MINUS, :PLUS])
      next if !b.battler.pbCanRaiseStatStage?(:DEFENSE, user.battler, move.move) &&
              !b.battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user.battler, move.move)
      will_fail = false
      break
    end
    next will_fail
  }
)
AIHandlers::MoveFailureAgainstTargetCheck.add("137",
  proc { |move, user, target, ai, battle|
    next true if !target.has_active_ability?([:MINUS, :PLUS])
    next !target.battler.pbCanRaiseStatStage?(:DEFENSE, user.battler, move.move) &&
         !target.battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user.battler, move.move)
  }
)
AIHandlers::MoveEffectScore.add("137",
  proc { |score, move, user, ai, battle|
    next score if move.pbTarget(user.battler) != :UserSide
    ai.each_same_side_battler(user.side) do |b, i|
      score = ai.get_score_for_target_stat_raise(score, b, [:DEFENSE, 1, :SPECIAL_DEFENSE, 1], false)
    end
    next score
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("137",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:DEFENSE, 1, :SPECIAL_DEFENSE, 1])
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("13E",
  proc { |move, user, target, ai, battle|
    next true if !target.has_type?(:GRASS) || target.battler.airborne? || target.battler.semiInvulnerable?
    next !target.battler.pbCanRaiseStatStage?(:ATTACK, user.battler, move.move) &&
         !target.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user.battler, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("13E",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:ATTACK, 1, :SPECIAL_ATTACK, 1])
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("13F",
  proc { |move, user, target, ai, battle|
    next true if !target.has_type?(:GRASS) || target.battler.semiInvulnerable?
    next !target.battler.pbCanRaiseStatStage?(:DEFENSE, user.battler, move.move)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("13F",
  proc { |score, move, user, target, ai, battle|
    next ai.get_score_for_target_stat_raise(score, target, [:DEFENSE, 1])
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("052",
  proc { |score, move, user, target, ai, battle|
    raises = []
    drops = []
    [:ATTACK, :SPECIAL_ATTACK].each do |stat|
      stage_diff = target.stages[stat] - user.stages[stat]
      if stage_diff > 0
        raises.push(stat)
        raises.push(stage_diff)
      elsif stage_diff < 0
        drops.push(stat)
        drops.push(stage_diff)
      end
    end
    next NewAI::MOVE_USELESS_SCORE if raises.length == 0   # No stat raises
    score = ai.get_score_for_target_stat_raise(score, user, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, target, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, user, drops, false, true) if drops.length > 0
    score = ai.get_score_for_target_stat_raise(score, target, drops, false, true) if drops.length > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("053",
  proc { |score, move, user, target, ai, battle|
    raises = []
    drops = []
    [:DEFENSE, :SPECIAL_DEFENSE].each do |stat|
      stage_diff = target.stages[stat] - user.stages[stat]
      if stage_diff > 0
        raises.push(stat)
        raises.push(stage_diff)
      elsif stage_diff < 0
        drops.push(stat)
        drops.push(stage_diff)
      end
    end
    next NewAI::MOVE_USELESS_SCORE if raises.length == 0   # No stat raises
    score = ai.get_score_for_target_stat_raise(score, user, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, target, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, user, drops, false, true) if drops.length > 0
    score = ai.get_score_for_target_stat_raise(score, target, drops, false, true) if drops.length > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("054",
  proc { |score, move, user, target, ai, battle|
    raises = []
    drops = []
    GameData::Stat.each_battle do |s|
      stage_diff = target.stages[s.id] - user.stages[s.id]
      if stage_diff > 0
        raises.push(s.id)
        raises.push(stage_diff)
      elsif stage_diff < 0
        drops.push(s.id)
        drops.push(stage_diff)
      end
    end
    next NewAI::MOVE_USELESS_SCORE if raises.length == 0   # No stat raises
    score = ai.get_score_for_target_stat_raise(score, user, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, target, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, user, drops, false, true) if drops.length > 0
    score = ai.get_score_for_target_stat_raise(score, target, drops, false, true) if drops.length > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("055",
  proc { |score, move, user, target, ai, battle|
    raises = []
    drops = []
    GameData::Stat.each_battle do |s|
      stage_diff = target.stages[s.id] - user.stages[s.id]
      if stage_diff > 0
        raises.push(s.id)
        raises.push(stage_diff)
      elsif stage_diff < 0
        drops.push(s.id)
        drops.push(stage_diff)
      end
    end
    next NewAI::MOVE_USELESS_SCORE if raises.length == 0   # No stat raises
    score = ai.get_score_for_target_stat_raise(score, user, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, user, drops, false, true) if drops.length > 0
    if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
      if user.effects[PBEffects::FocusEnergy] > 0 && target.effects[PBEffects::FocusEnergy] == 0
        score -= 5
      elsif user.effects[PBEffects::FocusEnergy] == 0 && target.effects[PBEffects::FocusEnergy] > 0
        score += 5
      end
      if user.effects[PBEffects::LaserFocus] > 0 && target.effects[PBEffects::LaserFocus] == 0
        score -= 5
      elsif user.effects[PBEffects::LaserFocus] == 0 && target.effects[PBEffects::LaserFocus] > 0
        score += 5
      end
    end
    next score
  }
)

#===============================================================================
# NOTE: Accounting for the stat theft before damage calculation, to calculate a
#       more accurate predicted damage, would be complex, involving
#       pbCanRaiseStatStage? and Contrary and Simple; I'm not bothering with
#       that.
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("15D",
  proc { |score, move, user, target, ai, battle|
    raises = []
    GameData::Stat.each_battle do |s|
      next if target.stages[s.id] <= 0
      raises.push(s.id)
      raises.push(target.stages[s.id])
    end
    if raises.length > 0
      score = ai.get_score_for_target_stat_raise(score, user, raises, false)
      score = ai.get_score_for_target_stat_drop(score, target, raises, false, true)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("141",
  proc { |move, user, target, ai, battle|
    next !target.battler.hasAlteredStatStages?
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("141",
  proc { |score, move, user, target, ai, battle|
    raises = []
    drops = []
    GameData::Stat.each_battle do |s|
      if target.stages[s.id] > 0
        drops.push(s.id)
        drops.push(target.stages[s.id] * 2)
      elsif target.stages[s.id] < 0
        raises.push(s.id)
        raises.push(target.stages[s.id] * 2)
      end
    end
    next NewAI::MOVE_USELESS_SCORE if drops.length == 0   # No stats will drop
    score = ai.get_score_for_target_stat_raise(score, target, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, target, drops, false, true) if drops.length > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("050",
  proc { |score, move, user, target, ai, battle|
    raises = []
    drops = []
    GameData::Stat.each_battle do |s|
      if target.stages[s.id] > 0
        drops.push(s.id)
        drops.push(target.stages[s.id])
      elsif target.stages[s.id] < 0
        raises.push(s.id)
        raises.push(target.stages[s.id])
      end
    end
    score = ai.get_score_for_target_stat_raise(score, target, raises, false, true) if raises.length > 0
    score = ai.get_score_for_target_stat_drop(score, target, drops, false, true) if drops.length > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("051",
  proc { |move, user, ai, battle|
    next battle.allBattlers.none? { |b| b.hasAlteredStatStages? }
  }
)
AIHandlers::MoveEffectScore.add("051",
  proc { |score, move, user, ai, battle|
    ai.each_battler do |b|
      raises = []
      drops = []
      GameData::Stat.each_battle do |s|
        if b.stages[s.id] > 0
          drops.push(s.id)
          drops.push(b.stages[s.id])
        elsif b.stages[s.id] < 0
          raises.push(s.id)
          raises.push(b.stages[s.id])
        end
      end
      score = ai.get_score_for_target_stat_raise(score, b, raises, false, true) if raises.length > 0
      score = ai.get_score_for_target_stat_drop(score, b, drops, false, true) if drops.length > 0
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("056",
  proc { |move, user, ai, battle|
    next user.pbOwnSide.effects[PBEffects::Mist] > 0
  }
)
AIHandlers::MoveEffectScore.add("056",
  proc { |score, move, user, ai, battle|
    has_move = false
    ai.each_foe_battler(user.side) do |b, i|
      if b.check_for_move { |m| m.is_a?(Battle::Move::TargetStatDownMove) ||
                                m.is_a?(Battle::Move::TargetMultiStatDownMove) ||
                                ["140",
                                 "159",
                                 "160"].include?(m.function) }
        score += 15
        has_move = true
      end
    end
    next NewAI::MOVE_USELESS_SCORE if !has_move
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("057",
  proc { |score, move, user, ai, battle|
    # No flip-flopping
    next NewAI::MOVE_USELESS_SCORE if user.effects[PBEffects::PowerTrick]
    # Check stats
    user_atk = user.base_stat(:ATTACK)
    user_def = user.base_stat(:DEFENSE)
    next NewAI::MOVE_USELESS_SCORE if user_atk == user_def
    # NOTE: Prefer to raise Attack regardless of the drop to Defense. Only
    #       prefer to raise Defense if Attack is useless.
    if user_def > user_atk   # Attack will be raised
      next NewAI::MOVE_USELESS_SCORE if !ai.stat_raise_worthwhile?(user, :ATTACK, true)
      score += (40 * ((user_def.to_f / user_atk) - 1)).to_i
      score += 5 if !ai.stat_drop_worthwhile?(user, :DEFENSE, true)   # No downside
    else   # Defense will be raised
      next NewAI::MOVE_USELESS_SCORE if !ai.stat_raise_worthwhile?(user, :DEFENSE, true)
      # Don't want to lower user's Attack if it can make use of it
      next NewAI::MOVE_USELESS_SCORE if ai.stat_drop_worthwhile?(user, :ATTACK, true)
      score += (40 * ((user_atk.to_f / user_def) - 1)).to_i
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("161",
  proc { |score, move, user, target, ai, battle|
    user_speed = user.base_stat(:SPEED)
    target_speed = target.base_stat(:SPEED)
    next NewAI::MOVE_USELESS_SCORE if user_speed == target_speed
    if battle.field.effects[PBEffects::TrickRoom] > 1
      # User wants to be slower so it can move first
      next NewAI::MOVE_USELESS_SCORE if target_speed > user_speed
      score += (40 * ((user_speed.to_f / target_speed) - 1)).to_i
    else
      # User wants to be faster so it can move first
      next NewAI::MOVE_USELESS_SCORE if user_speed > target_speed
      score += (40 * ((target_speed.to_f / user_speed) - 1)).to_i
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("058",
  proc { |score, move, user, target, ai, battle|
    user_atk = user.base_stat(:ATTACK)
    user_spatk = user.base_stat(:SPECIAL_ATTACK)
    target_atk = target.base_stat(:ATTACK)
    target_spatk = target.base_stat(:SPECIAL_ATTACK)
    next NewAI::MOVE_USELESS_SCORE if user_atk >= target_atk && user_spatk >= target_spatk
    change_matters = false
    # Score based on changes to Attack
    if target_atk > user_atk
      # User's Attack will be raised, target's Attack will be lowered
      if ai.stat_raise_worthwhile?(user, :ATTACK, true) ||
         ai.stat_drop_worthwhile?(target, :ATTACK, true)
        score += (40 * ((target_atk.to_f / user_atk) - 1)).to_i
        change_matters = true
      end
    elsif target_atk < user_atk
      # User's Attack will be lowered, target's Attack will be raised
      if ai.stat_drop_worthwhile?(user, :ATTACK, true) ||
         ai.stat_raise_worthwhile?(target, :ATTACK, true)
        score -= (40 * ((user_atk.to_f / target_atk) - 1)).to_i
        change_matters = true
      end
    end
    # Score based on changes to Special Attack
    if target_spatk > user_spatk
      # User's Special Attack will be raised, target's Special Attack will be lowered
      if ai.stat_raise_worthwhile?(user, :SPECIAL_ATTACK, true) ||
         ai.stat_drop_worthwhile?(target, :SPECIAL_ATTACK, true)
        score += (40 * ((target_spatk.to_f / user_spatk) - 1)).to_i
        change_matters = true
      end
    elsif target_spatk < user_spatk
      # User's Special Attack will be lowered, target's Special Attack will be raised
      if ai.stat_drop_worthwhile?(user, :SPECIAL_ATTACK, true) ||
         ai.stat_raise_worthwhile?(target, :SPECIAL_ATTACK, true)
        score -= (40 * ((user_spatk.to_f / target_spatk) - 1)).to_i
        change_matters = true
      end
    end
    next NewAI::MOVE_USELESS_SCORE if !change_matters
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("059",
  proc { |score, move, user, target, ai, battle|
    user_def = user.base_stat(:DEFENSE)
    user_spdef = user.base_stat(:SPECIAL_DEFENSE)
    target_def = target.base_stat(:DEFENSE)
    target_spdef = target.base_stat(:SPECIAL_DEFENSE)
    next NewAI::MOVE_USELESS_SCORE if user_def >= target_def && user_spdef >= target_spdef
    change_matters = false
    # Score based on changes to Defense
    if target_def > user_def
      # User's Defense will be raised, target's Defense will be lowered
      if ai.stat_raise_worthwhile?(user, :DEFENSE, true) ||
         ai.stat_drop_worthwhile?(target, :DEFENSE, true)
        score += (40 * ((target_def.to_f / user_def) - 1)).to_i
        change_matters = true
      end
    elsif target_def < user_def
      # User's Defense will be lowered, target's Defense will be raised
      if ai.stat_drop_worthwhile?(user, :DEFENSE, true) ||
         ai.stat_raise_worthwhile?(target, :DEFENSE, true)
        score -= (40 * ((user_def.to_f / target_def) - 1)).to_i
        change_matters = true
      end
    end
    # Score based on changes to Special Defense
    if target_spdef > user_spdef
      # User's Special Defense will be raised, target's Special Defense will be lowered
      if ai.stat_raise_worthwhile?(user, :SPECIAL_DEFENSE, true) ||
         ai.stat_drop_worthwhile?(target, :SPECIAL_DEFENSE, true)
        score += (40 * ((target_spdef.to_f / user_spdef) - 1)).to_i
        change_matters = true
      end
    elsif target_spdef < user_spdef
      # User's Special Defense will be lowered, target's Special Defense will be raised
      if ai.stat_drop_worthwhile?(user, :SPECIAL_DEFENSE, true) ||
         ai.stat_raise_worthwhile?(target, :SPECIAL_DEFENSE, true)
        score -= (40 * ((user_spdef.to_f / target_spdef) - 1)).to_i
        change_matters = true
      end
    end
    next NewAI::MOVE_USELESS_SCORE if !change_matters
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("05A",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if user.hp >= target.hp
    mult = (user.hp + target.hp) / (2.0 * user.hp)
    score += (10 * mult).to_i if mult >= 1.2
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("05B",
  proc { |move, user, ai, battle|
    next user.pbOwnSide.effects[PBEffects::Tailwind] > 0
  }
)
AIHandlers::MoveEffectScore.add("05B",
  proc { |score, move, user, ai, battle|
    # Don't want to make allies faster if Trick Room will make them act later
    if ai.trainer.medium_skill?
      next NewAI::MOVE_USELESS_SCORE if battle.field.effects[PBEffects::TrickRoom] > 1
    end
    # Get the speeds of all battlers
    ally_speeds = []
    foe_speeds = []
    ai.each_battler do |b|
      spd = b.rough_stat(:SPEED)
      (b.opposes?(user)) ? foe_speeds.push(spd) : ally_speeds.push(spd)
    end
    next NewAI::MOVE_USELESS_SCORE if ally_speeds.min > foe_speeds.max
    # Compare speeds of all battlers
    outspeeds = 0
    ally_speeds.each do |ally_speed|
      foe_speeds.each do |foe_speed|
        outspeeds += 1 if foe_speed > ally_speed && foe_speed < ally_speed * 2
      end
    end
    next NewAI::MOVE_USELESS_SCORE if outspeeds == 0
    # This move will achieve something
    next score + 8 + (10 * outspeeds)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("124",
  proc { |score, move, user, ai, battle|
    change_matters = false
    ai.each_battler do |b, i|
      b_def = b.base_stat(:DEFENSE)
      b_spdef = b.base_stat(:SPECIAL_DEFENSE)
      next if b_def == b_spdef
      score_change = 0
      if b_def > b_spdef
        # Battler's Defense will be lowered, battler's Special Defense will be raised
        if ai.stat_drop_worthwhile?(b, :DEFENSE, true)
          score_change -= (20 * ((b_def.to_f / b_spdef) - 1)).to_i
          change_matters = true
        end
        # Battler's Special Defense will be raised
        if ai.stat_raise_worthwhile?(b, :SPECIAL_DEFENSE, true)
          score_change += (20 * ((b_def.to_f / b_spdef) - 1)).to_i
          change_matters = true
        end
      else
        # Battler's Special Defense will be lowered
        if ai.stat_drop_worthwhile?(b, :SPECIAL_DEFENSE, true)
          score_change -= (20 * ((b_spdef.to_f / b_def) - 1)).to_i
          change_matters = true
        end
        # Battler's Defense will be raised
        if ai.stat_raise_worthwhile?(b, :DEFENSE, true)
          score_change += (20 * ((b_spdef.to_f / b_def) - 1)).to_i
          change_matters = true
        end
      end
      score += (b.opposes?(user)) ? -score_change : score_change
    end
    next NewAI::MOVE_USELESS_SCORE if !change_matters
    next NewAI::MOVE_USELESS_SCORE if score <= NewAI::MOVE_BASE_SCORE
    next score
  }
)
