module Mobile_MG
  MOBILE_FILE = "MysteryGift.txt"
end

def write_mobile_mg
  $mobile_mystery_gifts = []
  if safeExists?(Mobile_MG::MOBILE_FILE)
    $mobile_mystery_gifts=IO.read(Mobile_MG::MOBILE_FILE)
    $mobile_mystery_gifts=pbMysteryGiftDecrypt($mobile_mystery_gifts)
    $mobile_mystery_gifts.push($mobile_mystery_gifts)
  end
end

def next_id_mobile
  for i in $mobile_mystery_gifts
    return i[0] if i.length>1
  end
  return 0
end

def mobile_mg_receive(id)
  $mg_received = [] if ($mg_received == nil || $mg_received == 0)
  index=-1
  for i in 0...$mobile_mystery_gifts.length
    next if $mg_received != nil && $mg_received.include?(id)
    if $mobile_mystery_gifts[i][0]==id && $mobile_mystery_gifts[i].length>1
      index=i
      break
    end
  end
  if index==-1
    pbMessage(_INTL("Couldn't find an unclaimed Mystery Gift with ID {1}.",id))
    return false
  end
  gift=$mobile_mystery_gifts[index]
  if gift[1]==0   # Pokémon
    gift[2].personalID = rand(2**16) | rand(2**16) << 16
    gift[2].calc_stats
    time=pbGetTimeNow
    gift[2].timeReceived=time.getgm.to_i
    gift[2].obtain_method = 4   # Fateful encounter
    gift[2].record_first_moves
    if $game_map
      gift[2].obtain_map=$game_map.map_id
      gift[2].obtain_level=gift[2].level
    else
      gift[2].obtain_map=0
      gift[2].obtain_level=gift[2].level
    end
    if pbAddPokemonSilent(gift[2])
      pbMessage(_INTL("\\me[Pkmn get]{1} received {2}!",$Trainer.name,gift[2].name))
      $mobile_mystery_gifts[index]=[id]
      $mg_received.push(id)
      return true
    end
  elsif gift[1]>0   # Item
    item=gift[2]
    qty=gift[1]
    if $PokemonBag.pbCanStore?(item,qty)
      $PokemonBag.pbStoreItem(item,qty)
      itm = GameData::Item.get(item)
      itemname=(qty>1) ? itm.name_plural : itm.name
      if item == :LEFTOVERS
        pbMessage(_INTL("\\me[Item get]You obtained some \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
      elsif itm.is_machine?   # TM or HM
        pbMessage(_INTL("\\me[Item get]You obtained \\c[1]{1} {2}\\c[0]!\\wtnp[30]",itemname,
           GameData::Move.get(itm.move).name))
      elsif qty>1
        pbMessage(_INTL("\\me[Item get]You obtained {1} \\c[1]{2}\\c[0]!\\wtnp[30]",qty,itemname))
      elsif itemname.starts_with_vowel?
        pbMessage(_INTL("\\me[Item get]You obtained an \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
      else
        pbMessage(_INTL("\\me[Item get]You obtained a \\c[1]{1}\\c[0]!\\wtnp[30]",itemname))
      end
      $mobile_mystery_gifts[index]=[id]
      $mg_received.push(id)
      return true
    end
  end
  return false
end
