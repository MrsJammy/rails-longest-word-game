require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def game
    # @query = params[:query].to_i
    @grid = generate_grid(8)
  end

  def score
    @attempt = params[:attempt].upcase
    @grid = params[:grid].split('')
    @start_time = params[:start_time].to_i
    @end_time = Time.now.to_i
    # @elapsed_time = @end_time - @start_time
    # @valid = included?(@attempt.split(''), @grid) #
    # @score = compute_score(@attempt, @elapsed_time)
    @result = run_game(@attempt, @grid, @start_time, @end_time)
    # @result[:score] dans la vue
  end

private

  def generate_grid(query)
    Array.new(query) { ('A'..'Z').to_a[rand(26)] }
  end
end

def included?(attempt, grid)
  attempt = attempt.split('')
  attempt.all? { |letter| attempt.count(letter) <= grid.count(letter) }
end

def compute_score(attempt, elapsed_time)
  (elapsed_time > 60.0) ? 0 : attempt.size * (1.0 - elapsed_time / 60.0)
end

def score_and_message(attempt, translation, grid, time)
  if included?(attempt.upcase, grid)
    if translation
      score = compute_score(attempt, time)
      [score, "well done"]
    else
      [0, "not an english word"]
    end
  else
    [0, "not in the grid"]
  end
end

def run_game(attempt, grid, start_time, end_time)
  result = { time: end_time - start_time }

  result[:translation] = get_translation(attempt)
  result[:score], result[:message] = score_and_message(
    attempt, result[:translation], grid, result[:time])

  result
end

def get_translation(word)
  return "coucou"
  api_key = "4e201ea1-cd6d-4843-b233-a7542d912482"
  begin
    response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
    json = JSON.parse(response.read.to_s)
    if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
      return json['outputs'][0]['output']
    end
  rescue
    if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
      return word
    else
      return nil
    end
  end
end
