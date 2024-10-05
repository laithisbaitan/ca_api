defmodule CaApi.SearchService do
  alias CaApi.BaseServiceClient

  def search(query) do
    BaseServiceClient.request("find", :get, "ca_objects", %{q: query})
  end
end
