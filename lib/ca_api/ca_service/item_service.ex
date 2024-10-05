defmodule CaApi.ItemService do
  alias CaApi.BaseServiceClient

  def search(id) do
    BaseServiceClient.request("item", :get, "ca_objects", %{id: id})
  end
end
