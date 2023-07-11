Essentials::ERROR_TEXT += "[Phantombass AI v3.0]\r\n"
#===============================================================================
#
#===============================================================================
class PokeBattle_Battle
  attr_reader :battleAI

  alias ai_initialize initialize
  def initialize(*args)
    ai_initialize(*args)
    @battleAI = NewAI.new(self)
    PBDebug.log_ai("AI initialized")
  end
  def allOtherSideBattlers(idxBattler = 0)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    return @battlers.select { |b| b && !b.fainted? && b.opposes?(idxBattler) }
  end
  def allBattlers
    return @battlers.select { |b| b && !b.fainted? }
  end
  def pbCanSwitchIn?(idxBattler, idxParty, partyScene = nil)
    return true if idxParty < 0
    party = pbParty(idxBattler)
    return false if idxParty >= party.length
    return false if !party[idxParty]
    if party[idxParty].egg?
      partyScene&.pbDisplay(_INTL("An Egg can't battle!"))
      return false
    end
    if !pbIsOwner?(idxBattler, idxParty)
      if partyScene
        owner = pbGetOwnerFromPartyIndex(idxBattler, idxParty)
        partyScene.pbDisplay(_INTL("You can't switch {1}'s Pokémon with one of yours!", owner.name))
      end
      return false
    end
    if party[idxParty].fainted?
      partyScene&.pbDisplay(_INTL("{1} has no energy left to battle!", party[idxParty].name))
      return false
    end
    if pbFindBattler(idxParty, idxBattler)
      partyScene&.pbDisplay(_INTL("{1} is already in battle!", party[idxParty].name))
      return false
    end
    return true
  end

  # Check whether the currently active Pokémon (at battler index idxBattler) can
  # switch out.
  def pbCanSwitchOut?(idxBattler, partyScene = nil)
    battler = @battlers[idxBattler]
    return true if battler.fainted?
    # Ability/item effects that allow switching no matter what
    if battler.abilityActive? && BattleHandlers.triggerCertainSwitchingUserAbility(battler.ability, battler, self)
      return true
    end
    if battler.itemActive? && BattleHandlers.triggerCertainSwitchingUserItem(battler.item, battler, self)
      return true
    end
    # Other certain switching effects
    return true if Settings::MORE_TYPE_EFFECTS && battler.pbHasType?(:GHOST)
    # Other certain trapping effects
    if battler.trappedInBattle?
      partyScene&.pbDisplay(_INTL("{1} can't be switched out!", battler.pbThis))
      return false
    end
    # Trapping abilities/items
    allOtherSideBattlers(idxBattler).each do |b|
      next if !b.abilityActive?
      if BattleHandlers.triggerTrappingTargetAbility(b.ability, battler, b, self)
        partyScene&.pbDisplay(_INTL("{1}'s {2} prevents switching!", b.pbThis, b.abilityName))
        return false
      end
    end
    allOtherSideBattlers(idxBattler).each do |b|
      next if !b.itemActive?
      if BattleHandlers.triggerTrappingTargetItem(b.item, battler, b, self)
        partyScene&.pbDisplay(_INTL("{1}'s {2} prevents switching!", b.pbThis, b.itemName))
        return false
      end
    end
    return true
  end
end
class PokeBattle_PoisonMove
  attr_reader :toxic
end
=begin
class Array
  def sum
    n = 0
    self.each { |e| n += e }
    n
  end
