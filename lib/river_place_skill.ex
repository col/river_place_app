defmodule RiverPlaceSkill do
  use Alexa.Skill, app_id: Application.get_env(:river_place_app, :app_id)
  alias RiverPlace.TimeSlot
  alias RiverPlaceSkill.Booking
  alias Alexa.{Request, Response}
  alias Oauth2Server.{Repo, OauthAccessToken}
  use Timex

  @river_place_api Application.get_env(:river_place_app, :river_place_api)

  def login(%{session: %{user: %{accessToken: nil}}}) do
    {:error, "invalid token"}
  end

  def login(request) do
    case Repo.get_by(OauthAccessToken, token: Request.access_token(request)) do
      nil ->
        {:error, "invalid token"}
      oauth_access_token ->
        user = RiverPlaceApp.Repo.get(RiverPlaceApp.User, oauth_access_token.user_id)
        case @river_place_api.logged_in? do
          true -> {:ok, user}
          false ->
            IO.puts "Logging into riverplace.sg with #{user.rp_username} / #{user.rp_password}"
            IO.puts "Using module #{@river_place_api}"
            case @river_place_api.login(user.rp_username, user.rp_password) do
              :ok -> {:ok, user}
              :error -> {:error, "Login failed. Please check your username and password"}
            end
        end
    end
  end

  def handle_auth_failure(response) do
    response
      |> say("Please link to your River Place account using the Alexa app")
      |> card("LinkAccount", "Link Account", "You can link your River Place account here")
      |> should_end_session(true)
  end

  def handle_launch(request, response) do
    case login(request) do
      {:ok, _} ->
        response
          |> say("Ok. When would you like to play?")
          |> should_end_session(false)
      {:error, msg} ->
        IO.puts "Login Failed: #{msg}"
        handle_auth_failure(response)
    end
  end

  def handle_intent("Logout", _, response) do
    @river_place_api.logout
    response
      |> say("Good bye")
      |> should_end_session(true)
  end

  def handle_intent("AMAZON.HelpIntent", _, response) do
    response
      |> say("Ask me to book you a tennis court and tell me the which day and time you'd like to play.")
      |> should_end_session(false)
  end

  def handle_intent("AMAZON.StopIntent", _, response) do
    response |> say("") |> should_end_session(true)
  end

  def handle_intent("AMAZON.CancelIntent", _, response) do
    response |> say("") |> should_end_session(true)
  end

  def handle_intent("AMAZON.YesIntent", request, response) do
    Response.attribute(response, "question")
    |> handle_yes(request, response)
  end

  defp handle_yes("ChooseDifferentTime?", _, response) do
    response
      |> say("Ok. When would you like to play?")
      |> should_end_session(false)
  end

  defp handle_yes(_, _, response) do
    response
      |> say("Ok. When would you like to play?")
      |> should_end_session(false)
  end

  def handle_intent("AMAZON.NoIntent", request, response) do
    Response.attribute(response, "question")
    |> handle_no(request, response)
  end

  defp handle_no("ChooseDifferentTime?", _, response) do
    response |> say("") |> should_end_session(true)
  end

  defp handle_no(_, _, response) do
    response |> say("") |> should_end_session(true)
  end

  def handle_intent("CreateBooking", request, response) do
    case login(request) do
      {:ok, _} ->
        booking(request)
        |> validate_booking()
        |> create_booking(response)
      {:error, msg} ->
        IO.puts "Login Failed: #{msg}"
        handle_auth_failure(response)
    end
  end

  defp create_booking(%{date: nil, time: nil}, response) do
    response
      |> say("Ok. When would you like to play?")
      |> should_end_session(false)
  end

  defp create_booking(%{date: date, time: nil}, response) do
    response
      |> say("What time would you like to play?")
      |> Response.set_attribute("date", date)
      |> should_end_session(false)
  end

  defp create_booking(%{date: nil, time: time}, response) do
    response
      |> say("What day would you like to play?")
      |> Response.set_attribute("time", time)
      |> should_end_session(false)
  end

  defp create_booking(booking = %{time: time, available: []}, response) do
    response
      |> say("Sorry. #{time} is not available. Would you like to choose a different time?")
      |> reprompt("Would you like to choose a different time?")
      |> Response.set_attribute("date", booking.date)
      |> Response.set_attribute("time", booking.time)
      |> Response.set_attribute("question", "ChooseDifferentTime?")
      |> should_end_session(false)
  end

  defp create_booking(%{date: date, time: time, available: [first|_]}, response) do
    case @river_place_api.create_booking(date, first) do
      {:ok, entity} ->
        response
          |> say("OK, I've booked #{first.facility_name} for you at #{time}")
          |> should_end_session(true)
      {:error, message} ->
        IO.puts "Create Booking Error: #{message}"
        response
          |> say("#{message}. Please try again later.")
          |> should_end_session(true)
    end
  end

  defp create_booking({:error, message}, response) do
    response
      |> say("#{message}. Would you like to choose a different date?")
      |> reprompt("Would you like to choose a different date?")
      |> Response.set_attribute("question", "ChooseDifferentTime?")
      |> should_end_session(false)
  end

  defp request_attributes(request) do
    attribs = Request.attributes(request)
    Request.slot_attributes(request)
      |> Enum.filter(fn({k,v}) -> v != "" end) |> Enum.into(%{})
      |> Map.update("time", nil, fn(t) -> to_12hr_time(t) end)
      |> Map.put_new("date", Map.get(attribs, "date"))
      |> Map.put_new("time", Map.get(attribs, "time"))
  end

  defp booking(request) do
    attribs = request_attributes(request)
    date = Map.get(attribs, "date", nil)
    time = Map.get(attribs, "time", nil)
    %Booking{
      date: date,
      time: time,
      available: available_time_slots(date, time)
    }
  end

  defp validate_booking(booking = %{date: nil}), do: booking
  defp validate_booking(booking = %{date: date}) do
    case validate_date(date) do
      :ok -> booking
      error -> error
    end
  end


  defp validate_date(date) do
    datetime = Timex.parse!(date, "{YYYY}-{0M}-{D}")
    cond do
      Timex.after?(datetime, Timex.shift(Timex.today, days: 7)) ->
        {:error, "You cannot book more than seven days in advance"}
      Timex.before?(datetime, Timex.today) ->
        {:error, "You cannot book a court in the past"}
      true ->
        :ok
    end
  rescue
    e in Timex.Parse.ParseError ->
      IO.puts "Failed to convert '#{date}' to a valid date. Error: #{inspect(e)}"
      {:error, "That's not a valid date"}
  end

  defp available_time_slots(nil, nil) do
    []
  end

  defp available_time_slots(_, nil) do
    []
  end

  defp available_time_slots(nil, _) do
    []
  end

  defp available_time_slots(date, time) do
    @river_place_api.time_slots(date)
      |> TimeSlot.available
      |> TimeSlot.for_time(time)
  end

  defp to_12hr_time(""), do: nil
  defp to_12hr_time(time) do
    hours = String.split(time, ":") |> List.first |> String.to_integer
    suffix = if hours > 12, do: "PM", else: "AM"
    hours = if hours > 12, do: hours = hours - 12, else: hours
    "#{String.rjust("#{hours}", 2, ?0)}:00 #{suffix}"
  rescue
    e in ArgumentError ->
      IO.puts "Failed to convert '#{time}' to a valid time. Error: #{inspect(e)}"
      nil
  end

  def say_time(time, format \\ "hms12") do
    "<say-as interpret-as=\"time\" format=\"#{format}\">#{time}</say-as>"
  end

end
