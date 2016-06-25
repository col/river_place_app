defmodule RiverPlaceApp.User do
  use RiverPlaceApp.Web, :model

  schema "users" do
    field :name, :string
    field :email, :string
    field :username, :string
    field :new_password, :string, virtual: true
    field :password, :string

    field :rp_username, :string
    field :rp_password, :string

    timestamps
  end

  @required_fields ~w(name username email)
  @optional_fields ~w(rp_username rp_password)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(new_password), [])
    |> validate_length(:new_password, min: 6, max: 100)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{new_password: pass}} ->
        put_change(changeset, :password, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

end
