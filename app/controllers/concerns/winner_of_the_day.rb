module WinnerOfTheDay
  def winner(*args)
    return unless can_reply?
    reply_text = t('.winner.no_one')
    case args.first
    when '—enable', '--enable'
      if args.second.present?
        @chat.update(winner: args[1..-1].join(' '))
      else
        @chat.update(winner: t('.winner.default'))
      end
      reply_text = ok
    when '—disable', '--disable'
      @chat.update(winner: nil)
      reply_text = ok
    when '—me', '--me'
      top = Winner.stats(@chat.id, from.id)
      if top[:dates].present?
        reply_text = t('.winner.user.top', name: @chat.winner, dates: top[:dates].join("\n"), count: top[:count])
      else
        reply_text = t('.winner.user.none').sample
      end
    when '—current', '--current'
      current_stats = Winner.current_stats(@chat.id).sort_by { |key, value| value }.reverse[0..9].to_h
      names = Chat.names(current_stats.keys)
      stats = current_stats.map {|user, count| [names[user] || fetch_user_info(@chat.telegram_id, user) || t('.winner.user.unknown'), count]}
      top = stats.each_with_index.map{|s,i| t('.winner.current_top_line_html', user: s.first, count: s.second, position: i + 1) }.join("\n")
      reply_text = t('.winner.current_html', top: top)
    else
      gambled = Winner.gambled?(@chat.id)
      winner_id = Winner.gamble(@chat.id)
      if winner_id.present?
        stats = Winner.stats(@chat.id)
        names = Chat.names(stats.keys)
        user_chat = Chat.find_by(telegram_id: winner_id)
        user = gambled ? user_chat.to_s : user_chat.to_link
        stats = stats.map {|user, count| [names[user] || fetch_user_info(@chat.telegram_id, user) || t('.winner.user.unknown'), count]}
        top = stats.each_with_index.map{|s,i| t('.winner.top_line_html', user: s.first, count: s.second, position: i + 1) }.join("\n")
        reply_text = t('.winner.day_html', name: @chat.winner, user: user, top: top)
      end
    end
    respond_with :message, text: reply_text, parse_mode: :html
  end
end
