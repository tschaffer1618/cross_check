module LeagueStatables

  def count_of_teams
    @teams.count
  end

  def game_teams_by_team(team_id)
    @game_teams.values.find_all { |value| value.team_id == team_id }
  end

  def total_goals(team_id)
    game_teams_by_team(team_id).sum { |game_team| game_team.goals }
  end

  def average_goals_per_game_team(team_id)
    (total_goals(team_id) / game_teams_by_team(team_id).size.to_f).round(2)
  end

  def best_offense
    @teams.values.max_by { |value| average_goals_per_game_team(value.team_id) }
      .team_name
  end

  def worst_offense
    @teams.values.min_by { |value| average_goals_per_game_team(value.team_id) }
      .team_name
  end

  def games_by_team(team_id)
    @games.values.find_all do |value|
      value.away_team_id == team_id || value.home_team_id == team_id
    end
  end

  def home_games(team_id)
    games_by_team(team_id).find_all { |game| game.home_team_id == team_id }
  end

  def away_games(team_id)
    games_by_team(team_id).find_all { |game| game.away_team_id == team_id }
  end

  def home_goals_allowed(team_id)
    home_games(team_id).sum { |game| game.away_goals }
  end

  def away_goals_allowed(team_id)
    away_games(team_id).sum { |game| game.home_goals }
  end

  def total_goals_allowed(team_id)
    home_goals_allowed(team_id) + away_goals_allowed(team_id)
  end

  def average_goals_allowed_per_game(team_id)
    (total_goals_allowed(team_id) / games_by_team(team_id).size.to_f ).round(2)
  end

  def best_defense
    @teams.values.min_by { |value| average_goals_allowed_per_game(value.team_id) }
      .team_name
  end

  def worst_defense
    @teams.values.max_by { |value| average_goals_allowed_per_game(value.team_id) }
      .team_name
  end

  def total_home_goals(team_id)
    home_games(team_id).sum { |game| game.home_goals }
  end

  def total_away_goals(team_id)
    away_games(team_id).sum { |game| game.away_goals }
  end

  def average_home_goals(team_id)
    (total_home_goals(team_id) / home_games(team_id).size.to_f ).round(2)
  end

  def average_away_goals(team_id)
    (total_away_goals(team_id) / away_games(team_id).size.to_f ).round(2)
  end

  def highest_scoring_visitor
    @teams.values.max_by { |value| average_away_goals(value.team_id) }
      .team_name
  end

  def highest_scoring_home_team
    @teams.values.max_by { |value| average_home_goals(value.team_id) }
      .team_name
  end

  def lowest_scoring_visitor
    @teams.values.min_by { |value| average_away_goals(value.team_id) }
      .team_name
  end

  def lowest_scoring_home_team
    @teams.values.min_by { |value| average_home_goals(value.team_id) }
      .team_name
  end

  def winningest_team
    num_of_wins_data = Hash.new(0)
    @game_teams.values.map do |team|
      if team.won?
        num_of_wins_data[team.team_id]+= 1
      end
    end
    id_avg = Hash.new
    num_of_wins_data.each do |team_id, wins|
      id_avg[team_id] = (wins.to_f / games_by_team(team_id).count)
    end
    winningest = id_avg.max_by {|team_id,percentage| percentage}
    @teams[winningest.first].team_name
  end



end
