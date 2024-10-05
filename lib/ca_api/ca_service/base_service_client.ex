defmodule CaApi.BaseServiceClient do
  @moduledoc """
  A base module for interacting with the CollectiveAccess API.
  """

  alias HTTPoison

  @base_url Application.compile_env!(:ca_api, :collective_access_base_url)
  @auth_token_file Path.join(System.tmp_dir(), "ca-service-wrapper-token.txt")

  @doc """
  Sends a request to the CollectiveAccess API with authentication.
  """
  def request(service, method, table, params \\ %{}) do
    # Add the authToken as a query parameter
    token = get_auth_token()
    params_with_token = Map.put(params, "authToken", token)

    url = build_url(service, table, params_with_token)

    case HTTPoison.request(method, url, "", []) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, parse_response(body)}

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        reauthenticate()
        request(service, method, table, params)

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp build_url(service, table, params) do
    case service do
      "find" ->
        query = URI.encode_query(params)
        "#{@base_url}/service.php/#{service}/#{table}?#{query}&noCache=1"
      "item" ->
        id_value =
          case Map.fetch(params, :id) do
            {:ok, value} -> value
            {:error} -> Map.get(params, "id")
          end
        "#{@base_url}/service.php/#{service}/#{table}/id/#{id_value}&noCache=1"

    end
  end

  defp get_auth_token do
    if File.exists?(@auth_token_file) do
      File.read!(@auth_token_file)
    else
      authenticate()
    end
  end

  defp authenticate do
    user = Application.fetch_env!(:ca_api, :ca_service_api_user)
    key = Application.fetch_env!(:ca_api, :ca_service_api_key)

    auth_url = "#{@base_url}/service.php/auth/login"
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(auth_url, [], [hackney: [basic_auth: {user, key}]])
    token = extract_token_from_response(body)

    File.write!(@auth_token_file, token)
    token
  end

  defp extract_token_from_response(body) do
    case Jason.decode(body) do
      {:ok, %{"authToken" => token}} ->
        # IO.puts("token is: #{token}")
        token
        _ -> raise "Authentication failed"
        # err -> raise "#{err}"
    end
  end

  defp reauthenticate do
    File.rm!(@auth_token_file)
    authenticate()
  end

  defp parse_response(body) do
    Jason.decode!(body)
  end
end
