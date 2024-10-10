defmodule CaApiWeb.PageController do
  use CaApiWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  def submit(conn, params) do
    # Create query string
    query = %{"query" => [
      "OBJ_HODCODE:#{params["hod_code"]}",
      "OBJ_HAYCODE:#{params["hay_code"]}",
      "OBJ_PIECECODE:#{params["piece_code"]}"
    ]}

    case HTTPoison.post("localhost:4000/api/query", Jason.encode!(query), [{"Content-Type", "application/json"}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.inspect(conn)
        body = Jason.decode!(body)["results"]
        conn
        |> put_status(:ok)
        |> render(:results, results: body)

      # {:ok, %HTTPoison.Response{status_code: :bad_request, body: body}} ->
      #   conn
      #   |> put_status(:bad_request)
      #   |> json(%{error: "Request failed", response: Jason.decode!(body)})

      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Request failed", reason: reason})
    end

    # # Call API with query
    # case CaApiWeb.CollectiveAccessController.query_search(conn, %{"query" => query}) do
    #   %{"ok" => true, "results" => results} ->
    #     render(conn, "results.html", results: results)

    #   %{"error" => reason} ->
    #     conn
    #     |> put_flash(:error, "Search failed: #{reason}")
    #     |> redirect(to: "/")
    # end
  end
end
