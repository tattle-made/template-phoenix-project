defmodule TattleWeb.AccessTokenController do

  use TattleWeb, :controller


  def say_hi(conn,_) do
    conn
    |> json(%{message: "This is to test the authentication of the access token. Hi!!"})
  end
end
