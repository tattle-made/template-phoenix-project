defmodule TattleWeb.Plugs.AuthenticateAccessToken do
  use TattleWeb, :controller

  require Logger

  alias Tattle.Api.AccessToken
  alias Tattle.Api.Token
  alias Tattle.Api

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, data} <- Token.verify(token),
         %AccessToken{} = access_token <- Api.get_access_token(data.token_id),
         true <- access_token.expiry >= Date.utc_today() do
      conn |> assign(:access_token, access_token)
    else
      _error -> conn |> put_status(:unauthorized) |> json(%{error: "Access is Unauthorized"})
    end
  end

end
