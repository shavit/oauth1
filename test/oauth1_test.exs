defmodule OAuth1Test do
  use ExUnit.Case
  doctest OAuth1

  @credentials %OAuth1.Credentials{consumer_key: "xE4wvPHz1evFSBTGEFEPog",
    consumer_secret: "kF45e7zjPAoAc21Fu8E3N2USOqz7ZhfV3WpwZRZ7kBw",
    access_token: "123107377-APR9EyMZeS9weJNmHAEGYyLbxEtIKZeRNFsMKMbg",
    access_token_secret: "LsjkRh4J50vUPVVHtR55doUaI2YPiwwS8ltyTtvkE"}

  @headers %OAuth1.Headers{oauth_consumer_key: "xE4wvPHz1evFBTSFEPGEog",
    oauth_nonce: "UEh3UzvNJhXp2qvIAz1Iz2RqSLw",
    oauth_signature_method: "HMAC-SHA1",
    oauth_timestamp: "1507220864",
    oauth_token: "123107377-APR9EyMZeS9weJNmHAEGYyLbxEtIKZeRNFsMKMbg",
    oauth_version: "1.0"}

  @query_params %{query: "Is math related to science?", count: "2 + 2"}

  @url "http://api.example.com/1.0/"

  describe "oauth" do

    test "should create authorization headers" do
      headers = OAuth1.generate_authorization_headers("post", @url, @credentials)

      headers_part = ~r/OAuth oauth_consumer_key=\"xE4wvPHz1evFSBTGEFEPog\"/
      assert Regex.match?(headers_part, headers)

      headers_part = ~r/oauth_token=\"123107377-APR9EyMZeS9weJNmHAEGYyLbxEtIKZeRNFsMKMbg\"/
      assert Regex.match?(headers_part, headers)
    end

    test "should collect parameters" do
      assert @headers
        |> Map.from_struct
        |> Map.merge(@query_params)
        |> OAuth1.collect_parameters == "count=2%20%2B%202&oauth_consumer_key=xE4wvPHz1evFBTSFEPGEog&oauth_nonce=UEh3UzvNJhXp2qvIAz1Iz2RqSLw&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1507220864&oauth_token=123107377-APR9EyMZeS9weJNmHAEGYyLbxEtIKZeRNFsMKMbg&oauth_version=1.0&query=Is%20math%20related%20to%20science%3F"
    end

    test "should create a signed base string" do
      collected_params = @headers
      |> Map.from_struct
      |> Map.merge(@query_params)
      |> OAuth1.collect_parameters

      assert OAuth1.signature_base_string("post", @url, collected_params) == "POST&http%3A%2F%2Fapi.example.com%2F1.0%2F&count%3D2%2520%252B%25202%26oauth_consumer_key%3DxE4wvPHz1evFBTSFEPGEog%26oauth_nonce%3DUEh3UzvNJhXp2qvIAz1Iz2RqSLw%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1507220864%26oauth_token%3D123107377-APR9EyMZeS9weJNmHAEGYyLbxEtIKZeRNFsMKMbg%26oauth_version%3D1.0%26query%3DIs%2520math%2520related%2520to%2520science%253F"
    end

    test "should generate a signing key" do
      signing_key = "kF45e7zjPAoAc21Fu8E3N2USOqz7ZhfV3WpwZRZ7kBw&LsjkRh4J50vUPVVHtR55doUaI2YPiwwS8ltyTtvkE"
      assert OAuth1.generate_signing_key(@credentials.consumer_secret,
        @credentials.access_token_secret) == signing_key
    end

    test "should calculate the signature" do
      signed_base_string = "POST&http%3A%2F%2Fapi.example.com%2F1.0%2F&count%3D2%2520%252B%25202%26oauth_consumer_key%3DxE4wvPHz1evFBTSFEPGEog%26oauth_nonce%3DUEh3UzvNJhXp2qvIAz1Iz2RqSLw%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1507220864%26oauth_token%3D123107377-APR9EyMZeS9weJNmHAEGYyLbxEtIKZeRNFsMKMbg%26oauth_version%3D1.0%26query%3DIs%2520math%2520related%2520to%2520science%253F"
      signing_key = "kF45e7zjPAoAc21Fu8E3N2USOqz7ZhfV3WpwZRZ7kBw&LsjkRh4J50vUPVVHtR55doUaI2YPiwwS8ltyTtvkE"

      assert OAuth1.calculate_signature(signing_key, signed_base_string) == "IjPsSry9LHUItCV5m9U+IAcg+Mw="
    end

    test "should build header string" do
      auth_headers = @headers
      oauth_signature = ""
      oauth_token = ""
      headers = OAuth1.authorize_request_headers(auth_headers, oauth_signature, oauth_token)
      header_string = OAuth1.build_header_string(headers)
    end

  end
end
