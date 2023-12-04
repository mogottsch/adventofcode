defmodule Scraper do
  @year 2023

  def get_day_html(day) do
    {:ok, response} = Tesla.get(build_client(), "/#{@year}/day/#{day}")

    if response.status == 200 do
      response.body
    else
      raise "Error getting day #{day} html"
    end
  end

  def get_day_input(day) do
    {:ok, response} = Tesla.get(build_client(), "/#{@year}/day/#{day}/input")
    if response.status == 200 do
      response.body
    else
      raise "Error getting day #{day} input"
    end
  end

  defp build_client() do
    cookie = Application.fetch_env!(:aoc, :cookie)

    middleware = [
      {Tesla.Middleware.BaseUrl, "https://adventofcode.com"},
      {Tesla.Middleware.Headers, [{"Cookie", "session=#{cookie}"}]}
    ]

    Tesla.client(middleware)
  end
end
