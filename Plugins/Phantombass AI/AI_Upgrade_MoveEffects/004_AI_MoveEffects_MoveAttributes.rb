#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("06A",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbFixedDamage(user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("06B",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbFixedDamage(user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("06C",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbFixedDamage(user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("06D",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbFixedDamage(user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("06F",
  proc { |power, move, user, target, ai, battle|
    next user.level   # Average power
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("06E",
  proc { |move, user, target, ai, battle|
    next user.hp >= target.hp
  }
)
AIHandlers::MoveBasePower.add("06E",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbFixedDamage(user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("070",
  proc { |move, user, target, ai, battle|
    next true if target.level > user.level
    next true if !battle.moldBreaker && target.has_active_ability?(:STURDY)
    next false
  }
)
AIHandlers::MoveBasePower.add("070",
  proc { |power, move, user, target, ai, battle|
    next target.hp
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("070",
  proc { |score, move, user, target, ai, battle|
    # Don't prefer if the target has less HP and user has a non-OKHO damaging move
    if ai.trainer.has_skill_flag?("HPAware")
      if user.check_for_move { |m| m.damagingMove? && m.function != "070"}
        score -= 12 if target.hp <= target.totalhp / 2
        score -= 8 if target.hp <= target.totalhp / 4
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("070",
  proc { |move, user, target, ai, battle|
    next true if target.has_type?(:ICE) && move.id == :SHEERCOLD
    next AIHandlers.move_will_fail_against_target?("070", move, user, target, ai, battle)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("074",
  proc { |score, move, user, target, ai, battle|
    target.battler.allAllies.each do |b|
      next if !b.near?(target.battler) || !b.battler.takesIndirectDamage?
      score += 10
      if ai.trainer.has_skill_flag?("HPAware")
        score += 10 if b.hp <= b.totalhp / 16
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("08B",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("08B",
                                         "098")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("08B",
                                         "08C")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("08B",
                                         "089")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("08B",
                                         "08A")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("08B",
                                         "08E")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("08B",
                                         "08F")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("08B",
                                         "099")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("08B",
                                         "08D")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("097",
  proc { |power, move, user, target, ai, battle|
    next 0 if move.move.pp == 0 && move.move.totalpp > 0
    dmgs = [200, 80, 60, 50, 40]
    ppLeft = [move.move.pp - 1, dmgs.length - 1].min
    next dmgs[ppLeft]
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("09A",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("09A",
                                         "09B")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("091",
  proc { |power, move, user, target, ai, battle|
    next power << user.effects[PBEffects::FuryCutter]
  }
)
AIHandlers::MoveEffectScore.add("091",
  proc { |score, move, user, ai, battle|
    # Prefer continuing to use this move
    score += 10 if user.effects[PBEffects::FuryCutter] > 0
    # Prefer if holding the Metronome
    score += 7 if user.has_active_item?(:METRONOME)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("092",
  proc { |power, move, user, target, ai, battle|
    next power * (user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter] + 1)
  }
)
AIHandlers::MoveEffectScore.add("091",
  proc { |score, move, user, ai, battle|
    # Prefer continuing to use this move
    score += 10 if user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter] > 0
    # Prefer if holding the Metronome
    score += 7 if user.has_active_item?(:METRONOME)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("095",
  proc { |power, move, user, target, ai, battle|
    power = 71   # Average damage
    next move.move.pbModifyDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("080",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("080",
                                         "07E")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("080",
                                         "07D")
AIHandlers::MoveEffectAgainstTargetScore.add("07D",
  proc { |score, move, user, target, ai, battle|
    if target.status == :SLEEP && target.statusCount > 1   # Will cure status
      if target.wants_status_problem?(:SLEEP)
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
AIHandlers::MoveBasePower.add("07B",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("07B",
                                         "07C")
AIHandlers::MoveEffectAgainstTargetScore.add("07C",
  proc { |score, move, user, target, ai, battle|
    if target.status == :PARALYSIS   # Will cure status
      if target.wants_status_problem?(:PARALYSIS)
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
AIHandlers::MoveBasePower.add("07F",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("086",
  proc { |power, move, user, target, ai, battle|
    power *= 2 if !user.item || user.has_active_item?(:FLYINGGEM)
    next power
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("075",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbModifyDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("075",
                                         "076")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("077",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("077",
                                         "18D")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("077",
                                         "166")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("077",
                                         "085")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("081",
  proc { |score, move, user, ai, battle|
    # Prefer if user is slower than its foe(s) and the foe(s) can attack
    ai.each_foe_battler(user.side) do |b, i|
      next if user.faster_than?(b) || !b.can_attack?
      score += 8
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("082",
  proc { |score, move, user, target, ai, battle|
    # Prefer if a user's ally is faster than the user and that ally can attack
    ai.each_foe_battler(target.side) do |b, i|
      next if i == user.index
      next if user.faster_than?(b) || !b.can_attack?
      score += 8
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
# DoublePowerIfUserStatsLoweredThisTurn

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("084",
  proc { |score, move, user, target, ai, battle|
    score += 10 if target.faster_than?(user)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("178",
  proc { |score, move, user, target, ai, battle|
    score += 10 if user.faster_than?(target)
    next score
  }
)

#===============================================================================
#
#===============================================================================
# AlwaysCriticalHit

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("15E",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if user.effects[PBEffects::LaserFocus] > 0
    # Useless if the user's critical hit stage ensures critical hits already, or
    # critical hits are impossible (e.g. via Lucky Chant)
    crit_stage = 0
    crit_stage = -1 if user.battler.pbOwnSide.effects[PBEffects::LuckyChant] > 0
    if crit_stage >= 0 && user.ability_active? && ![:MERCILESS].include?(user.ability_id)
      crit_stage = BattleHandlers.triggerCriticalCalcUserAbility(user.battler.ability,
         user.battler, user.battler, crit_stage)
    end
    if crit_stage >= 0 && user.item_active?
      crit_stage = BattleHandlers.triggerCriticalCalcUserItem(user.battler.item,
         user.battler, user.battler, crit_stage)
    end
    if crit_stage >= 0 && crit_stage < 50
      crit_stage += user.effects[PBEffects::FocusEnergy]
      crit_stage = [crit_stage, PokeBattle_Move::CRITICAL_HIT_RATIOS.length - 1].min
    end
    if crit_stage < 0 ||
       crit_stage >= PokeBattle_Move::CRITICAL_HIT_RATIOS.length ||
       PokeBattle_Move::CRITICAL_HIT_RATIOS[crit_stage] == 1
      next NewAI::MOVE_USELESS_SCORE
    end
    # Prefer if user knows a damaging move which won't definitely critical hit
    if user.check_for_move { |m| m.damagingMove? && m.function_code != "0A0"}
      score += 15
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0A1",
  proc { |move, user, ai, battle|
    next user.pbOwnSide.effects[PBEffects::LuckyChant] > 0
  }
)
AIHandlers::MoveEffectScore.add("0A1",
  proc { |score, move, user, ai, battle|
    # Useless if Pokémon on the user's side are immune to critical hits
    user_side_immune = true
    ai.each_same_side_battler(user.side) do |b, i|
      crit_stage = 0
      if b.ability_active?
        crit_stage = BattleHandlers.triggerCriticalCalcTargetAbility(b.battler.ability,
           b.battler, b.battler, crit_stage)
        next if crit_stage < 0
      end
      if b.item_active?
        crit_stage = BattleHandlers.triggerCriticalCalcTargetItem(b.battler.item,
           b.battler, b.battler, crit_stage)
        next if crit_stage < 0
      end
      user_side_immune = false
      break
    end
    next NewAI::MOVE_USELESS_SCORE if user_side_immune
    # Prefer if any foe has an increased critical hit rate or moves/effects that
    # make critical hits more likely
    ai.each_foe_battler(user.side) do |b, i|
      crit_stage = 0
      if crit_stage >= 0 && b.ability_active?
        crit_stage = BattleHandlers.triggerCriticalCalcUserAbility(b.battler.ability,
           b.battler, user.battler, crit_stage)
        next if crit_stage < 0
      end
      if crit_stage >= 0 && b.item_active?
        crit_stage = BattleHandlers.triggerCriticalCalcUserItem(b.battler.item,
           b.battler, user.battler, crit_stage)
        next if crit_stage < 0
      end
      if crit_stage >= 0 && crit_stage < 50
        crit_stage += b.effects[PBEffects::FocusEnergy]
        crit_stage += 1 if b.check_for_move { |m| m.highCriticalRate? }
        crit_stage = 99 if b.check_for_move { |m| m.pbCritialOverride(b.battler, user.battler) > 0 }
        crit_stage = [crit_stage, PokeBattle_Move::CRITICAL_HIT_RATIOS.length - 1].min
      end
      score += 8 * crit_stage if crit_stage > 0
      score += 10 if b.effects[PBEffects::LaserFocus] > 0
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0E9",
  proc { |move, user, target, ai, battle|
    next target.hp == 1
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("0E8",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if user.rough_end_of_round_damage > 0
    # Prefer for each foe that can attack
    useless = true
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack?
      score += 5
      useless = false
    end
    next NewAI::MOVE_USELESS_SCORE if useless
    # Don't prefer if user has high HP, prefer if user has lower HP
    if ai.trainer.has_skill_flag?("HPAware")
      if user.hp >= user.totalhp / 2
        score -= 15
      elsif user.hp <= user.totalhp / 4
        score += 8
      end
    end
    # Don't prefer if the user used a protection move last turn, making this one
    # less likely to work
    score -= (user.effects[PBEffects::ProtectRate] - 1) * 8
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("09D",
  proc { |move, user, ai, battle|
    next battle.field.effects[PBEffects::MudSportField] > 0 if Settings::MECHANICS_GENERATION >= 6
    next battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
  }
)
AIHandlers::MoveEffectScore.add("09D",
  proc { |score, move, user, ai, battle|
    # Don't prefer the lower the user's HP is
    if ai.trainer.has_skill_flag?("HPAware")
      if user.hp <= user.totalhp / 2
        score -= (20 * (0.75 - (user.hp.to_f / user.totalhp))).to_i   # -5 to -15
      end
    end
    # Prefer if foes have Electric moves
    any_foe_electric_moves = false
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.has_damaging_move_of_type?(:ELECTRIC)
      score += 15
      score += 7 if !b.check_for_move { |m| m.damagingMove? && m.pbCalcType(b.battler) != :ELECTRIC }
      any_foe_electric_moves = true
    end
    next NewAI::MOVE_USELESS_SCORE if !any_foe_electric_moves
    # Don't prefer if any allies have Electric moves
    ai.each_same_side_battler(user.side) do |b, i|
      next if !b.has_damaging_move_of_type?(:ELECTRIC)
      score -= 10
      score -= 5 if !b.check_for_move { |m| m.damagingMove? && m.pbCalcType(b.battler) != :ELECTRIC }
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("09E",
  proc { |move, user, ai, battle|
    next battle.field.effects[PBEffects::WaterSportField] > 0 if Settings::MECHANICS_GENERATION >= 6
    next battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
  }
)
AIHandlers::MoveEffectScore.add("09E",
  proc { |score, move, user, ai, battle|
    # Don't prefer the lower the user's HP is
    if ai.trainer.has_skill_flag?("HPAware")
      if user.hp <= user.totalhp / 2
        score -= (20 * (0.75 - (user.hp.to_f / user.totalhp))).to_i   # -5 to -15
      end
    end
    # Prefer if foes have Fire moves
    any_foe_fire_moves = false
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.has_damaging_move_of_type?(:FIRE)
      score += 15
      score += 7 if !b.check_for_move { |m| m.damagingMove? && m.pbCalcType(b.battler) != :FIRE }
      any_foe_fire_moves = true
    end
    next NewAI::MOVE_USELESS_SCORE if !any_foe_fire_moves
    # Don't prefer if any allies have Fire moves
    ai.each_same_side_battler(user.side) do |b, i|
      next if !b.has_damaging_move_of_type?(:FIRE)
      score -= 10
      score -= 5 if !b.check_for_move { |m| m.damagingMove? && m.pbCalcType(b.battler) != :FIRE }
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0A2",
  proc { |move, user, ai, battle|
    next user.pbOwnSide.effects[PBEffects::Reflect] > 0
  }
)
AIHandlers::MoveEffectScore.add("0A2",
  proc { |score, move, user, ai, battle|
    # Doesn't stack with Aurora Veil
    next NewAI::MOVE_USELESS_SCORE if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
    # Don't prefer the lower the user's HP is
    if ai.trainer.has_skill_flag?("HPAware") && battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
      if user.hp <= user.totalhp / 2
        score -= (20 * (0.75 - (user.hp.to_f / user.totalhp))).to_i   # -5 to -15
      end
    end
    # Prefer if foes have physical moves (moreso if they don't have special moves)
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| m.physicalMove?(m.type) }
      score += 10
      score += 8 if !b.check_for_move { |m| m.specialMove?(m.type) }
    end
    # Prefer if user has Light Clay
    score += 5 if user.has_active_item?(:LIGHTCLAY)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0A3",
  proc { |move, user, ai, battle|
    next user.pbOwnSide.effects[PBEffects::LightScreen] > 0
  }
)
AIHandlers::MoveEffectScore.add("0A3",
  proc { |score, move, user, ai, battle|
    # Doesn't stack with Aurora Veil
    next NewAI::MOVE_USELESS_SCORE if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
    # Don't prefer the lower the user's HP is
    if ai.trainer.has_skill_flag?("HPAware") && battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
      if user.hp <= user.totalhp / 2
        score -= (20 * (0.75 - (user.hp.to_f / user.totalhp))).to_i   # -5 to -15
      end
    end
    # Prefer if foes have special moves (moreso if they don't have physical moves)
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.check_for_move { |m| m.specialMove?(m.type) }
      score += 10
      score += 8 if !b.check_for_move { |m| m.physicalMove?(m.type) }
    end
    # Prefer if user has Light Clay
    score += 5 if user.has_active_item?(:LIGHTCLAY)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("167",
  proc { |move, user, ai, battle|
    next true if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
    next true if user.battler.effectiveWeather != :Hail
    next false
  }
)
AIHandlers::MoveEffectScore.add("167",
  proc { |score, move, user, ai, battle|
    # Doesn't stack with Reflect/Light Screen
    next NewAI::MOVE_USELESS_SCORE if user.pbOwnSide.effects[PBEffects::Reflect] > 0 &&
                                           user.pbOwnSide.effects[PBEffects::LightScreen] > 0
    # Don't prefer the lower the user's HP is
    if ai.trainer.has_skill_flag?("HPAware") && battle.pbAbleNonActiveCount(user.idxOwnSide) == 0
      if user.hp <= user.totalhp / 2
        score -= (20 * (0.75 - (user.hp.to_f / user.totalhp))).to_i   # -5 to -15
      end
    end
    # Prefer if user has Light Clay
    score += 5 if user.has_active_item?(:LIGHTCLAY)
    next score + 15
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("10A",
  proc { |score, move, user, ai, battle|
    # Prefer if allies have physical moves that are being weakened
    if user.pbOpposingSide.effects[PBEffects::Reflect] > 1 ||
       user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 1
      ai.each_same_side_battler(user.side) do |b, i|
        score += 10 if b.check_for_move { |m| m.physicalMove?(m.type) }
      end
    end
    # Prefer if allies have special moves that are being weakened
    if user.pbOpposingSide.effects[PBEffects::LightScreen] > 1 ||
       user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 1
      ai.each_same_side_battler(user.side) do |b, i|
        score += 10 if b.check_for_move { |m| m.specialMove?(m.type) }
      end
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("0AA",
  proc { |score, move, user, ai, battle|
    # Useless if the success chance is 25% or lower
    next NewAI::MOVE_USELESS_SCORE if user.effects[PBEffects::ProtectRate] >= 4
    # Score changes for each foe
    useless = true
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack?
      next if !b.check_for_move { |m| m.canProtectAgainst? }
      next if b.has_active_ability?(:UNSEENFIST) && b.check_for_move { |m| m.contactMove? }
      useless = false
      # General preference
      score += 7
      # Prefer if the foe is in the middle of using a two turn attack
      score += 15 if b.effects[PBEffects::TwoTurnAttack] &&
                     GameData::Move.get(b.effects[PBEffects::TwoTurnAttack]).flags[/b/]
      # Prefer if foe takes EOR damage, don't prefer if they have EOR healing
      b_eor_damage = b.rough_end_of_round_damage
      if b_eor_damage > 0
        score += 8
      elsif b_eor_damage < 0
        score -= 8
      end
    end
    next NewAI::MOVE_USELESS_SCORE if useless
    # Prefer if the user has EOR healing, don't prefer if they take EOR damage
    user_eor_damage = user.rough_end_of_round_damage
    if user_eor_damage >= user.hp
      next NewAI::MOVE_USELESS_SCORE
    elsif user_eor_damage > 0
      score -= 8
    elsif user_eor_damage < 0
      score += 8
    end
    # Don't prefer if the user used a protection move last turn, making this one
    # less likely to work
    score -= (user.effects[PBEffects::ProtectRate] - 1) * ((Settings::MECHANICS_GENERATION >= 6) ? 15 : 10)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("168",
  proc { |score, move, user, ai, battle|
    # Useless if the success chance is 25% or lower
    next NewAI::MOVE_USELESS_SCORE if user.effects[PBEffects::ProtectRate] >= 4
    # Score changes for each foe
    useless = true
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack?
      next if !b.check_for_move { |m| m.canProtectAgainst? }
      next if b.has_active_ability?(:UNSEENFIST) && b.check_for_move { |m| m.contactMove? }
      useless = false
      # General preference
      score += 7
      # Prefer if the foe is likely to be poisoned by this move
      if b.check_for_move { |m| m.contactMove? }
        poison_score = AIHandlers.apply_move_effect_against_target_score("005",
           0, move, user, b, ai, battle)
        if poison_score != NewAI::MOVE_USELESS_SCORE
          score += poison_score / 2   # Halved because we don't know what move b will use
        end
      end
      # Prefer if the foe is in the middle of using a two turn attack
      score += 15 if b.effects[PBEffects::TwoTurnAttack] &&
                     GameData::Move.get(b.effects[PBEffects::TwoTurnAttack]).flags[/b/]
      # Prefer if foe takes EOR damage, don't prefer if they have EOR healing
      b_eor_damage = b.rough_end_of_round_damage
      if b_eor_damage > 0
        score += 8
      elsif b_eor_damage < 0
        score -= 8
      end
    end
    next NewAI::MOVE_USELESS_SCORE if useless
    # Prefer if the user has EOR healing, don't prefer if they take EOR damage
    user_eor_damage = user.rough_end_of_round_damage
    if user_eor_damage >= user.hp
      next NewAI::MOVE_USELESS_SCORE
    elsif user_eor_damage > 0
      score -= 8
    elsif user_eor_damage < 0
      score += 8
    end
    # Don't prefer if the user used a protection move last turn, making this one
    # less likely to work
    score -= (user.effects[PBEffects::ProtectRate] - 1) * ((Settings::MECHANICS_GENERATION >= 6) ? 15 : 10)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("14B",
  proc { |score, move, user, ai, battle|
    # Useless if the success chance is 25% or lower
    next NewAI::MOVE_USELESS_SCORE if user.effects[PBEffects::ProtectRate] >= 4
    # Score changes for each foe
    useless = true
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack?
      next if !b.check_for_move { |m| m.damagingMove? && m.canProtectAgainst? }
      next if b.has_active_ability?(:UNSEENFIST) && b.check_for_move { |m| m.contactMove? }
      useless = false
      # General preference
      score += 7
      # Prefer if the foe's Attack can be lowered by this move
      if b.battler.affectedByContactEffect? && b.check_for_move { |m| m.contactMove? }
        drop_score = ai.get_score_for_target_stat_drop(
           0, b, [:ATTACK, (Settings::MECHANICS_GENERATION >= 8) ? 1 : 2], false)
        score += drop_score / 2   # Halved because we don't know what move b will use
      end
      # Prefer if the foe is in the middle of using a two turn attack
      score += 15 if b.effects[PBEffects::TwoTurnAttack] &&
                     GameData::Move.get(b.effects[PBEffects::TwoTurnAttack]).flags[/b/]
      # Prefer if foe takes EOR damage, don't prefer if they have EOR healing
      b_eor_damage = b.rough_end_of_round_damage
      if b_eor_damage > 0
        score += 8
      elsif b_eor_damage < 0
        score -= 8
      end
    end
    next NewAI::MOVE_USELESS_SCORE if useless
    # Prefer if the user has EOR healing, don't prefer if they take EOR damage
    user_eor_damage = user.rough_end_of_round_damage
    if user_eor_damage >= user.hp
      next NewAI::MOVE_USELESS_SCORE
    elsif user_eor_damage > 0
      score -= 8
    elsif user_eor_damage < 0
      score += 8
    end
    # Don't prefer if the user used a protection move last turn, making this one
    # less likely to work
    score -= (user.effects[PBEffects::ProtectRate] - 1) * ((Settings::MECHANICS_GENERATION >= 6) ? 15 : 10)
    # Aegislash
    score += 10 if user.battler.isSpecies?(:AEGISLASH) && user.battler.form == 1 &&
                   user.ability == :STANCECHANGE
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("180",
  proc { |score, move, user, ai, battle|
    # Useless if the success chance is 25% or lower
    next NewAI::MOVE_USELESS_SCORE if user.effects[PBEffects::ProtectRate] >= 4
    # Score changes for each foe
    useless = true
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack?
      next if !b.check_for_move { |m| m.damagingMove? && m.canProtectAgainst? }
      next if b.has_active_ability?(:UNSEENFIST) && b.check_for_move { |m| m.contactMove? }
      useless = false
      # General preference
      score += 7
      # Prefer if the foe's Attack can be lowered by this move
      if b.battler.affectedByContactEffect? && b.check_for_move { |m| m.contactMove? }
        drop_score = ai.get_score_for_target_stat_drop(0, b, [:DEFENSE, 2], false)
        score += drop_score / 2   # Halved because we don't know what move b will use
      end
      # Prefer if the foe is in the middle of using a two turn attack
      score += 15 if b.effects[PBEffects::TwoTurnAttack] &&
                     GameData::Move.get(b.effects[PBEffects::TwoTurnAttack]).flags[/b/]
      # Prefer if foe takes EOR damage, don't prefer if they have EOR healing
      b_eor_damage = b.rough_end_of_round_damage
      if b_eor_damage > 0
        score += 8
      elsif b_eor_damage < 0
        score -= 8
      end
    end
    next NewAI::MOVE_USELESS_SCORE if useless
    # Prefer if the user has EOR healing, don't prefer if they take EOR damage
    user_eor_damage = user.rough_end_of_round_damage
    if user_eor_damage >= user.hp
      next NewAI::MOVE_USELESS_SCORE
    elsif user_eor_damage > 0
      score -= 8
    elsif user_eor_damage < 0
      score += 8
    end
    # Don't prefer if the user used a protection move last turn, making this one
    # less likely to work
    score -= (user.effects[PBEffects::ProtectRate] - 1) * ((Settings::MECHANICS_GENERATION >= 6) ? 15 : 10)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("14C",
  proc { |score, move, user, ai, battle|
    # Useless if the success chance is 25% or lower
    next NewAI::MOVE_USELESS_SCORE if user.effects[PBEffects::ProtectRate] >= 4
    # Score changes for each foe
    useless = true
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack?
      next if !b.check_for_move { |m| m.canProtectAgainst? }
      next if b.has_active_ability?(:UNSEENFIST) && b.check_for_move { |m| m.contactMove? }
      useless = false
      # General preference
      score += 7
      # Prefer if this move will deal damage
      if b.battler.affectedByContactEffect? && b.check_for_move { |m| m.contactMove? }
        score += 5
      end
      # Prefer if the foe is in the middle of using a two turn attack
      score += 15 if b.effects[PBEffects::TwoTurnAttack] &&
                     GameData::Move.get(b.effects[PBEffects::TwoTurnAttack]).flags[/b/]
      # Prefer if foe takes EOR damage, don't prefer if they have EOR healing
      b_eor_damage = b.rough_end_of_round_damage
      if b_eor_damage > 0
        score += 8
      elsif b_eor_damage < 0
        score -= 8
      end
    end
    next NewAI::MOVE_USELESS_SCORE if useless
    # Prefer if the user has EOR healing, don't prefer if they take EOR damage
    user_eor_damage = user.rough_end_of_round_damage
    if user_eor_damage >= user.hp
      next NewAI::MOVE_USELESS_SCORE
    elsif user_eor_damage > 0
      score -= 8
    elsif user_eor_damage < 0
      score += 8
    end
    # Don't prefer if the user used a protection move last turn, making this one
    # less likely to work
    score -= (user.effects[PBEffects::ProtectRate] - 1) * ((Settings::MECHANICS_GENERATION >= 6) ? 15 : 10)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("149",
  proc { |move, user, ai, battle|
    next user.turnCount > 0
  }
)
AIHandlers::MoveEffectScore.add("149",
  proc { |score, move, user, ai, battle|
    # Score changes for each foe
    useless = true
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack?
      next if !b.check_for_move { |m| m.damagingMove? && m.canProtectAgainst? }
      next if b.has_active_ability?(:UNSEENFIST) && b.check_for_move { |m| m.contactMove? }
      useless = false
      # General preference
      score += 7
      # Prefer if the foe is in the middle of using a two turn attack
      score += 15 if b.effects[PBEffects::TwoTurnAttack] &&
                     GameData::Move.get(b.effects[PBEffects::TwoTurnAttack]).flags[/b/]
      # Prefer if foe takes EOR damage, don't prefer if they have EOR healing
      b_eor_damage = b.rough_end_of_round_damage
      if b_eor_damage > 0
        score += 8
      elsif b_eor_damage < 0
        score -= 8
      end
    end
    next NewAI::MOVE_USELESS_SCORE if useless
    # Prefer if the user has EOR healing, don't prefer if they take EOR damage
    user_eor_damage = user.rough_end_of_round_damage
    if user_eor_damage >= user.hp
      next NewAI::MOVE_USELESS_SCORE
    elsif user_eor_damage > 0
      score -= 8
    elsif user_eor_damage < 0
      score += 8
    end
    # Use it or lose it
    score += 25
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("14A",
  proc { |move, user, ai, battle|
    next user.pbOwnSide.effects[PBEffects::CraftyShield]
  }
)
AIHandlers::MoveEffectScore.add("14A",
  proc { |score, move, user, ai, battle|
    # Score changes for each foe
    useless = true
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack?
      next if !b.check_for_move { |m| m.statusMove? && m.pbTarget(b.battler).targets_foe &&
                                      !m.pbTarget(b.battler).targets_all }
      useless = false
      # General preference
      score += 5
      # Prefer if foe takes EOR damage, don't prefer if they have EOR healing
      b_eor_damage = b.rough_end_of_round_damage
      if b_eor_damage > 0
        score += 8
      elsif b_eor_damage < 0
        score -= 8
      end
    end
    next NewAI::MOVE_USELESS_SCORE if useless
    # Prefer if the user has EOR healing, don't prefer if they take EOR damage
    user_eor_damage = user.rough_end_of_round_damage
    if user_eor_damage >= user.hp
      next NewAI::MOVE_USELESS_SCORE
    elsif user_eor_damage > 0
      score -= 8
    elsif user_eor_damage < 0
      score += 8
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0AB",
  proc { |move, user, ai, battle|
    next user.pbOwnSide.effects[PBEffects::QuickGuard]
  }
)
AIHandlers::MoveEffectScore.add("0AB",
  proc { |score, move, user, ai, battle|
    # Useless if the success chance is 25% or lower
    next NewAI::MOVE_USELESS_SCORE if user.effects[PBEffects::ProtectRate] >= 4
    # Score changes for each foe
    useless = true
    ai.each_foe_battler(user.side) do |b, i|
      next if !b.can_attack?
      next if !b.check_for_move { |m| m.pbPriority(b.battler) > 0 && m.canProtectAgainst? }
      useless = false
      # General preference
      score += 7
      # Prefer if foe takes EOR damage, don't prefer if they have EOR healing
      b_eor_damage = b.rough_end_of_round_damage
      if b_eor_damage > 0
        score += 8
      elsif b_eor_damage < 0
        score -= 8
      end
    end
    next NewAI::MOVE_USELESS_SCORE if useless
    # Prefer if the user has EOR healing, don't prefer if they take EOR damage
    user_eor_damage = user.rough_end_of_round_damage
    if user_eor_damage >= user.hp
      next NewAI::MOVE_USELESS_SCORE
    elsif user_eor_damage > 0
      score -= 8
    elsif user_eor_damage < 0
      score += 8
    end
    # Don't prefer if the user used a protection move last turn, making this one
    # less likely to work
    score -= (user.effects[PBEffects::ProtectRate] - 1) * ((Settings::MECHANICS_GENERATION >= 6) ? 15 : 10)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0AC",
  proc { |move, user, ai, battle|
    next user.pbOwnSide.effects[PBEffects::WideGuard]
  }
)
AIHandlers::MoveEffectScore.add("0AC",
  proc { |score, move, user, ai, battle|
    # Useless if the success chance is 25% or lower
    next NewAI::MOVE_USELESS_SCORE if user.effects[PBEffects::ProtectRate] >= 4
    # Score changes for each foe
    useless = true
    ai.each_battler do |b, i|
      next if b.index == user.index || !b.can_attack?
      next if !b.check_for_move { |m| (Settings::MECHANICS_GENERATION >= 7 || move.damagingMove?) &&
                                      m.pbTarget(b.battler).num_targets > 1 }
      useless = false
      # General preference
      score += 7
      # Prefer if foe takes EOR damage, don't prefer if they have EOR healing
      b_eor_damage = b.rough_end_of_round_damage
      if b_eor_damage > 0
        score += (b.opposes?(user)) ? 8 : -8
      elsif b_eor_damage < 0
        score -= (b.opposes?(user)) ? 8 : -8
      end
    end
    next NewAI::MOVE_USELESS_SCORE if useless
    # Prefer if the user has EOR healing, don't prefer if they take EOR damage
    user_eor_damage = user.rough_end_of_round_damage
    if user_eor_damage >= user.hp
      next NewAI::MOVE_USELESS_SCORE
    elsif user_eor_damage > 0
      score -= 8
    elsif user_eor_damage < 0
      score += 8
    end
    # Don't prefer if the user used a protection move last turn, making this one
    # less likely to work
    score -= (user.effects[PBEffects::ProtectRate] - 1) * ((Settings::MECHANICS_GENERATION >= 6) ? 15 : 10)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0AD",
  proc { |score, move, user, target, ai, battle|
    if target.check_for_move { |m| (m.is_a?(PokeBattle_Move::ProtectMove) &&
                                   m.function != "0E8") }
      score += 7
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.copy("147",
                                                        "0AD")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("13B",
  proc { |move, user, ai, battle|
    next !user.battler.isSpecies?(:HOOPA) || user.battler.form != 1
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("13B",
  proc { |score, move, user, target, ai, battle|
    score = AIHandlers.apply_move_effect_against_target_score("0AD",
       score, move, user, target, ai, battle)
    next ai.get_score_for_target_stat_drop(score, user, move.move.statDown, false)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0FA",
  proc { |score, move, user, target, ai, battle|
    next score if !user.battler.takesIndirectDamage? || user.has_active_ability?(:ROCKHEAD)
    dmg = move.rough_damage / 4
    if dmg >= user.hp
      reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
      next NewAI::MOVE_USELESS_SCORE if reserves <= foes
    end
    score -= 25 * [dmg, user.hp].min / user.hp
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0FD",
  proc { |score, move, user, target, ai, battle|
    # Score for being a recoil move
    if user.battler.takesIndirectDamage? && !user.has_active_ability?(:ROCKHEAD)
      dmg = move.rough_damage / 3
      if dmg >= user.hp
        reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
        foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
        next NewAI::MOVE_USELESS_SCORE if reserves <= foes
      end
      score -= 25 * [dmg, user.hp].min / user.hp
    end
    # Score for paralysing
    paralyze_score = AIHandlers.apply_move_effect_against_target_score("007",
       0, move, user, target, ai, battle)
    score += paralyze_score if paralyze_score != NewAI::MOVE_USELESS_SCORE
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0FE",
  proc { |score, move, user, target, ai, battle|
    # Score for being a recoil move
    if user.battler.takesIndirectDamage? && !user.has_active_ability?(:ROCKHEAD)
      dmg = move.rough_damage / 3
      if dmg >= user.hp
        reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
        foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
        next NewAI::MOVE_USELESS_SCORE if reserves <= foes
      end
      score -= 25 * [dmg, user.hp].min / user.hp
    end
    # Score for burning
    burn_score = AIHandlers.apply_move_effect_against_target_score("00A",
       0, move, user, target, ai, battle)
    score += burn_score if burn_score != NewAI::MOVE_USELESS_SCORE
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0FC",
  proc { |score, move, user, target, ai, battle|
    next score if !user.battler.takesIndirectDamage? || user.has_active_ability?(:ROCKHEAD)
    dmg = move.rough_damage / 2
    if dmg >= user.hp
      reserves = battle.pbAbleNonActiveCount(user.idxOwnSide)
      foes     = battle.pbAbleNonActiveCount(user.idxOpposingSide)
      next NewAI::MOVE_USELESS_SCORE if reserves <= foes
    end
    score -= 25 * [dmg, user.hp].min / user.hp
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("144",
  proc { |power, move, user, target, ai, battle|
    if GameData::Type.exists?(:FLYING)
      targetTypes = target.pbTypes(true)
      mult = Effectiveness.calculate(:FLYING, *targetTypes)
      power = (power * mult).round
    end
    next power
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.copy("005",
                                                        "187")

#===============================================================================
#
#===============================================================================
# CategoryDependsOnHigherDamageIgnoreTargetAbility

#===============================================================================
#
#===============================================================================
# UseUserDefenseInsteadOfUserAttack

#===============================================================================
#
#===============================================================================
# UseTargetAttackInsteadOfUserAttack

#===============================================================================
#
#===============================================================================
# UseTargetDefenseInsteadOfTargetSpDef

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0A6",
  proc { |move, user, ai, battle|
    next user.effects[PBEffects::LockOn] > 0
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0A6",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if user.has_active_ability?(:NOGUARD) || target.has_active_ability?(:NOGUARD)
    next NewAI::MOVE_USELESS_SCORE if target.effects[PBEffects::Telekinesis] > 0
    # Prefer if the user knows moves with low accuracy
    user.battler.eachMove do |m|
      next if target.effects[PBEffects::Minimize] && m.tramplesMinimize? && Settings::MECHANICS_GENERATION >= 6
      acc = m.accuracy
      acc = m.pbBaseAccuracy(user.battler, target.battler) if ai.trainer.medium_skill?
      score += 5 if acc < 90 && acc != 0
      score += 8 if acc <= 50 && acc != 0
      score += 8 if m.function == "070"
    end
    # Prefer if the target has increased evasion
    score += 5 * target.stages[:EVASION] if target.stages[:EVASION] > 0
    # Not worth it if the user or the target is at low HP
    if ai.trainer.has_skill_flag?("HPAware")
      score -= 10 if user.hp < user.totalhp / 2
      score -= 8 if target.hp < target.totalhp / 2
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0A7",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if target.effects[PBEffects::Foresight] || user.has_active_ability?(:SCRAPPY)
    # Check if the user knows any moves that would benefit from negating the
    # target's Ghost type immunity
    if target.has_type?(:GHOST)
      user.battler.eachMove do |m|
        next if !m.damagingMove?
        score += 10 if Effectiveness.ineffective_type?(m.pbCalcType(user.battler), :GHOST)
      end
    end
    # Prefer if the target has increased evasion
    score += 10 * target.stages[:EVASION] if target.stages[:EVASION] > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0A8",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if target.effects[PBEffects::MiracleEye]
    # Check if the user knows any moves that would benefit from negating the
    # target's Dark type immunity
    if target.has_type?(:DARK)
      user.battler.eachMove do |m|
        next if !m.damagingMove?
        score += 10 if Effectiveness.ineffective_type?(m.pbCalcType(user.battler), :DARK)
      end
    end
    # Prefer if the target has increased evasion
    score += 10 * target.stages[:EVASION] if target.stages[:EVASION] > 0
    next score
  }
)

#===============================================================================
#
#===============================================================================
# IgnoreTargetDefSpDefEvaStatStages

#===============================================================================
#
#===============================================================================
# TypeIsUserFirstType

#===============================================================================
#
#===============================================================================


#===============================================================================
#
#===============================================================================
# TypeDependsOnUserPlate

#===============================================================================
#
#===============================================================================
# TypeDependsOnUserMemory

#===============================================================================
#
#===============================================================================
# TypeDependsOnUserDrive

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("176",
  proc { |move, user, ai, battle|
    next !user.battler.isSpecies?(:MORPEKO) && user.effects[PBEffects::TransformSpecies] != :MORPEKO
  }
)
AIHandlers::MoveEffectScore.copy("01F",
                                           "176")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("087",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.copy("087",
                                         "18A")

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("145",
  proc { |move, user, target, ai, battle|
    next !user.faster_than?(target)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("145",
  proc { |score, move, user, target, ai, battle|
    # Get Electric's effectiveness against the user
    electric_eff = user.effectiveness_of_type_against_battler(:ELECTRIC, target)
    electric_eff *= 1.5 if target.has_type?(:ELECTRIC)   # STAB
    electric_eff = 0 if user.has_active_ability?([:LIGHTNINGROD, :MOTORDRIVE, :VOLTABSORB])
    # For each of target's moves, get its effectiveness against the user and
    # decide whether it is better or worse than Electric's effectiveness
    old_type_better = 0
    electric_type_better = 0
    target.battler.eachMove do |m|
      next if !m.damagingMove?
      m_type = m.pbCalcType(target.battler)
      next if m_type == :ELECTRIC
      eff = user.effectiveness_of_type_against_battler(m_type, target, m)
      eff *= 1.5 if target.has_type?(m_type)   # STAB
      case m_type
      when :FIRE
        eff = 0 if user.has_active_ability?(:FLASHFIRE)
      when :GRASS
        eff = 0 if user.has_active_ability?(:SAPSIPPER)
      when :WATER
        eff = 0 if user.has_active_ability?([:STORMDRAIN, :WATERABSORB])
      end
      if eff > electric_eff
        electric_type_better += 1
      elsif eff < electric_eff
        old_type_better += 1
      end
    end
    next NewAI::MOVE_USELESS_SCORE if electric_type_better == 0
    next NewAI::MOVE_USELESS_SCORE if electric_type_better < old_type_better
    score += 10 * (electric_type_better - old_type_better)
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("146",
  proc { |score, move, user, ai, battle|
    base_electric_eff = Effectiveness::NORMAL_EFFECTIVE_MULTIPLIER
    base_electric_eff = 0 if user.has_active_ability?([:LIGHTNINGROD, :MOTORDRIVE, :VOLTABSORB])
    # Check all affected foe battlers for Normal moves, get their effectiveness
    # against the user and decide whether it is better or worse than Electric's
    # effectiveness
    normal_type_better = 0
    electric_type_better = 0
    ai.each_foe_battler(user.side) do |b, i|
      next if move.rough_priority(b) <= 0 && b.faster_than?(user)
      next if !b.has_damaging_move_of_type?(:NORMAL)
      # Normal's effectiveness
      eff = user.effectiveness_of_type_against_battler(:NORMAL, b)
      eff *= 1.5 if b.has_type?(:NORMAL)   # STAB
      # Electric's effectiveness
      elec_eff = user.effectiveness_of_type_against_battler(:ELECTRIC, b)
      elec_eff *= 1.5 if b.has_type?(:ELECTRIC)   # STAB
      elec_eff *= base_electric_eff
      # Compare the two
      if eff > elec_eff
        electric_type_better += 1
      elsif eff < elec_eff
        normal_type_better += 1
      end
    end
    if electric_type_better == 0 || electric_type_better < normal_type_better
      next (move.statusMove?) ? NewAI::MOVE_USELESS_SCORE : score
    end
    score += 10 * (electric_type_better - normal_type_better)
    next score
  }
)
