defmodule RiverPlaceMock do
  alias RiverPlace.TimeSlot

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

  def time_slots(_) do
    [
      %TimeSlot{id: 1, start_time: "07:00 AM", end_time: "08:00 AM", status: "valid", booking_id: 123, facility_name: "Court 1"},
      %TimeSlot{id: 2, start_time: "08:00 AM", end_time: "09:00 AM", status: "valid", booking_id: nil, facility_name: "Court 1"},
      %TimeSlot{id: 3, start_time: "07:00 AM", end_time: "08:00 AM", status: "valid", booking_id: 456, facility_name: "Court 2"},
      %TimeSlot{id: 4, start_time: "08:00 AM", end_time: "09:00 AM", status: "valid", booking_id: nil, facility_name: "Court 2"}
    ]
  end

  def create_booking(_, %{start_time: "07:00 AM"}) do
    {:error, "This is a sample error message"}
  end

  def create_booking(_, %{start_time: "08:00 AM"}) do
    {:ok, [%{"id": "1234"}]}
  end

  def delete_booking("2016-01-01", %{start_time: "07:00 AM"}) do
    :ok
  end

  def delete_booking("2016-01-01", _) do
    :error
  end

end
