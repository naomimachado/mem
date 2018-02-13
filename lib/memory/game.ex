defmodule Memory.Game do

  def new do
    %{
      cards: listShuffle(),
      matches: 0,
      clicks: 0,
      flipped: 0,
      current: nil,
      prev: nil,
      ready: true,
    }
  end

  def client_view(game) do
    %{
      cards: game.cards,
      matches: game.matches,
      clicks: game.clicks,
      flipped: game.flipped,
      current: game.current,
      prev: game.prev,
      ready: game.ready,

    }
  end

  #case when cards match
  def updateBoard(game, card) do
      if game.flipped != 0 && Enum.at(game.cards, keyMap(game.cards, game.prev)).letter == card.letter do
        c1 = keyMap(game.cards, card.id)
        c2 = keyMap(game.cards, game.prev)
        updateCards = List.replace_at(game.cards, c1,
            %{letter: Enum.at(game.cards, c1).letter, id: Enum.at(game.cards, c1).id, flipped: Enum.at(game.cards, c1).flipped, matched: true})
          |> List.replace_at(c2,
               %{letter: Enum.at(game.cards, c2).letter, id: Enum.at(game.cards, c2).id, flipped: Enum.at(game.cards, c2).flipped, matched: true})
        Map.put(game, :cards, updateCards)
        |> Map.put(:matches, game.matches + 1)
      else
        game
      end
  end

  #case when cards do not match
  def resetBoard(game) do
    if game.flipped == 2 do
      c1 = keyMap(game.cards, game.current)
      c2 = keyMap(game.cards, game.prev)
      updateCards = List.replace_at(game.cards, c1,
          %{letter: Enum.at(game.cards, c1).letter, id: Enum.at(game.cards, c1).id, flipped: false, matched: Enum.at(game.cards, c1).matched})
        |> List.replace_at(c2,
             %{letter: Enum.at(game.cards, c2).letter, id: Enum.at(game.cards, c2).id, flipped: false, matched: Enum.at(game.cards, c2).matched})
      Map.put(game, :cards, updateCards)
      |> Map.put(:flipped, 0)
      |> Map.put(:ready, true)
    else
      game
    end
  end

  def clicked(game, card) do
    cickedCard = stringToAtom(card)
    if not cickedCard.matched && game.ready && (game.flipped == 0 || game.prev != cickedCard.id) do
      newGame = game
                |> Map.put(:current, cickedCard.id)
                |> Map.put(:cards, flipCard(game.cards, cickedCard))
      cickedCard = Enum.at(newGame.cards, keyMap(newGame.cards, cickedCard.id))
      updateBoard(newGame, cickedCard)
      |> Map.put(:prev, prevState(game, cickedCard))
      |> Map.put(:ready, game.flipped == 0)
      |> Map.put(:clicks, game.clicks + 1)
      |> Map.put(:flipped, game.flipped + 1)
    else
      game
    end
  end

  def flipCard(cards, card) do
      c = keyMap(cards, card.id)
      List.replace_at(cards, c, %{letter: Enum.at(cards, c).letter, id: Enum.at(cards, c).id, flipped: true, matched: Enum.at(cards, c).matched})
  end

  def prevState(game, card) do
      if(game.flipped == 0, do: card.id, else: game.prev)
  end

  def listShuffle do
    list = ~w( A B C D E F G H A B C D E F G H)
    list1 = Enum.shuffle(list)
    hold = []
    id = 1
    cardList1 = cardList(list1, hold, id)
    cardList1
  end

  def cardList(list1, hold, id) do
    if MyList.empty? list1 do
      hold
    else
      map = %{letter: hd(list1), id: id, flipped: false, matched: false}
      hold = List.insert_at(hold, -1, map)
      list2 = tl(list1)
      cardList(list2, hold, id+1)
    end
  end

  def stringToAtom(m) do
    for {key, val} <- m, into: %{}, do: {String.to_atom(key), val}
  end

  def keyMap(cards, id) do
    Enum.find_index(cards, fn(x) -> x.id == id end)
  end

end

defmodule MyList do
  def empty?([]), do: true
  def empty?(list) when is_list(list) do
    false
  end
end
