class PokerThree
  OPEN_RESULT = { "win"=>1, "draw"=>0, "lose"=>-1}
  HAND_STRONGTH_LIST = { "straight_flash"=>0, "three_of_a_kind"=>1, "straight"=>2, "flash"=>3, "pair"=>4, "highcard"=>5 }
  
  def open(player1_hand, player2_hand)
    player1_hand_strongth = hand_strongth(player1_hand)
    player2_hand_strongth = hand_strongth(player2_hand)
    if (player1_hand_strongth < player2_hand_strongth)
      OPEN_RESULT["win"]
    elsif (player1_hand_strongth == player2_hand_strongth)
      check_same_hand_strongth_conditions(player1_hand, player1_hand_strongth, player2_hand, player2_hand_strongth)
    else
      OPEN_RESULT["lose"]
    end
  end
  

  def check_same_hand_strongth_conditions(player1, player1_hand, player2, player2_hand)
    if (player1_hand == HAND_STRONGTH_LIST["straight_flash"] || player1_hand == HAND_STRONGTH_LIST["straight"])
      check_straight_hand(player1.hand_rank, player2.hand_rank)
    elsif (player1_hand == HAND_STRONGTH_LIST["three_of_a_kind"])
      check_three_of_a_kind(player1.hand_rank[0], player2.hand_rank[0])
    elsif (player1_hand == HAND_STRONGTH_LIST["flash"] || player1_hand == HAND_STRONGTH_LIST["highcard"])
      check_flash_high_hand(player1.hand_rank, player2.hand_rank)
    elsif (player1_hand == HAND_STRONGTH_LIST["pair"])
      check_pair_hand(player1.hand_rank, player2.hand_rank)
    end
  end

  def check_straight_hand(player1_hand, player2_hand)
    player1_strongth = straight_strongth(player1_hand)
    player2_strongth = straight_strongth(player2_hand)
    if (player1_strongth > player2_strongth)
      OPEN_RESULT["win"]
    elsif (player1_strongth < player2_strongth)
      OPEN_RESULT["lose"]
    elsif (player1_strongth == player2_strongth)
      OPEN_RESULT["draw"]  
    end
  end

  def straight_strongth(player_hand)
    if ((player_hand.min - player_hand.max).abs == 12 and player_hand.include?(1))
      return 14
    else
      return player_hand.max
    end
  end

  def check_three_of_a_kind(player1_hand, player2_hand)
    if (player1_hand == player2_hand)
      OPEN_RESULT["draw"]
    elsif (player1_hand == 1)
      OPEN_RESULT["win"]
    elsif (player2_hand == 1)
      OPEN_RESULT["lose"]
    elsif (player1_hand > player2_hand)
      OPEN_RESULT["win"]
    elsif (player1_hand < player1_hand)
      OPEN_RESULT["lose"]
    end
  end

  def check_flash_high_hand(player1_hand, player2_hand)     # rankですよね？
    # a.dupでもディープコピーできる
    player1_hand_temp = Marshal.load(Marshal.dump(player1_hand))
    player2_hand_temp = Marshal.load(Marshal.dump(player2_hand))
    player1_strongth, player1_rank = get_rank_strongth(player1_hand_temp)
    player2_strongth, player2_rank = get_rank_strongth(player2_hand_temp)
    if (player1_strongth > player2_strongth)
      OPEN_RESULT["win"]
    elsif (player1_strongth < player2_strongth)
      OPEN_RESULT["lose"]
    elsif (player1_strongth == player2_strongth)
      if (player1_hand_temp.length == 1)
        OPEN_RESULT["draw"]
      else
        player1_hand_temp.delete(player1_rank)
        player2_hand_temp.delete(player2_rank)
        check_flash_high_hand(player1_hand_temp, player2_hand_temp)
      end
    end
  end

  def get_rank_strongth(player_hand)
    if (player_hand.min == 1)
      return 14,1
    else
      return player_hand.max, player_hand.max
    end
  end

  def check_pair_hand(player1_cards, player2_cards)
    player1_pair_rank = player1_cards.group_by{|i| i}.reject{|k,v| v.one?}.keys[0]
    player2_pair_rank = player2_cards.group_by{|i| i}.reject{|k,v| v.one?}.keys[0]
    if player1_pair_rank > player2_pair_rank
      return OPEN_RESULT["win"]
    elsif player1_pair_rank < player2_pair_rank
      return OPEN_RESULT["lose"]
    end
    if ((player1_cards & player2_cards).length != 2)
      player1_cards.delete((player1_cards & player2_cards)[0])
      player2_cards.delete((player2_cards & player2_cards)[0])
      check_flash_high_hand(player1_cards, player2_cards)
    else
      OPEN_RESULT["draw"]
    end
  end

  def hand_strongth(hand_cards)
    if (hand_cards.straight_flash?)
      return HAND_STRONGTH_LIST["straight_flash"]
    elsif (hand_cards.three_of_a_kind?)
      return HAND_STRONGTH_LIST["three_of_a_kind"]
    elsif (hand_cards.straight?)
      return HAND_STRONGTH_LIST["straight"]
    elsif (hand_cards.flash?)
      return HAND_STRONGTH_LIST["flash"]
    elsif (hand_cards.pair?)
      return HAND_STRONGTH_LIST["pair"]
    elsif (hand_cards.highcard?)
      return HAND_STRONGTH_LIST["highcard"]
    end
  end
end


# cards_ranks