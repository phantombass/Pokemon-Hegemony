#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0F1",
  proc { |score, move, user, target, ai, battle|
    next score if user.wild? || user.item
    next score if !target.item || target.battler.unlosableItem?(target.item)
    next score if user.battler.unlosableItem?(target.item)
    next score if target.effects[PBEffects::Substitute] > 0
    next score if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
    # User can steal the target's item; score it
    user_item_preference = user.wants_item?(target.item_id)
    user_no_item_preference = user.wants_item?(:NONE)
    user_diff = user_item_preference - user_no_item_preference
    user_diff = 0 if !user.item_active?
    target_item_preference = target.wants_item?(target.item_id)
    target_no_item_preference = target.wants_item?(:NONE)
    target_diff = target_no_item_preference - target_item_preference
    target_diff = 0 if !target.item_active?
    score += user_diff * 4
    score -= target_diff * 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0F3",
  proc { |move, user, target, ai, battle|
    next true if !user.item || user.battler.unlosableItem?(user.item)
    next true if target.item || target.battler.unlosableItem?(user.item)
    next false
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0F3",
  proc { |score, move, user, target, ai, battle|
    user_item_preference = user.wants_item?(user.item_id)
    user_no_item_preference = user.wants_item?(:NONE)
    user_diff = user_no_item_preference - user_item_preference
    user_diff = 0 if !user.item_active?
    target_item_preference = target.wants_item?(user.item_id)
    target_no_item_preference = target.wants_item?(:NONE)
    target_diff = target_item_preference - target_no_item_preference
    target_diff = 0 if !target.item_active?
    score += user_diff * 4
    score -= target_diff * 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0F2",
  proc { |move, user, target, ai, battle|
    next true if user.wild?
    next true if !user.item && !target.item
    next true if user.battler.unlosableItem?(user.item) || user.battler.unlosableItem?(target.item)
    next true if target.battler.unlosableItem?(target.item) || target.battler.unlosableItem?(user.item)
    next true if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
    next false
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0F2",
  proc { |score, move, user, target, ai, battle|
    user_new_item_preference = user.wants_item?(target.item_id)
    user_old_item_preference = user.wants_item?(user.item_id)
    user_diff = user_new_item_preference - user_old_item_preference
    user_diff = 0 if !user.item_active?
    target_new_item_preference = target.wants_item?(user.item_id)
    target_old_item_preference = target.wants_item?(target.item_id)
    target_diff = target_new_item_preference - target_old_item_preference
    target_diff = 0 if !target.item_active?
    score += user_diff * 4
    score -= target_diff * 4
    # Don't prefer if user used this move in the last round
    score -= 15 if user.battler.lastMoveUsed &&
                   GameData::Move.exists?(user.battler.lastMoveUsed) &&
                   GameData::Move.get(user.battler.lastMoveUsed).function_code == move.function_code
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0F6",
  proc { |move, user, ai, battle|
    next !user.battler.recycleItem || user.item
  }
)
AIHandlers::MoveEffectScore.add("0F6",
  proc { |score, move, user, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !user.item_active?
    item_preference = user.wants_item?(user.battler.recycleItem)
    no_item_preference = user.wants_item?(:NONE)
    score += (item_preference - no_item_preference) * 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveBasePower.add("0F0",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0F0",
  proc { |score, move, user, target, ai, battle|
    next score if user.wild?
    next score if !target.item || target.battler.unlosableItem?(target.item)
    next score if target.effects[PBEffects::Substitute] > 0
    next score if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
    next score if !target.item_active?
    # User can knock off the target's item; score it
    item_preference = target.wants_item?(target.item_id)
    no_item_preference = target.wants_item?(:NONE)
    score -= (no_item_preference - item_preference) * 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0F5",
  proc { |score, move, user, target, ai, battle|
    next score if !target.item || (!target.item.is_berry? &&
                  !(Settings::MECHANICS_GENERATION >= 6 && target.item.is_gem?))
    next score if user.battler.unlosableItem?(target.item)
    next score if target.effects[PBEffects::Substitute] > 0
    next score if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
    next score if !target.item_active?
    # User can incinerate the target's item; score it
    item_preference = target.wants_item?(target.item_id)
    no_item_preference = target.wants_item?(:NONE)
    score -= (no_item_preference - item_preference) * 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("201",
  proc { |move, user, target, ai, battle|
    next true if !target.item || target.battler.unlosableItem?(target.item) ||
                 target.effects[PBEffects::Substitute] > 0
    next true if target.has_active_ability?(:STICKYHOLD)
    next true if battle.corrosiveGas[target.index % 2][target.party_index]
    next false
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("201",
  proc { |score, move, user, target, ai, battle|
    item_preference = target.wants_item?(target.item_id)
    no_item_preference = target.wants_item?(:NONE)
    target_diff = no_item_preference - item_preference
    target_diff = 0 if !target.item_active?
    score += target_diff * 4
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("0F8",
  proc { |move, user, target, ai, battle|
    next target.effects[PBEffects::Embargo] > 0
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0F8",
  proc { |score, move, user, target, ai, battle|
    next NewAI::MOVE_USELESS_SCORE if !target.item || !target.item_active?
    # NOTE: We won't check if the item has an effect, because if a Pokémon is
    #       holding an item, it probably does.
    item_score = target.wants_item?(target.item_id)
    next NewAI::MOVE_USELESS_SCORE if item_score <= 0   # Item has no effect or is bad
    score += item_score * 2
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectScore.add("0F9",
  proc { |score, move, user, ai, battle|
    next if battle.field.effects[PBEffects::MagicRoom] == 1   # About to expire anyway
    any_held_items = false
    total_want = 0   # Positive means foes want their items more than allies do
    ai.each_battler do |b, i|
      next if !b.item
      # Skip b if its item is disabled
      if ai.trainer.medium_skill?
        # NOTE: We won't check if the item has an effect, because if a Pokémon
        #       is holding an item, it probably does.
        if battle.field.effects[PBEffects::MagicRoom] > 0
          # NOTE: Same as b.item_active? but ignoring the Magic Room part.
          next if b.effects[PBEffects::Embargo] > 0
          next if battle.corrosiveGas[b.index % 2][b.party_index]
          next if b.has_active_ability?(:KLUTZ)
        else
          next if !b.item_active?
        end
      end
      # Rate b's held item and add it to total_want
      any_held_items = true
      want = b.wants_item?(b.item_id)
      total_want += (b.opposes?(user)) ? want : -want
    end
    # Alter score
    next NewAI::MOVE_USELESS_SCORE if !any_held_items
    if battle.field.effects[PBEffects::MagicRoom] > 0
      next NewAI::MOVE_USELESS_SCORE if total_want >= 0
      score -= [total_want, -5].max * 4   # Will enable items, prefer if allies affected more
    else
      next NewAI::MOVE_USELESS_SCORE if total_want <= 0
      score += [total_want, 5].min * 4   # Will disable items, prefer if foes affected more
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("183",
  proc { |move, user, ai, battle|
    item = user.item
    next !item || !item.is_berry? || !user.item_active?
  }
)
AIHandlers::MoveEffectScore.add("183",
  proc { |score, move, user, ai, battle|
    # Score for raising the user's stat
    stat_raise_score = AIHandlers.apply_move_effect_score("02F",
       0, move, user, ai, battle)
    score += stat_raise_score if stat_raise_score != NewAI::MOVE_USELESS_SCORE
    # Score for the consumed berry's effect
    score += user.get_score_change_for_consuming_item(user.item_id, true)
    # Score for other results of consuming the berry
    if ai.trainer.medium_skill?
      # Prefer if user will heal itself with Cheek Pouch
      score += 8 if user.battler.canHeal? && user.hp < user.totalhp / 2 &&
                    user.has_active_ability?(:CHEEKPOUCH)
      # Prefer if target can recover the consumed berry
      score += 8 if user.has_active_ability?(:HARVEST) ||
                    user.has_move_with_function?("0F6")
      # Prefer if user couldn't normally consume the berry
      score += 5 if !user.battler.canConsumeBerry?
      # Prefer if user will become able to use Belch
      score += 5 if !user.battler.belched? && user.has_move_with_function?("158")
      # Prefer if user will benefit from not having an item
      score += 5 if user.has_active_ability?(:UNBURDEN)
    end
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureAgainstTargetCheck.add("184",
  proc { |move, user, target, ai, battle|
    next !target.item || !target.item.is_berry? || target.battler.semiInvulnerable?
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("184",
  proc { |score, move, user, target, ai, battle|
    # Score for the consumed berry's effect
    score_change = target.get_score_change_for_consuming_item(target.item_id, !target.opposes?(user))
    # Score for other results of consuming the berry
    if ai.trainer.medium_skill?
      # Prefer if target will heal itself with Cheek Pouch
      score_change += 8 if target.battler.canHeal? && target.hp < target.totalhp / 2 &&
                           target.has_active_ability?(:CHEEKPOUCH)
      # Prefer if target can recover the consumed berry
      score_change += 8 if target.has_active_ability?(:HARVEST) ||
                           target.has_move_with_function?("0F6")
      # Prefer if target couldn't normally consume the berry
      score_change += 5 if !target.battler.canConsumeBerry?
      # Prefer if target will become able to use Belch
      score_change += 5 if !target.battler.belched? && target.has_move_with_function?("158")
      # Prefer if target will benefit from not having an item
      score_change += 5 if target.has_active_ability?(:UNBURDEN)
    end
    score += (target.opposes?(user)) ? -score_change : score_change
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveEffectAgainstTargetScore.add("0F4",
  proc { |score, move, user, target, ai, battle|
    next score if !target.item || !target.item.is_berry?
    next score if user.battler.unlosableItem?(target.item)
    next score if target.effects[PBEffects::Substitute] > 0
    next score if target.has_active_ability?(:STICKYHOLD) && !battle.moldBreaker
    # Score the user gaining the item's effect
    score += user.get_score_change_for_consuming_item(target.item_id)
    # Score for other results of consuming the berry
    if ai.trainer.medium_skill?
      # Prefer if user will heal itself with Cheek Pouch
      score += 8 if user.battler.canHeal? && user.hp < user.totalhp / 2 &&
                    user.has_active_ability?(:CHEEKPOUCH)
      # Prefer if user will become able to use Belch
      score += 5 if !user.battler.belched? && user.has_move_with_function?("158")
      # Don't prefer if target will benefit from not having an item
      score -= 5 if target.has_active_ability?(:UNBURDEN)
    end
    # Score the target no longer having the item
    item_preference = target.wants_item?(target.item_id)
    no_item_preference = target.wants_item?(:NONE)
    score -= (no_item_preference - item_preference) * 3
    next score
  }
)

#===============================================================================
#
#===============================================================================
AIHandlers::MoveFailureCheck.add("0F7",
  proc { |move, user, ai, battle|
    item = user.item
    next true if !item || !user.item_active? || user.battler.unlosableItem?(item)
    next true if item.is_berry? && !user.battler.canConsumeBerry?
    next false
  }
)
AIHandlers::MoveBasePower.add("0F7",
  proc { |power, move, user, target, ai, battle|
    next move.move.pbBaseDamage(power, user.battler, target.battler)
  }
)
AIHandlers::MoveEffectAgainstTargetScore.add("0F7",
  proc { |score, move, user, target, ai, battle|
    case user.item_id
    when :POISONBARB, :TOXICORB
      score = AIHandlers.apply_move_effect_against_target_score("005",
         score, move, user, target, ai, battle)
    when :FLAMEORB
      score = AIHandlers.apply_move_effect_against_target_score("00A",
         score, move, user, target, ai, battle)
    when :LIGHTBALL
      score = AIHandlers.apply_move_effect_against_target_score("007",
         score, move, user, target, ai, battle)
    when :KINGSROCK, :RAZORFANG
      score = AIHandlers.apply_move_effect_against_target_score("00F",
         score, move, user, target, ai, battle)
    else
      score -= target.get_score_change_for_consuming_item(user.item_id)
    end
    # Score for other results of consuming the berry
    if ai.trainer.medium_skill?
      # Don't prefer if target will become able to use Belch
      score -= 5 if user.item.is_berry? && !target.battler.belched? &&
                    target.has_move_with_function?("158")
      # Prefer if user will benefit from not having an item
      score += 5 if user.has_active_ability?(:UNBURDEN)
    end
    # Prefer if the user doesn't want its held item/don't prefer if it wants to
    # keep its held item
    item_preference = user.wants_item?(user.item_id)
    no_item_preference = user.wants_item?(:NONE)
    score += (no_item_preference - item_preference) * 2
    next score
  }
)