end
=end
class NewAI
  attr_reader :battle
  attr_reader :trainer
  attr_reader :battlers
  attr_reader :user, :target, :move

  def initialize(battle)
    @battle = battle
    $spam_block_flags = {
      :haze_flag => [], #A pokemon has haze, so the AI registers what mon knows Haze until it is gone
      :switches => [],
      :moves => [],
      :flags_set => [],
      :two_mon_flag => false, # Player switches between the same 2 mons 
      :triple_switch_flag => false, # Player switches 3 times in a row
      :no_attacking_flag => [], #Target has no attacking moves
      :double_recover_flag => [], # Target uses a recovery move twice in a row
      :choiced_flag => [], #Target is choice-locked
      :same_move_flag => false, # Target uses same move 3 times in a row
      :initiative_flag => false, # Target uses an initiative move 3 times in a row
      :double_intimidate_flag => false, # Target pivots between 2 Intimidators
      :no_priority_flag => []
    }
    $learned_flags = {
      :setup_fodder => [],
      :has_setup => [],
      :should_taunt => [],
      :move => nil
    }
  end

  def create_ai_objects
    # Initialize AI trainers
    @trainers = [[], []]
    @battle.player.each_with_index do |trainer, i|
      @trainers[0][i] = AITrainer.new(self, 0, i, trainer)
    end
    if @battle.wildBattle?
      @trainers[1][0] = AITrainer.new(self, 1, 0, nil)
    else
      @battle.opponent.each_with_index do |trainer, i|
        @trainers[1][i] = AITrainer.new(self, 1, i, trainer)
      end
    end
    # Initialize AI battlers
    @battlers = []
    # Initialize AI move object
    @move = AIMove.new(self)
  end

  # Set some class variables for the Pokémon whose action is being chosen
  def set_up(idxBattler)
    # Find the AI trainer choosing the action
    @battle.battlers.each_with_index do |battler, i|
      @battlers[i] = AIBattler.new(self, i) if battler
    end
    opposes = @battle.opposes?(idxBattler)
    trainer_index = @battle.pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @trainer = @trainers[(opposes) ? 1 : 0][trainer_index]
    # Find the AI battler for which the action is being chosen
    @user = @battlers[idxBattler]
    @battlers.each { |b| b.refresh_battler if b }
  end

  # Choose an action.
  def pbDefaultChooseEnemyCommand(idxBattler)
    set_up(idxBattler)
    ret = false
    PBDebug.logonerr { ret = pbChooseToSwitchOut }
    if ret
      PBDebug.log("")
      return
    end
    ret = false
    PBDebug.logonerr { ret = pbChooseToUseItem }
    if ret
      PBDebug.log("")
      return
    end
    if @battle.pbAutoFightMenu(idxBattler)
      PBDebug.log("")
      return
    end
    @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?
    choices = pbGetMoveScores
    pbChooseMove(choices)
    PBDebug.log("")
  end

  # Choose a replacement Pokémon (called directly from @battle, not part of
  # action choosing). Must return the party index of a replacement Pokémon if
  # possible.
  def pbDefaultChooseNewEnemy(idxBattler)
    set_up(idxBattler)
    return choose_best_replacement_pokemon(idxBattler, true)
  end
end

