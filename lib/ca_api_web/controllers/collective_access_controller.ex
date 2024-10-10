defmodule CaApiWeb.CollectiveAccessController do
  use CaApiWeb, :controller
  alias CaApi.SearchService
  alias CaApi.ItemService

  @doc """
  Search for an item from CollectiveAccess using a Query.

  ## Example

    Request Body:
    {"query": [ "OBJ_HODCODE:\"10\"", "OBJ_PIECECODE:\"635\"" ]}

    Response on success:
    {"ok": true,
    "results": [
    {"display_label": "label", "id":"1", "object_id":"1"}]}

    Response on error:
    {"error": Reason for failure}
  """
  def query_search(conn, _params) do
    %{"query" => query } = conn.body_params

    query_string =
      query
      |> Enum.map(&String.trim(&1))
      |> Enum.join(" AND ")

    case SearchService.search(query_string) do
      {:ok, results} -> json(conn, results)
      {:error, reason} -> conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end

  @doc """
  Fetches a specific item from CollectiveAccess by ID.
  """
  def item_search(conn, %{"id" => id}) do
    case ItemService.search(id) do
      {:ok, results} -> json(conn, results)
      {:error, reason} -> conn |> put_status(:bad_request) |> json(%{error: reason})
    end
  end
end
