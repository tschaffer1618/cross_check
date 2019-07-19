module SeasonStatables

  def all_seasons #returns array of season values
    @all_seasons ||= @games.values.map { |game| game.season }.uniq
  end

  def all_teams #returns array of team ids
    @all_teams ||= @teams.values.map { |team| team.team_id }.uniq
  end

  def all_head_coaches #returns array of head coaches
    @all_head_coaches ||= @game_teams.values.map { |game_team| game_team.head_coach }.uniq
  end

  def all_season_games(season)
    @games.values.find_all { |value| value.season == season }
  end

  def game_teams_by_season(season)
    game_ids = all_season_games(season).map { |game| game.game_id }
    @game_teams.values.find_all { |value| game_ids.include?(value.game_id) }
  end

  def game_teams_hash_by_team(season) #returns hash with season key and all game_teams from that season as values
    hash = {}
    all_teams.each do |team_id|
      hash[team_id] = []
      hash[team_id] << game_teams_by_season(season)
      hash[team_id].flatten!
    end
    hash
  end

  def hits_by_team(season)
    hash = Hash.new(0)
    game_teams_hash_by_team(season).each do |team_id, array_of_game_teams|
      array_of_game_teams.each do |game_team|
        hash[team_id] += game_team.hits if team_id == game_team.team_id
      end
    end
    hash
  end

  def most_hits(season)
    most_hits_stat = hits_by_team(season).max_by { |k, v| v }
    @teams[most_hits_stat[0]].team_name
  end

  def fewest_hits(season)
    most_hits_stat = hits_by_team(season).min_by { |k, v| v }
    @teams[most_hits_stat[0]].team_name
  end

  #break

  def regular_season_games_by_team(team_id, season)
    @games.values.find_all do |value|
      value.season == season &&
      value.type == "R" &&
      (value.away_team_id == team_id || value.home_team_id == team_id)
    end
  end

  def postseason_games_by_team(team_id, season)
    @games.values.find_all do |value|
      value.season == season &&
      value.type == "P" &&
      (value.away_team_id == team_id || value.home_team_id == team_id)
    end
  end

  def season_games_by_team(team_id, season)
    @games.values.find_all do |value|
      value.season == season &&
      (value.away_team_id == team_id || value.home_team_id == team_id)
    end
  end

  def regular_season_wins_by_team(team_id, season)
    regular_season_games_by_team(team_id, season).find_all do |game|
      if game.away_team_id == team_id
        game.away_goals > game.home_goals
      elsif game.home_team_id == team_id
        game.home_goals > game.away_goals
      end
    end
  end

  def postseason_wins_by_team(team_id, season)
    postseason_games_by_team(team_id, season).find_all do |game|
      if game.away_team_id == team_id
        game.away_goals > game.home_goals
      elsif game.home_team_id == team_id
        game.home_goals > game.away_goals
      end
    end
  end

  def season_wins_by_team(team_id, season)
    season_games_by_team(team_id, season).find_all do |game|
      if game.away_team_id == team_id
        game.away_goals > game.home_goals
      elsif game.home_team_id == team_id
        game.home_goals > game.away_goals
      end
    end
  end

  def regular_season_win_percentage(team_id, season)
    (regular_season_wins_by_team(team_id, season).size / regular_season_games_by_team(team_id, season).size.to_f).round(2)
  end

  def postseason_win_percentage(team_id, season)
    if postseason_games_by_team(team_id, season) == []
      regular_season_win_percentage(team_id, season)
    else
      (postseason_wins_by_team(team_id, season).size / postseason_games_by_team(team_id, season).size.to_f).round(2)
    end
  end

  def season_win_percentage(team_id, season)
    (season_wins_by_team(team_id, season).size / season_games_by_team(team_id, season).size.to_f).round(2)
  end

  def all_season_games(season)
    @games.values.find_all { |value| value.season == season }
  end

  def postseason_games(season)
    @games.values.find_all { |value| value.season == season && value.type == "P" }
  end

  def teams_that_made_the_postseason(season)
    home = postseason_games(season).map { |game| game.home_team_id }
    away = postseason_games(season).map { |game| game.away_team_id }
    all_ids = home + away
    all_ids.uniq!
    all_ids.map { |team_id| @teams[team_id] }
  end

  def teams_in_a_season(season)
    home = all_season_games(season).map { |game| game.home_team_id }
    away = all_season_games(season).map { |game| game.away_team_id }
    all_ids = home + away
    all_ids.uniq!
    all_ids.map { |team_id| @teams[team_id] }
  end

  def biggest_bust(season)
    teams_that_made_the_postseason(season).max_by do |value|
      regular_season_win_percentage(value.team_id, season) -
      postseason_win_percentage(value.team_id, season)
    end.team_name
  end

  def biggest_surprise(season)
    teams_that_made_the_postseason(season).max_by do |value|
      postseason_win_percentage(value.team_id, season) -
      regular_season_win_percentage(value.team_id, season)
    end.team_name
  end
  def total_shots_by_season_by_team(team_id, season)
    game_teams_by_season_by_team(team_id, season).sum { |game_team| game_team.shots }
  end

  def total_goals_by_season_by_team(team_id, season)
    game_teams_by_season_by_team(team_id, season).sum { |game_team| game_team.goals }
  end

  def total_hits_by_season_by_team(team_id, season)
    game_teams_by_season_by_team(team_id, season).sum { |game_team| game_team.hits }
  end

  def most_accurate_team(season)
    teams_in_a_season(season).max_by do |value|
      total_goals_by_season_by_team(value.team_id, season) /
      total_shots_by_season_by_team(value.team_id, season).to_f
    end.team_name
  end

  def least_accurate_team(season)
    teams_in_a_season(season).min_by do |value|
      total_goals_by_season_by_team(value.team_id, season) /
      total_shots_by_season_by_team(value.team_id, season).to_f
    end.team_name
  end

  def game_teams_by_season_by_team(team_id, season)
    game_teams_by_season(season).find_all { |game_team| game_team.team_id == team_id }
  end

  def power_play_goal_percentage(season)
    power_play_goals = game_teams_by_season(season).sum { |game_team| game_team.power_play_goals }
    total_goals = game_teams_by_season(season).sum { |game_team| game_team.goals }
    (power_play_goals / total_goals.to_f ).round(2)
  end 

  # power_play_goal_percentage	Percentage of goals that were power play goals for the season (rounded to the nearest 100th)	Float


end
