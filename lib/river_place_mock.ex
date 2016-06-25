defmodule RiverPlaceMock do
  alias RiverPlace.{Facility, TimeSlot}

  def login("foo", "bar") do
    :ok
  end

  def login(_, _) do
    :error
  end

  def logout do
    :ok
  end

  def logged_in? do
    true
  end

  def time_slots("2016-01-01") do
    [
      %TimeSlot{id: 1, start_time: "07:00 AM", end_time: "08:00 AM", booking_id: nil, facility_name: "Court 1"},
      %TimeSlot{id: 2, start_time: "08:00 AM", end_time: "09:00 AM", booking_id: nil, facility_name: "Court 1"},
      %TimeSlot{id: 3, start_time: "07:00 AM", end_time: "08:00 AM", booking_id: nil, facility_name: "Court 2"},
      %TimeSlot{id: 4, start_time: "08:00 AM", end_time: "09:00 AM", booking_id: nil, facility_name: "Court 2"}
    ]
  end

  def time_slots("2016-01-02") do
    [
      %TimeSlot{id: 1, start_time: "07:00 AM", end_time: "08:00 AM", booking_id: nil, facility_name: "Court 1"},
      %TimeSlot{id: 2, start_time: "08:00 AM", end_time: "09:00 AM", booking_id: nil, facility_name: "Court 1"},
      %TimeSlot{id: 3, start_time: "07:00 AM", end_time: "08:00 AM", booking_id: nil, facility_name: "Court 2"},
      %TimeSlot{id: 4, start_time: "08:00 AM", end_time: "09:00 AM", booking_id: nil, facility_name: "Court 2"}
    ]
  end

  def create_booking("2016-01-01", %{id: 1}) do
    :ok
  end

  def create_booking("2016-01-02", %{id: 1}) do
    :error
  end

  def delete_booking("2016-01-01", %{id: 1}) do
    :error
  end

  def delete_booking("2016-01-02", %{id: 1}) do
    :ok
  end

end
