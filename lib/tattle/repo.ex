defmodule Tattle.Repo do
  use Ecto.Repo,
    otp_app: :tattle,
    adapter: Ecto.Adapters.Postgres
end