class HandlerHash3
  def initialize
    @hash = {}
  end

  def [](id)
    return @hash[id] if id && @hash[id]
    return nil
  end

  def add(id, handler = nil, &handlerBlock)
    if ![Proc, Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "#{self.class.name} for #{id.inspect} has no valid handler (#{handler.inspect} was given)"
    end
    @hash[id] = handler || handlerBlock if id && !id.empty?
  end

  def copy(src, *dests)
    handler = self[src]
    return if !handler
    dests.each { |dest| add(dest, handler) }
  end

  def remove(key)
    @hash.delete(key)
  end

  def clear
    @hash.clear
  end

  def each
    @hash.each_pair { |key, value| yield key, value }
  end

  def keys
    return @hash.keys.clone
  end

  # NOTE: The call does not pass id as a parameter to the proc/block.
  def trigger(id, *args)
    handler = self[id]
    return handler&.call(*args)
  end
end
class HandlerHashSymbol
  def initialize
    @hash    = {}
    @add_ifs = {}
  end

  def [](sym)
    sym = sym.id if !sym.is_a?(Symbol) && sym.respond_to?("id")
    return @hash[sym] if sym && @hash[sym]
    @add_ifs.each_value do |add_if|
      return add_if[1] if add_if[0].call(sym)
    end
    return nil
  end

  def add(sym, handler = nil, &handlerBlock)
    if ![Proc, Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "#{self.class.name} for #{sym.inspect} has no valid handler (#{handler.inspect} was given)"
    end
    @hash[sym] = handler || handlerBlock if sym
  end

  def addIf(sym, conditionProc, handler = nil, &handlerBlock)
    if ![Proc, Hash].include?(handler.class) && !block_given?
      raise ArgumentError, "addIf call for #{sym} in #{self.class.name} has no valid handler (#{handler.inspect} was given)"
    end
    @add_ifs[sym] = [conditionProc, handler || handlerBlock]
  end

  def copy(src, *dests)
    handler = self[src]
    return if !handler
    dests.each { |dest| add(dest, handler) }
  end

  def remove(key)
    @hash.delete(key)
  end

  def clear
    @hash.clear
    @add_ifs.clear
  end

  def trigger(sym, *args)
    sym = sym.id if !sym.is_a?(Symbol) && sym.respond_to?("id")
    handler = self[sym]
    return handler&.call(sym, *args)
  end
end
#===============================================================================
#
#===============================================================================
module AIHandlers
  MoveFailureCheck              = HandlerHash3.new
  MoveFailureAgainstTargetCheck = HandlerHash3.new
  MoveEffectScore               = HandlerHash3.new
  MoveEffectAgainstTargetScore  = HandlerHash3.new
  MoveBasePower                 = HandlerHash3.new
  GeneralMoveScore              = HandlerHash3.new
  GeneralMoveAgainstTargetScore = HandlerHash3.new
  ShouldSwitch                  = HandlerHash3.new
  ShouldNotSwitch               = HandlerHash3.new
  AbilityRanking                = HandlerHashSymbol.new
  ItemRanking                   = HandlerHashSymbol.new
  SpamBlockFlag                 = HandlerHash3.new

  def self.move_will_fail?(function_code, *args)
    return MoveFailureCheck.trigger(function_code, *args) || false
  end

  def self.move_will_fail_against_target?(function_code, *args)
    return MoveFailureAgainstTargetCheck.trigger(function_code, *args) || false
  end

  def self.apply_move_effect_score(function_code, score, *args)
    ret = MoveEffectScore.trigger(function_code, score, *args)
    return (ret.nil?) ? score : ret
  end

  def self.apply_move_effect_against_target_score(function_code, score, *args)
    ret = MoveEffectAgainstTargetScore.trigger(function_code, score, *args)
    return (ret.nil?) ? score : ret
  end

  def self.get_base_power(function_code, power, *args)
    ret = MoveBasePower.trigger(function_code, power, *args)
    return (ret.nil?) ? power : ret
  end

  def self.apply_general_move_score_modifiers(score, *args)
    GeneralMoveScore.each do |id, score_proc|
      new_score = score_proc.call(score, *args)
      score = new_score if new_score
    end
    return score
  end

  def self.apply_general_move_against_target_score_modifiers(score, *args)
    GeneralMoveAgainstTargetScore.each do |id, score_proc|
      new_score = score_proc.call(score, *args)
      score = new_score if new_score
    end
    return score
  end

  def self.should_switch?(*args)
    ret = false
    ShouldSwitch.each do |id, switch_proc|
      ret ||= switch_proc.call(*args)
      break if ret
    end
    return ret
  end

  def self.should_not_switch?(*args)
    ret = false
    ShouldNotSwitch.each do |id, switch_proc|
      ret ||= switch_proc.call(*args)
      break if ret
    end
    return ret
  end

  def self.spam_block_activated?(*args)
    ret = false
    SpamBlockFlag.each do |id, spam_proc|
      ret ||= spam_proc.call(*args)
      break if ret
    end
    return ret
  end

  def self.modify_ability_ranking(ability, score, *args)
    ret = AbilityRanking.trigger(ability, score, *args)
    return (ret.nil?) ? score : ret
  end

  def self.modify_item_ranking(item, score, *args)
    ret = ItemRanking.trigger(item, score, *args)
    return (ret.nil?) ? score : ret
  end
end
