#================
#Multiple Forms
#================

MultipleForms.register(:CASTFORM,{
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0
  }
})



class PokeBattle_Battler
  def pbCheckFormOnWeatherChange
    return if fainted? || @effects[PBEffects::Transform]
    # Castform - Forecast
      if isSpecies?(:CASTFORM)
        if hasActiveAbility?(:FORECAST)
          newForm = 0
          case @battle.pbWeather
          when :Fog then                        newForm = 4
          when :Overcast then                   newForm = 5
          when :Starstorm then   			        	newForm = 6
          when :DClear then 				          	newForm = 6
          when :Eclipse then                    newForm = 7
          when :Windy then                      newForm = 8
          when :HeatLight then                  newForm = 9
          when :StrongWinds then                newForm = 10
          when :AcidRain then                   newForm = 11
          when :Sandstorm then                  newForm = 12
          when :Rainbow then                    newForm = 13
          when :DustDevil then                  newForm = 14
          when :DAshfall then                   newForm = 15
          when :VolcanicAsh then                newForm = 16
          when :Borealis then                   newForm = 17
          when :Humid then                      newForm = 18
          when :Sun, :HarshSun then             newForm = 1
          when :Rain, :Storm, :HeavyRain then   newForm = 2
          when :Hail, :Sleet then               newForm = 3
          end
          if @form!=newForm
            @battle.pbShowAbilitySplash(self,true)
            @battle.pbHideAbilitySplash(self)
            pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
          end
        else
          pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
    # Cherrim - Flower Gift
    if isSpecies?(:CHERRIM)
      if hasActiveAbility?(:FLOWERGIFT)
        newForm = 0
        case @battle.pbWeather
        when :Sun, :HarshSun then newForm = 1
        end
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
        end
      else
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
  end
end
